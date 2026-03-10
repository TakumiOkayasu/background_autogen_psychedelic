#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform float uSpeed;
uniform float uComplexity;
uniform float uBrightness;
uniform float uNoiseIntensity;

out vec4 fragColor;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float t = uTime * uSpeed;

  // 1回のwarp計算 (8層フィードバック座標変換)
  vec2 p = (uv - 0.5) * 2.0;
  int iterations = int(uComplexity) + 3;

  for (int i = 0; i < 8; i++) {
    if (i >= iterations) break;
    float fi = float(i);

    vec2 prev = p;
    p = vec2(
      sin(p.y * 3.0 + t * (0.3 + fi * 0.08) + fi * 1.7)
      + cos(p.x * 2.5 - t * 0.2 + fi * 0.6),
      cos(p.x * 2.8 - t * (0.25 + fi * 0.06) + fi * 2.3)
      + sin(p.y * 3.2 + t * 0.35)
    );

    // abs折り返し + 前座標とのブレンドで安定化
    if (i / 2 * 2 == i) {
      p = abs(p) - 0.6;
    }
    p = mix(p, prev * 0.3, 0.1);
  }

  // 色収差: warp後の座標を微小オフセットして各チャンネルをサンプル
  vec3 finalColor;
  for (int ch = 0; ch < 3; ch++) {
    float fch = float(ch);
    vec2 cp = p + vec2(sin(fch * 2.1), cos(fch * 2.1)) * 0.15;

    // HSV hue cycling: warp座標から直接hueを生成
    float hue = fract(
      sin(cp.x * 2.0 + cp.y * 3.0) * 0.5
      + t * 0.1
      + fch * 0.33
    );
    float sat = 0.85 + sin(cp.x * 3.0 + t * 0.15) * 0.15;
    float val = 0.75 + cos(cp.y * 2.0 - t * 0.2) * 0.25;

    vec3 hsvColor = hsv2rgb(vec3(hue, sat, val));

    // uniform色とブレンド
    float blend = smoothstep(0.3, 0.35,
      sin(cp.x * 4.0 + cp.y * 5.0 + t * 0.3) * 0.5 + 0.5);
    vec3 baseColor = mix(uColor1, uColor2, blend);
    baseColor = mix(baseColor, uColor3,
      smoothstep(0.6, 0.65, cos(cp.x * 3.0 - cp.y * 2.0) * 0.5 + 0.5));

    vec3 mixed = mix(hsvColor, baseColor, 0.35);
    finalColor[ch] = mixed[ch];
  }

  // 鋭いエッジオーバーレイ
  vec2 ep = (uv - 0.5) * 2.0;
  float edgeOverlay = smoothstep(0.0, 0.04,
    abs(sin(ep.x * 8.0 + ep.y * 6.0 + t * 0.5)));
  finalColor = mix(finalColor * 0.7, finalColor, edgeOverlay);

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  finalColor += noise * uNoiseIntensity * noiseBlend;
  finalColor *= uBrightness;

  fragColor = vec4(finalColor, 1.0);
}

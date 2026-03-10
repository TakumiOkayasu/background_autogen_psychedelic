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

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float t = uTime * uSpeed;

  vec2 p = (uv - 0.5) * 2.5;
  int layers = int(uComplexity) + 2;

  // 波源座標をdomain warpingで歪める（コースティクス前処理）
  vec2 wp = p;
  for (int i = 0; i < 5; i++) {
    if (i >= layers) break;
    float fi = float(i);
    wp = vec2(
      wp.x + sin(wp.y * 2.5 + t * 0.4 + fi * 1.1) * 0.4,
      wp.y + cos(wp.x * 2.3 - t * 0.35 + fi * 0.9) * 0.4
    );
  }

  // 4つの動的波源からの干渉パターン
  float caustic = 0.0;
  for (int i = 0; i < 7; i++) {
    if (i >= layers + 2) break;
    float fi = float(i);
    vec2 source = vec2(
      sin(t * 0.2 + fi * 1.5) * 1.2,
      cos(t * 0.18 + fi * 2.1) * 1.2
    );
    float d = length(wp - source);
    // abs(sin())で鋭い焼痕ライン
    caustic += abs(sin(d * 8.0 - t * 1.5 + fi * 0.7)) / (1.0 + fi * 0.3);
  }

  // 鋭いエッジで色分割
  float e1 = smoothstep(0.0, 0.06, abs(caustic - 1.5));
  float e2 = smoothstep(0.0, 0.06, abs(caustic - 2.5));
  float e3 = smoothstep(0.0, 0.08, abs(caustic - 3.5));

  vec3 color = uColor1;
  color = mix(uColor3 * 0.8, color, e1);
  color = mix(uColor2, color, e2);
  color = mix(uColor1 * 0.4 + uColor2 * 0.6, color, e3);
  color = mix(color, uColor3 * 0.5 + uColor1 * 0.5,
    smoothstep(0.4, 0.45, fract(caustic * 0.5) ));

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}

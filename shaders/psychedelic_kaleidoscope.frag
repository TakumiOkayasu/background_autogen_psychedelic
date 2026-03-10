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

const float PI = 3.14159265;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float t = uTime * uSpeed;

  vec2 centered = uv - 0.5;
  float r = length(centered);
  float angle = atan(centered.y, centered.x);

  // 万華鏡折り返し
  float segments = floor(uComplexity) * 2.0 + 4.0;
  float segAngle = PI * 2.0 / segments;
  angle = mod(angle + t * 0.25, segAngle);
  angle = abs(angle - segAngle * 0.5);

  // 折り返し後の座標
  vec2 p = vec2(cos(angle), sin(angle)) * r * 3.0;
  int iterations = int(uComplexity) + 3;

  // abs/dot inversion + domain warping: 無限ミラートンネル
  for (int i = 0; i < 8; i++) {
    if (i >= iterations) break;
    float fi = float(i);

    // inversion mapping: 空間の内外反転
    float dp = dot(p, p) + 0.2;
    p = abs(p) / dp - vec2(1.2 + sin(t * 0.15 + fi * 0.8) * 0.3);

    // 回転
    float ca = cos(t * 0.12 + fi * 0.5), sa = sin(t * 0.12 + fi * 0.5);
    p *= mat2(ca, sa, -sa, ca);

    // domain warp追加
    p += vec2(
      sin(p.y * 2.0 + t * 0.2 + fi) * 0.3,
      cos(p.x * 2.0 - t * 0.15 + fi) * 0.3
    );
  }

  // 鋭い幾何学エッジ
  float b1 = smoothstep(0.0, 0.05, abs(sin(p.x * 6.0 + p.y * 4.0)));
  float b2 = smoothstep(0.0, 0.05, abs(cos(p.y * 5.0 - p.x * 3.0 + t * 0.3)));
  float radial = smoothstep(0.0, 0.06, abs(sin(r * 15.0 - t * 2.0)));

  vec3 color = mix(uColor1, uColor2, b1);
  color = mix(color, uColor3, (1.0 - b2) * 0.5);
  color = mix(color, uColor1 * 0.3 + uColor2 * 0.7, (1.0 - radial) * 0.4);
  color = mix(color, uColor3 * 0.5 + uColor1 * 0.5,
    smoothstep(0.4, 0.45, sin(p.x * p.y * 2.0 + t * 0.5) * 0.5 + 0.5));

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}

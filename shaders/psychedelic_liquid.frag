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

  vec2 p = uv * 2.0;
  int iterations = int(uComplexity) + 3;

  // 8層domain warping: 各層で異なる周波数・位相・振幅
  for (int i = 0; i < 8; i++) {
    if (i >= iterations) break;
    float fi = float(i);
    float freq1 = 2.1 + fi * 0.7;
    float freq2 = 1.8 + fi * 0.5;
    float phase = fi * 1.3 + t * (0.4 + fi * 0.15);
    p = vec2(
      sin(p.y * freq1 + phase) * 1.3 + cos(p.x * freq2 - t * 0.6 + fi * 0.9),
      cos(p.x * (2.3 + fi * 0.4) - phase * 0.8) * 1.3 + sin(p.y * (1.7 + fi * 0.6) + t * 0.9)
    );
  }

  // 2つのbandを重畳: 鋭いsmoothstepで色境界くっきり
  float band1 = sin(p.x * 4.0 + p.y * 3.0 + t * 0.5);
  float band2 = cos(p.y * 3.5 - p.x * 2.5 - t * 0.3);
  float edge1 = smoothstep(0.3, 0.35, band1 * 0.5 + 0.5);
  float edge2 = smoothstep(0.3, 0.35, band2 * 0.5 + 0.5);

  // 6色以上のバリエーション: 色の掛け合わせ
  vec3 col4 = uColor1 * 0.5 + uColor3 * 0.5;
  vec3 col5 = uColor2 * 0.6 + uColor1 * 0.4;
  vec3 col6 = uColor3 * 0.7 + uColor2 * 0.3;

  vec3 color = mix(uColor1, uColor2, edge1);
  color = mix(color, uColor3, edge2);
  color = mix(color, col4, smoothstep(0.5, 0.55, band1 * band2 * 0.5 + 0.5));
  color = mix(color, col5, smoothstep(0.6, 0.65, sin(p.x * 2.0 + p.y * 3.0) * 0.5 + 0.5));
  color = mix(color, col6, smoothstep(0.7, 0.75, cos(p.x * 3.0 - p.y * 2.0) * 0.5 + 0.5));

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}

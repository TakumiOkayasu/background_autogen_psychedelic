#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform vec3 uColor1;
uniform vec3 uColor2;
uniform vec3 uColor3;
uniform float uSpeed;
uniform float uComplexity;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float t = uTime * uSpeed;

  // 中心からの距離
  vec2 center = uv - 0.5;
  float dist = length(center);

  // 同心円波の合成
  float wave = 0.0;
  int iterations = int(uComplexity);
  for (int i = 0; i < 5; i++) {
    if (i >= iterations) break;
    float freq = 8.0 + float(i) * 4.0;
    float phase = t * (0.8 + float(i) * 0.3);
    wave += sin(dist * freq - phase) / (1.0 + float(i));
  }

  float band = wave * 0.5 + 0.5;

  vec3 color = mix(uColor1, uColor2, smoothstep(0.0, 0.5, band));
  color = mix(color, uColor3, smoothstep(0.4, 0.9, band));

  fragColor = vec4(color, 1.0);
}

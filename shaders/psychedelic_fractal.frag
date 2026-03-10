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

  // 反復座標変換の自己相似パターン
  vec2 p = (uv - 0.5) * 2.5;
  int iterations = int(uComplexity);
  float sa = sin(t * 0.3);
  for (int i = 0; i < 5; i++) {
    if (i >= iterations) break;
    float dp = dot(p, p) + 0.15;
    p = abs(p) / dp - 1.0;
    float ca = cos(t * 0.2 + float(i));
    p *= mat2(ca, sa, -sa, ca);
  }

  float band = sin(length(p) * 2.0 + t * 0.4) * 0.5 + 0.5;

  vec3 color = mix(uColor1, uColor2, smoothstep(0.0, 0.5, band));
  color = mix(color, uColor3, smoothstep(0.4, 0.9, band));

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}

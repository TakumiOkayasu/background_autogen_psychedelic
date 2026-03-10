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

  // 多面体折り返し: complexity依存のセグメント数
  float segments = floor(uComplexity) * 2.0 + 6.0;
  float segAngle = PI * 2.0 / segments;
  float foldedAngle = mod(angle + t * 0.2, segAngle);
  foldedAngle = abs(foldedAngle - segAngle * 0.5);

  // 折り返し後の座標でfractal反復
  vec2 p = vec2(foldedAngle / segAngle * 2.0, r * 3.0);
  int iterations = int(uComplexity) + 2;

  for (int i = 0; i < 7; i++) {
    if (i >= iterations) break;
    float fi = float(i);

    // abs + inversion: fractalパターンのセグメント内展開
    float dp = dot(p, p) + 0.15;
    p = abs(p) / dp - vec2(0.8 + sin(t * 0.2 + fi) * 0.2);

    // 回転
    float ca = cos(t * 0.15 + fi * 0.7), sa = sin(t * 0.15 + fi * 0.7);
    p *= mat2(ca, sa, -sa, ca);

    // sin歪みで有機的な揺らぎ
    p += vec2(sin(p.y * 1.5 + t * 0.2), cos(p.x * 1.5 - t * 0.15)) * 0.2;
  }

  // 鋭い放射状バンド
  float b1 = smoothstep(0.0, 0.05, abs(sin(p.x * 5.0 + p.y * 3.0)));
  float b2 = smoothstep(0.0, 0.05, abs(cos(p.y * 4.0 - p.x * 6.0 + t * 0.3)));
  float b3 = smoothstep(0.0, 0.07, abs(sin(r * 10.0 - t * 1.5)));

  vec3 color = mix(uColor1, uColor2, b1 * b2);
  color = mix(color, uColor3, (1.0 - b3) * 0.5);
  color = mix(color, uColor1 * 0.5 + uColor2 * 0.5,
    smoothstep(0.3, 0.35, sin(p.x * p.y + t * 0.4) * 0.5 + 0.5));
  color = mix(color, uColor3 * 0.6 + uColor1 * 0.4,
    (1.0 - b1) * (1.0 - b2) * 0.3);

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}

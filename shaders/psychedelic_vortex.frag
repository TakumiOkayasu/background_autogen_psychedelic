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

  vec2 p = (uv - 0.5) * 3.0;
  int iterations = int(uComplexity) + 2;

  // 複数特異点による重力井戸: 各点が空間を引き込む
  for (int i = 0; i < 7; i++) {
    if (i >= iterations) break;
    float fi = float(i);

    // 時間変動する特異点の位置
    vec2 singularity = vec2(
      sin(t * 0.3 + fi * 2.1) * 0.8,
      cos(t * 0.25 + fi * 1.7) * 0.8
    );

    // inversion mapping: 特異点周辺で空間が極端に歪む
    vec2 diff = p - singularity;
    float dist2 = dot(diff, diff) + 0.15;
    p += diff / dist2 * 0.6;

    // abs折り返し + 回転で対称性を崩す
    p = abs(p) - 0.7;
    float ca = cos(t * 0.15 + fi * 0.4), sa = sin(t * 0.15 + fi * 0.4);
    p *= mat2(ca, sa, -sa, ca);
  }

  // 鋭い色帯: 特異点周りの歪んだ空間から生成
  float b1 = smoothstep(0.0, 0.06, abs(sin(p.x * 5.0 + p.y * 3.0 + t * 0.3)));
  float b2 = smoothstep(0.0, 0.06, abs(cos(p.y * 4.0 - p.x * 6.0)));
  float b3 = smoothstep(0.0, 0.08, abs(sin(length(p) * 4.0 - t * 0.5)));

  vec3 color = mix(uColor1, uColor2, b1);
  color = mix(color, uColor3, (1.0 - b2) * 0.6);
  color = mix(color, uColor1 * 0.4 + uColor3 * 0.6, (1.0 - b3) * 0.4);
  color = mix(color, uColor2 * 0.5 + uColor1 * 0.5,
    smoothstep(0.3, 0.35, sin(p.x * p.y * 2.0 + t * 0.2) * 0.5 + 0.5));

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}

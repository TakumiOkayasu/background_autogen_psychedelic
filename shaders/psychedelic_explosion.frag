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

  // 3つの爆発中心
  int iterations = int(uComplexity) + 2;
  vec3 totalColor = vec3(0.0);
  float totalWeight = 0.0;

  for (int center = 0; center < 3; center++) {
    float fc = float(center);
    vec2 origin = vec2(
      0.5 + sin(t * 0.15 + fc * 2.1) * 0.25,
      0.5 + cos(t * 0.12 + fc * 1.7) * 0.25
    );

    vec2 p = (uv - origin) * 3.0;

    // fractal burst: abs折り返し + inversion + 回転
    for (int i = 0; i < 7; i++) {
      if (i >= iterations) break;
      float fi = float(i);

      p = abs(p) * 1.6 - vec2(
        0.9 + sin(t * 0.2 + fi + fc * 1.5) * 0.3,
        0.9 + cos(t * 0.25 + fi + fc * 2.0) * 0.3
      );

      float ca = cos(t * 0.18 + fi * 0.5 + fc), sa = sin(t * 0.18 + fi * 0.5 + fc);
      p *= mat2(ca, sa, -sa, ca);

      // dot product inversion for singularity
      float dp = dot(p, p) + 0.3;
      p = abs(p) / dp * 2.0 - 0.5;
    }

    // 鋭い幾何学的衝撃波
    float d1 = smoothstep(0.0, 0.06, abs(sin(length(p) * 4.0 + t)));
    float d2 = smoothstep(0.0, 0.06, abs(sin(p.x * 5.0 + p.y * 5.0 + t * 1.2)));

    vec2 dv = uv - origin;
    float weight = 1.0 / (1.0 + dot(dv, dv) * 9.0);

    vec3 c = mix(uColor1, uColor2, d1);
    c = mix(c, uColor3, (1.0 - d2) * 0.6);

    totalColor += c * weight;
    totalWeight += weight;
  }

  vec3 color = totalColor / totalWeight;

  // 追加の色レイヤー
  vec2 gp = (uv - 0.5) * 2.0;
  color = mix(color, uColor1 * 0.4 + uColor3 * 0.6,
    smoothstep(0.3, 0.35, sin(gp.x * 8.0 + gp.y * 6.0 + t * 0.5) * 0.5 + 0.5) * 0.3);

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}

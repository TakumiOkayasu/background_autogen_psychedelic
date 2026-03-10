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

  // Domain warping: sin/cosで座標を再帰的にねじる
  vec2 p = uv * 2.0;
  int iterations = int(uComplexity);
  for (int i = 0; i < 5; i++) {
    if (i >= iterations) break;
    p = vec2(
      sin(p.y * 2.1 + t * 0.7 + float(i) * 1.3) + cos(p.x * 1.8 - t * 0.5),
      cos(p.x * 2.3 - t * 0.6 + float(i) * 0.9) + sin(p.y * 1.7 + t * 0.8)
    );
  }

  // warpedな座標からノイズバンドを生成
  float band = sin(p.x * 3.0 + p.y * 2.0 + t * 0.3) * 0.5 + 0.5;

  // 3色にsmoothstepでマッピング
  vec3 color = mix(uColor1, uColor2, smoothstep(0.0, 0.5, band));
  color = mix(color, uColor3, smoothstep(0.4, 0.9, band));

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}

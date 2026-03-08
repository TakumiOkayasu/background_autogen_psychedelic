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

  // 複数sin波の加算合成（プラズマ効果）
  float v = 0.0;
  int iterations = int(uComplexity);
  for (int i = 0; i < 5; i++) {
    if (i >= iterations) break;
    float fi = float(i);
    v += sin(uv.x * (3.0 + fi * 2.0) + t * 0.7 + fi);
    v += sin(uv.y * (4.0 + fi * 1.5) - t * 0.5 + fi * 0.8);
    v += sin((uv.x + uv.y) * (2.0 + fi) + t * 0.6);
  }

  float band = v / (float(iterations) * 3.0) * 0.5 + 0.5;
  band = clamp(band, 0.0, 1.0);

  vec3 color = mix(uColor1, uColor2, smoothstep(0.0, 0.5, band));
  color = mix(color, uColor3, smoothstep(0.4, 0.9, band));

  fragColor = vec4(color, 1.0);
}

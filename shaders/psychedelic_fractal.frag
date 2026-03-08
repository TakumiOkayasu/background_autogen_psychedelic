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

  // 反復座標変換の自己相似パターン
  vec2 p = (uv - 0.5) * 4.0;
  int iterations = int(uComplexity);
  for (int i = 0; i < 5; i++) {
    if (i >= iterations) break;
    p = abs(p) / dot(p, p) - 1.0;
    p *= mat2(cos(t * 0.2 + float(i)), sin(t * 0.3),
              -sin(t * 0.3), cos(t * 0.2 + float(i)));
  }

  float band = sin(length(p) * 2.0 + t * 0.4) * 0.5 + 0.5;

  vec3 color = mix(uColor1, uColor2, smoothstep(0.0, 0.5, band));
  color = mix(color, uColor3, smoothstep(0.4, 0.9, band));

  fragColor = vec4(color, 1.0);
}

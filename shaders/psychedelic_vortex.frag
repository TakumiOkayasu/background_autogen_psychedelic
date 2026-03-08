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

  // 中心からの極座標
  vec2 center = uv - 0.5;
  float r = length(center);
  float angle = atan(center.y, center.x);

  // 極座標変換 + 角度にsin波でねじり
  int iterations = int(uComplexity);
  float twist = 0.0;
  for (int i = 0; i < 5; i++) {
    if (i >= iterations) break;
    twist += sin(r * 6.0 - t * 1.2 + float(i) * 1.5) * 0.8;
  }
  angle += twist;

  // ねじった角度からバンド生成
  float band = sin(angle * 3.0 + r * 8.0 - t * 0.5) * 0.5 + 0.5;

  // 3色マッピング
  vec3 color = mix(uColor1, uColor2, smoothstep(0.0, 0.5, band));
  color = mix(color, uColor3, smoothstep(0.4, 0.9, band));

  fragColor = vec4(color, 1.0);
}

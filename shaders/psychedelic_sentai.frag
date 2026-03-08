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

  // atan2で放射状セグメント + 回転
  vec2 center = uv - 0.5;
  float angle = atan(center.y, center.x) + t * 0.5;
  float r = length(center);

  // セグメント数はcomplexityで制御
  float segments = uComplexity * 2.0;
  float sector = floor(angle / (6.2831853 / segments));
  float sectorAngle = mod(angle, 6.2831853 / segments) * segments;

  // セクター内の変化
  float band = sin(sectorAngle * 3.14159 + r * 8.0 - t) * 0.5 + 0.5;
  band = mix(band, mod(sector, 3.0) / 3.0, 0.3);

  vec3 color = mix(uColor1, uColor2, smoothstep(0.0, 0.5, band));
  color = mix(color, uColor3, smoothstep(0.4, 0.9, band));

  fragColor = vec4(color, 1.0);
}

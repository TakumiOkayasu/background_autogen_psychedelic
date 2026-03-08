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
  fragColor = vec4(uv, 0.0, 1.0);
}

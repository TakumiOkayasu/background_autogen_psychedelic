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

float hash2(vec2 p) {
  return fract(sin(dot(p, vec2(269.5, 183.3))) * 43758.5453);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float t = uTime * uSpeed;

  vec2 p = uv * 3.0;
  int iterations = int(uComplexity) + 2;

  // 擬似Voronoi: 格子点をdomain warpで歪めてセル生成
  float minDist = 10.0;
  float secondDist = 10.0;
  vec2 closestCell = vec2(0.0);

  vec2 ip = floor(p);
  vec2 fp = fract(p);

  for (int y = -1; y <= 1; y++) {
    for (int x = -1; x <= 1; x++) {
      vec2 neighbor = vec2(float(x), float(y));
      vec2 cellId = ip + neighbor;

      // 格子点をdomain warpで動かす (hash + 単一sin/cosで軽量化)
      vec2 cellPoint = neighbor + vec2(hash(cellId), hash2(cellId));
      float phase = t * 0.3 + cellId.x * 2.0 + cellId.y * 2.5;
      int clampedIter = iterations - 1;
      if (clampedIter > 4) clampedIter = 4;
      float amp = 0.2 * float(clampedIter);
      cellPoint += vec2(sin(phase), cos(phase * 1.3 + 1.0)) * amp;

      float d = length(fp - cellPoint);
      if (d < minDist) {
        secondDist = minDist;
        minDist = d;
        closestCell = cellId;
      } else if (d < secondDist) {
        secondDist = d;
      }
    }
  }

  // セル境界の鋭いエッジ
  float edge = secondDist - minDist;
  float sharpEdge = smoothstep(0.0, 0.05, edge);

  // セル内部の色: セルIDからハッシュで決定
  float cellHash = hash(closestCell + 0.5);
  float cellPhase = cellHash * 6.28 + t * 0.4;

  float b1 = smoothstep(0.3, 0.35, sin(cellPhase) * 0.5 + 0.5);
  float b2 = smoothstep(0.5, 0.55, sin(cellPhase * 1.7 + 1.0) * 0.5 + 0.5);

  vec3 color = mix(uColor1, uColor2, b1);
  color = mix(color, uColor3, b2);
  // 境界線を別色で描画
  color = mix(uColor1 * 0.3 + uColor3 * 0.7, color, sharpEdge);
  color = mix(color, uColor2 * 0.6 + uColor1 * 0.4,
    smoothstep(0.6, 0.65, fract(minDist * 4.0 + t * 0.3)));

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}

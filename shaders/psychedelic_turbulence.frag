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

float valueNoise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  f = f * f * (3.0 - 2.0 * f);
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));
  return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

const float fbmCa = 0.8775826;  // cos(0.5)
const float fbmSa = 0.4794255;  // sin(0.5)

float fbm(vec2 p, int octaves, float t) {
  float v = 0.0;
  float amp = 0.5;
  float freq = 1.0;
  for (int i = 0; i < 6; i++) {
    if (i >= octaves) break;
    v += amp * valueNoise(p * freq + t * 0.2 * float(i + 1));
    freq *= 2.1;
    amp *= 0.5;
    // 回転でオクターブ間のアーティファクト軽減
    p *= mat2(fbmCa, fbmSa, -fbmSa, fbmCa);
  }
  return v;
}

vec3 hsv2rgb(vec3 c) {
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  float t = uTime * uSpeed;

  vec2 p = uv * 2.0;
  int layers = int(uComplexity) + 2;

  // 深いnoise-on-noise warping
  for (int i = 0; i < 5; i++) {
    if (i >= layers) break;
    float fi = float(i);
    float n1 = fbm(p + vec2(t * 0.1 + fi * 3.7, fi * 2.3), 3, t) * 2.0 - 1.0;
    float n2 = fbm(p + vec2(fi * 5.3, t * 0.08 + fi * 1.9) + 100.0, 3, t) * 2.0 - 1.0;
    p += vec2(n1, n2) * 0.7;
  }

  // warpされた座標から多スケールfBm
  float v = fbm(p * 2.0, layers, t);
  float turb = abs(v * 2.0 - 1.0);

  // 薄膜干渉的色分離: turbulence値をhueに変換
  float hue = fract(turb * 2.0 + t * 0.05);
  vec3 iridescent = hsv2rgb(vec3(hue, 0.8, 0.9));

  // uniform色と干渉色をブレンド
  float band = smoothstep(0.15, 0.2, turb);
  float band2 = smoothstep(0.35, 0.4, turb);
  float band3 = smoothstep(0.55, 0.6, turb);

  vec3 color = mix(uColor1, uColor2, band);
  color = mix(color, uColor3, band2);
  color = mix(color, iridescent * 0.5 + uColor1 * 0.5, band3);
  // 油膜エッジ: 鋭い境界線
  color = mix(uColor3 * 0.3 + uColor2 * 0.7, color,
    smoothstep(0.0, 0.04, abs(turb - 0.35)));

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}

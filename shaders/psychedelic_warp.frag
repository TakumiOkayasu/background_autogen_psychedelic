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

  // LiquidGlass: 複数レンズの屈折歪みを多段カスケード
  // uComplexity = 粘度 (高い→歪みが強い→粘性の高い液体)
  vec2 p = uv;
  float viscosity = uComplexity * 0.15 + 0.1;
  int iterations = int(uComplexity) + 3;

  // 多段レンズ歪み: 各レンズが異なる位置・曲率で空間を屈折
  for (int i = 0; i < 8; i++) {
    if (i >= iterations) break;
    float fi = float(i);

    // レンズ中心の動的位置
    vec2 lensCenter = vec2(
      0.5 + sin(t * 0.2 + fi * 1.8) * 0.3,
      0.5 + cos(t * 0.17 + fi * 2.3) * 0.3
    );

    vec2 toLens = p - lensCenter;
    float lensR = length(toLens);

    // 屈折: レンズ中心に近いほど強い歪み
    float refraction = viscosity / (lensR * lensR + 0.08);
    vec2 normal = toLens / (lensR + 0.001);

    // sin/cosで波状の屈折面（平面レンズではなく波打つガラス）
    float wave = sin(lensR * 12.0 - t * 1.5 + fi * 2.0) * 0.5 + 0.5;
    refraction *= wave;

    p += normal * refraction * 0.03;

    // 各レンズ後にabs折り返し: ガラス片の反射
    if (i / 3 * 3 == i) {
      p = vec2(0.5) + abs(p - vec2(0.5));
      p = mod(p, 1.0);
    }
  }

  // 屈折後の座標から色パターン生成
  // ベースはグラデーション + 幾何学模様
  vec2 dp = (p - 0.5) * 4.0;

  float pattern1 = sin(dp.x * 5.0 + dp.y * 3.0 + t * 0.4);
  float pattern2 = cos(dp.y * 4.0 - dp.x * 6.0 - t * 0.3);
  float pattern3 = sin(length(dp) * 6.0 - t * 0.8);

  float e1 = smoothstep(0.0, 0.06, abs(pattern1));
  float e2 = smoothstep(0.0, 0.06, abs(pattern2));
  float e3 = smoothstep(0.0, 0.08, abs(pattern3));

  vec3 color = mix(uColor1, uColor2, e1);
  color = mix(color, uColor3, (1.0 - e2) * 0.5);
  color = mix(color, uColor1 * 0.3 + uColor3 * 0.7, (1.0 - e3) * 0.4);

  // ガラス反射のハイライト: 屈折量に応じた輝度変化
  float distortion = length(p - uv) * 10.0;
  color += vec3(distortion * 0.15);

  color = mix(color, uColor2 * 0.6 + uColor1 * 0.4,
    smoothstep(0.4, 0.45, sin(dp.x * dp.y + t * 0.3) * 0.5 + 0.5) * 0.3);

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}

# 新規シェーダーパターン追加 + スケール拡大 実装計画

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 3つの複雑なシェーダーパターン (liquid, kaleidoscope, explosion) を追加し、既存パターンのエフェクトスケールを拡大する。

**Architecture:** ShaderPattern enum に3値を追加し、対応する .frag ファイルを新規作成。既存シェーダーのUVスケール係数を調整してパターンを大きくする。uniform layout (16 floats) は全パターン共通のまま維持。

**Tech Stack:** Flutter 3.41 / Dart 3.11 / GLSL 4.60 Fragment Shader

---

## ファイル構成

| 操作 | ファイル | 責務 |
|------|---------|------|
| Modify | `lib/interface/shader_pattern.dart` | enum に liquid, kaleidoscope, explosion 追加 |
| Modify | `pubspec.yaml` | 新規シェーダーアセット登録 |
| Create | `shaders/psychedelic_liquid.frag` | 多層domain warpingシェーダー |
| Create | `shaders/psychedelic_kaleidoscope.frag` | 万華鏡+domain warpingシェーダー |
| Create | `shaders/psychedelic_explosion.frag` | 螺旋爆発+fractal distortionシェーダー |
| Modify | `shaders/psychedelic_marble.frag` | UVスケール 3.0→2.0 |
| Modify | `shaders/psychedelic_fractal.frag` | UVスケール 4.0→2.5 |
| Modify | `shaders/psychedelic_plasma.frag` | UV係数を0.6倍に |
| Modify | `lib/interface/shader_config.dart` | minoMusic プリセット追加 |
| Modify | `test/interface/shader_config_test.dart` | 新パターン・プリセットのテスト |

---

## Chunk 1: enum拡張 + テスト

### Task 1: ShaderPattern enum 拡張

**Files:**
- Modify: `lib/interface/shader_pattern.dart`
- Modify: `test/interface/shader_config_test.dart`

- [ ] **Step 1: テスト追加 — パターン数が9であること**

`test/interface/shader_config_test.dart` に追加:

```dart
test('ShaderPatternが9パターン存在する', () {
  expect(ShaderPattern.values.length, 9);
});

test('新規パターンのassetPathが正しい', () {
  expect(
    ShaderPattern.liquid.assetPath,
    'shaders/psychedelic_liquid.frag',
  );
  expect(
    ShaderPattern.kaleidoscope.assetPath,
    'shaders/psychedelic_kaleidoscope.frag',
  );
  expect(
    ShaderPattern.explosion.assetPath,
    'shaders/psychedelic_explosion.frag',
  );
});
```

- [ ] **Step 2: テスト実行 — RED確認**

Run: `mise run test`
Expected: FAIL — `ShaderPattern.liquid` が存在しない

- [ ] **Step 3: enum に3パターン追加**

`lib/interface/shader_pattern.dart`:

```dart
enum ShaderPattern {
  marble('shaders/psychedelic_marble.frag', 'Marble'),
  vortex('shaders/psychedelic_vortex.frag', 'Vortex'),
  ripple('shaders/psychedelic_ripple.frag', 'Ripple'),
  fractal('shaders/psychedelic_fractal.frag', 'Fractal'),
  plasma('shaders/psychedelic_plasma.frag', 'Plasma'),
  sentai('shaders/psychedelic_sentai.frag', 'Sentai'),
  liquid('shaders/psychedelic_liquid.frag', 'Liquid'),
  kaleidoscope('shaders/psychedelic_kaleidoscope.frag', 'Kaleidoscope'),
  explosion('shaders/psychedelic_explosion.frag', 'Explosion');

  const ShaderPattern(this.assetPath, this.label);

  final String assetPath;
  final String label;
}
```

- [ ] **Step 4: テスト実行 — GREEN確認**

Run: `mise run test`
Expected: PASS (ただし「全プリセットがmarble」テストは新パターンがプリセットに入るまで影響なし)

- [ ] **Step 5: コミット**

```bash
git add lib/interface/shader_pattern.dart test/interface/shader_config_test.dart
git commit -m "feat: ShaderPattern enum に liquid, kaleidoscope, explosion を追加"
```

---

## Chunk 2: 新規シェーダー3本 + アセット登録

### Task 2: liquid シェーダー作成

**Files:**
- Create: `shaders/psychedelic_liquid.frag`
- Modify: `pubspec.yaml`

- [ ] **Step 1: psychedelic_liquid.frag 作成**

```glsl
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

  // 多層domain warping（6〜8層）で極端な歪み
  vec2 p = uv * 2.0;
  int iterations = int(uComplexity) + 3; // 最低4層、最大8層
  iterations = min(iterations, 8);

  for (int i = 0; i < 8; i++) {
    if (i >= iterations) break;
    float fi = float(i);
    // 各層で異なる周波数・位相でねじる
    p = vec2(
      sin(p.y * (1.7 + fi * 0.3) + t * (0.4 + fi * 0.1) + fi * 2.1)
        + cos(p.x * (2.1 - fi * 0.2) - t * (0.3 + fi * 0.07)),
      cos(p.x * (1.9 + fi * 0.25) - t * (0.35 + fi * 0.08) + fi * 1.7)
        + sin(p.y * (2.3 - fi * 0.15) + t * (0.5 + fi * 0.06))
    );
  }

  // 鋭いsmoothstep境界で色の重なりを強調
  float band = sin(p.x * 2.0 + p.y * 1.5 + t * 0.2) * 0.5 + 0.5;
  float band2 = cos(p.y * 1.8 - p.x * 2.2 + t * 0.15) * 0.5 + 0.5;

  // 3色に加えて、bandの重なりで6色以上の視覚的バリエーション
  vec3 color = mix(uColor1, uColor2, smoothstep(0.3, 0.35, band));
  color = mix(color, uColor3, smoothstep(0.3, 0.35, band2));
  color = mix(color, uColor1 * 0.5 + uColor3 * 0.5, smoothstep(0.6, 0.65, band * band2));

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}
```

- [ ] **Step 2: pubspec.yaml にアセット登録**

`pubspec.yaml` の `shaders:` セクションに追加:

```yaml
  shaders:
    - shaders/psychedelic_marble.frag
    - shaders/psychedelic_vortex.frag
    - shaders/psychedelic_ripple.frag
    - shaders/psychedelic_fractal.frag
    - shaders/psychedelic_plasma.frag
    - shaders/psychedelic_sentai.frag
    - shaders/psychedelic_liquid.frag
    - shaders/psychedelic_kaleidoscope.frag
    - shaders/psychedelic_explosion.frag
```

### Task 3: kaleidoscope シェーダー作成

**Files:**
- Create: `shaders/psychedelic_kaleidoscope.frag`

- [ ] **Step 1: psychedelic_kaleidoscope.frag 作成**

```glsl
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

  // 中心基準の極座標
  vec2 center = (uv - 0.5) * 2.0;
  float angle = atan(center.y, center.x) + t * 0.3;
  float r = length(center);

  // 万華鏡: 角度をセグメント数で折り返し
  float segments = max(uComplexity * 2.0, 3.0);
  float segAngle = 6.2831853 / segments;
  angle = mod(angle, segAngle);
  // 鏡面反転
  angle = min(angle, segAngle - angle);

  // 折り返した座標にdomain warpingを適用
  vec2 p = vec2(cos(angle), sin(angle)) * r;
  for (int i = 0; i < 5; i++) {
    if (i >= int(uComplexity)) break;
    float fi = float(i);
    p = vec2(
      sin(p.y * 3.1 + t * 0.5 + fi * 1.7) + cos(p.x * 2.7 - t * 0.4),
      cos(p.x * 2.9 - t * 0.6 + fi * 1.3) + sin(p.y * 2.3 + t * 0.35)
    );
  }

  float band = sin(p.x * 2.5 + p.y * 2.0 + t * 0.25) * 0.5 + 0.5;

  vec3 color = mix(uColor1, uColor2, smoothstep(0.0, 0.5, band));
  color = mix(color, uColor3, smoothstep(0.4, 0.9, band));

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}
```

### Task 4: explosion シェーダー作成

**Files:**
- Create: `shaders/psychedelic_explosion.frag`

- [ ] **Step 1: psychedelic_explosion.frag 作成**

```glsl
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

  vec2 center = (uv - 0.5) * 3.0;
  float r = length(center);
  float angle = atan(center.y, center.x);

  // 螺旋波紋: 距離+角度で螺旋を生成
  float spiral = sin(r * 6.0 - angle * 3.0 - t * 2.0) * 0.5 + 0.5;

  // fractal distortion: 座標を反復変換して重畳
  vec2 p = center;
  float distortion = 0.0;
  int iterations = int(uComplexity);
  for (int i = 0; i < 5; i++) {
    if (i >= iterations) break;
    p = abs(p) * 1.5 - 1.0;
    p *= mat2(cos(t * 0.3), sin(t * 0.2),
              -sin(t * 0.2), cos(t * 0.3));
    distortion += sin(length(p) * 4.0 + t) / float(i + 2);
  }

  // 放射パルス: 時間で外側に広がる波
  float pulse = sin(r * 8.0 - t * 3.0) * exp(-r * 0.5);

  float band = (spiral + distortion * 0.4 + pulse * 0.3) * 0.5 + 0.5;
  band = clamp(band, 0.0, 1.0);

  vec3 color = mix(uColor1, uColor2, smoothstep(0.0, 0.5, band));
  color = mix(color, uColor3, smoothstep(0.4, 0.9, band));

  const float noiseScale = 500.0;
  const float noiseBlend = 0.3;
  float noise = hash(uv * noiseScale + t) * 2.0 - 1.0;
  color += noise * uNoiseIntensity * noiseBlend;
  color *= uBrightness;

  fragColor = vec4(color, 1.0);
}
```

- [ ] **Step 2: ビルド確認**

Run: `mise run analyze`
Expected: No issues found

- [ ] **Step 3: コミット**

```bash
git add shaders/psychedelic_liquid.frag shaders/psychedelic_kaleidoscope.frag shaders/psychedelic_explosion.frag pubspec.yaml
git commit -m "feat: liquid, kaleidoscope, explosion シェーダーを追加"
```

---

## Chunk 3: 既存シェーダーのスケール拡大

### Task 5: marble のUVスケール調整

**Files:**
- Modify: `shaders/psychedelic_marble.frag:25`

- [ ] **Step 1: UVスケール変更**

```glsl
// 変更前
vec2 p = uv * 3.0;
// 変更後
vec2 p = uv * 2.0;
```

### Task 6: fractal のUVスケール調整

**Files:**
- Modify: `shaders/psychedelic_fractal.frag:25`

- [ ] **Step 1: UVスケール変更**

```glsl
// 変更前
vec2 p = (uv - 0.5) * 4.0;
// 変更後
vec2 p = (uv - 0.5) * 2.5;
```

### Task 7: plasma のUV係数調整

**Files:**
- Modify: `shaders/psychedelic_plasma.frag:30-32`

- [ ] **Step 1: 周波数係数を0.6倍に**

```glsl
// 変更前
v += sin(uv.x * (3.0 + fi * 2.0) + t * 0.7 + fi);
v += sin(uv.y * (4.0 + fi * 1.5) - t * 0.5 + fi * 0.8);
v += sin((uv.x + uv.y) * (2.0 + fi) + t * 0.6);
// 変更後
v += sin(uv.x * (1.8 + fi * 1.2) + t * 0.7 + fi);
v += sin(uv.y * (2.4 + fi * 0.9) - t * 0.5 + fi * 0.8);
v += sin((uv.x + uv.y) * (1.2 + fi * 0.6) + t * 0.6);
```

- [ ] **Step 2: ビルド確認**

Run: `mise run analyze`
Expected: No issues found

- [ ] **Step 3: コミット**

```bash
git add shaders/psychedelic_marble.frag shaders/psychedelic_fractal.frag shaders/psychedelic_plasma.frag
git commit -m "feat: 既存シェーダーのエフェクトスケールを拡大"
```

---

## Chunk 4: minoMusic プリセット + テスト

### Task 8: minoMusic プリセット追加

**Files:**
- Modify: `lib/interface/shader_config.dart`
- Modify: `test/interface/shader_config_test.dart`

- [ ] **Step 1: テスト追加**

`test/interface/shader_config_test.dart` に追加:

```dart
test('presetsにminoMusicが含まれる', () {
  expect(ShaderConfig.presets.containsKey('minoMusic'), isTrue);
});

test('minoMusicプリセットがliquidパターン', () {
  expect(
    ShaderConfig.presets['minoMusic']!.pattern,
    ShaderPattern.liquid,
  );
});
```

既存テスト修正 — 「全プリセットがmarble」テストを削除し、パターン指定プリセットを許容するテストに変更:

```dart
// 変更前
test('全プリセットがデフォルトpattern(marble)を持つ', () {
  for (final entry in ShaderConfig.presets.entries) {
    expect(
      entry.value.pattern,
      ShaderPattern.marble,
      reason: '${entry.key}プリセットがpatternを上書きしている',
    );
  }
});
// 変更後
test('全プリセットが有効なShaderPatternを持つ', () {
  for (final entry in ShaderConfig.presets.entries) {
    expect(
      ShaderPattern.values.contains(entry.value.pattern),
      isTrue,
      reason: '${entry.key}プリセットのpatternが無効',
    );
  }
});
```

- [ ] **Step 2: テスト実行 — RED確認**

Run: `mise run test`
Expected: FAIL — `minoMusic` が presets に存在しない

- [ ] **Step 3: minoMusic プリセットを追加**

`lib/interface/shader_config.dart` に追加:

```dart
static const minoMusic = ShaderConfig(
  pattern: ShaderPattern.liquid,
  color1: Color(0xFFFF0040),
  color2: Color(0xFF00FF80),
  color3: Color(0xFF4000FF),
  brightness: 1.0,
  noiseIntensity: 0.0,
  speed: 0.8,
  complexity: 5.0,
);
```

presets マップに `'minoMusic': minoMusic` を追加。

- [ ] **Step 4: テスト実行 — GREEN確認**

Run: `mise run test`
Expected: PASS

- [ ] **Step 5: 静的解析**

Run: `mise run analyze`
Expected: No issues found

- [ ] **Step 6: コミット**

```bash
git add lib/interface/shader_config.dart test/interface/shader_config_test.dart
git commit -m "feat: minoMusic プリセットを追加（liquid パターン + 高彩度カラー）"
```

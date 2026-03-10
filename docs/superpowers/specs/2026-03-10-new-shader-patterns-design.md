# 新規シェーダーパターン追加 + スケール拡大

## 目的

既存6パターンに3つの複雑なパターンを追加し、全パターンの歪み・エフェクトスケールを拡大する。
参考: みのミュージックOP映像（極彩色のliquid marble / fluid art風）。

## 新規パターン

### 1. liquid

- **アルゴリズム**: 多層domain warping（6〜8層のsin/cos再帰変換）
- **カラーマッピング**: 3色のsmoothstep境界を鋭くし、色の重なりで6色以上の視覚的バリエーションを生成
- **特徴**: 現marbleの強化版。歪み層を倍以上にし、各層の周波数・位相をずらして不規則性を高める
- **UVスケール**: `uv * 2.0`（大きなうねり）

### 2. kaleidoscope

- **アルゴリズム**: 極座標変換 → 角度をセグメント数で割って鏡面反転 → domain warpingで歪ませる
- **特徴**: 幾何学的な万華鏡パターンだが、domain warpingにより有機的な不規則さが加わる
- **セグメント数**: `uComplexity`で制御（3〜10セグメント）
- **UVスケール**: `(uv - 0.5) * 2.0`（画面中心基準、大スケール）

### 3. explosion

- **アルゴリズム**: 中心からの距離と角度に基づく螺旋波紋 + fractal distortion重畳 + 放射パルス
- **特徴**: 複数の歪み関数（螺旋、fractional brownian motion風ノイズ、放射パルス）を加算合成し、爆発的な渦巻きパターンを生成
- **UVスケール**: `(uv - 0.5) * 3.0`（中心から大きく広がる）

## 既存パターンのスケール拡大

全9パターンのUV座標スケーリング係数を調整し、歪み1要素が画面の大部分を占めるようにする。

| パターン | 現在のUVスケール | 変更後 |
|---------|----------------|--------|
| marble | `uv * 3.0` | `uv * 2.0` |
| vortex | `center`ベース | そのまま（元々大スケール） |
| ripple | `center`ベース | そのまま |
| fractal | `(uv - 0.5) * 4.0` | `(uv - 0.5) * 2.5` |
| plasma | `uv * 各種係数` | 係数を0.6倍に |
| sentai | `center`ベース | そのまま |

## uniform layout

既存と同一（16 floats）。新規3パターンも同じlayoutを使用。

## ファイル変更

| ファイル | 変更内容 |
|---------|---------|
| `lib/interface/shader_pattern.dart` | enum に liquid, kaleidoscope, explosion を追加 |
| `shaders/psychedelic_liquid.frag` | 新規作成 |
| `shaders/psychedelic_kaleidoscope.frag` | 新規作成 |
| `shaders/psychedelic_explosion.frag` | 新規作成 |
| `shaders/psychedelic_marble.frag` | UVスケール調整 |
| `shaders/psychedelic_fractal.frag` | UVスケール調整 |
| `shaders/psychedelic_plasma.frag` | UVスケール調整 |
| `pubspec.yaml` | 新規シェーダーアセット登録 |
| `test/interface/shader_config_test.dart` | 新パターンのテスト追加 |

## プリセット

| プリセット名 | パターン | 色 | 用途 |
|------------|---------|---|------|
| minoMusic | liquid | 高彩度（赤・緑・青系） | みのOP再現 |

## テスト方針

- ShaderPattern enumの値数テスト（9パターン）
- 新パターンのassetPath/label検証
- presetsマップに新プリセット含まれるか
- 全プリセットが有効なpatternを持つか

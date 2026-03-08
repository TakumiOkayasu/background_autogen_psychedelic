# Psychedelic Background Generator

Fragment Shaderで6種のサイケデリックパターン背景をリアルタイム生成するFlutterデモアプリ。

## 機能

- 6種のGPUシェーダーパターン (marble / vortex / ripple / fractal / plasma / sentai)
- 3色カラー制御 + 6プリセット (warm / cool / neon / ocean / fire / pastel)
- パターン・プリセット・速度・複雑度をデバッグオーバーレイからリアルタイム切替
- Web環境でのメモリ表示 (`performance.memory` API)
- バッテリー最適化 (バックグラウンド時Ticker停止、RepaintBoundary)

## セットアップ

```bash
mise install
mise exec -- flutter pub get
```

## 実行

```bash
mise run dev          # macOSデスクトップ
mise run dev:ios      # iOSシミュレータ
mise run dev:android  # Androidエミュレータ
mise run dev:chrome   # Chrome
mise run dev:pick     # デバイス選択
```

VS Codeの場合は `F5` でlaunch.jsonから起動。

## テスト・解析

```bash
mise run test         # 全テスト
mise run analyze      # 静的解析
```

## ゲームへの組み込み

`pubspec.yaml` に git 依存として追加し、`Stack` の最背面に配置するだけで使える。

```yaml
# pubspec.yaml
dependencies:
  psychedelic_bg:
    git:
      url: https://github.com/TakumiOkayasu/background_autogen_psychedelic.git
```

```dart
import 'package:psychedelic_bg/psychedelic_background.dart';

// 1. BackgroundManager を生成
final manager = BackgroundManager();

// 2. ShaderProvider でラップ
ShaderProvider(
  manager: manager,
  child: Stack(
    children: [
      PsychedelicBackgroundWidget(), // 最背面: シェーダー背景
      GameWidget(),                  // ゲーム本体
    ],
  ),
);

// 3. パターン・色を動的に変更
ShaderProvider.updateConfig(context, ShaderConfig.fire);
ShaderProvider.updateConfig(
  context,
  config.copyWith(pattern: ShaderPattern.vortex),
);
```

## アーキテクチャ

```text
Interface層  → ShaderPattern (enum), ShaderConfig (DTO + presets)
Manager層    → BackgroundManager (シェーダーキャッシュ・Ticker・uniform管理)
Provider層   → ShaderProvider (InheritedWidget)
Widget層     → PsychedelicBackgroundWidget + ColorOverlayWidget + DebugOverlayWidget
Shader資産   → psychedelic_*.frag (6種, 同一uniform layout)
```

## 技術スタック

- Flutter 3.29 / Dart 3.7
- Fragment Shader (GLSL 4.60)

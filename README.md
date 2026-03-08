# Psychedelic Background Generator

Fragment Shaderでサイケデリックなマーブル背景をリアルタイム生成するFlutterデモアプリ。

## 機能

- GPU描画によるマーブルアニメーション (domain warping)
- 3色カラー制御 (オレンジ・青・紫)
- カラープリセット (暖色 / 寒色 / ネオン)
- 速度・複雑度スライダー
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
mise run dev:chrome   # Chrome
mise run dev:pick     # デバイス選択
```

VS Codeの場合は `F5` でlaunch.jsonから起動。

## テスト・解析

```bash
mise run test         # 全テスト
mise run analyze      # 静的解析
```

## アーキテクチャ

```text
Interface層  → ShaderConfig (DTO), BackgroundShader (契約)
Manager層    → BackgroundManager (ライフサイクル・Ticker・uniform管理)
Provider層   → ShaderProvider (InheritedWidget)
Widget層     → PsychedelicBackgroundWidget + ColorOverlayWidget
Shader資産   → psychedelic_marble.frag
```

## 技術スタック

- Flutter 3.29 / Dart 3.7
- Fragment Shader (GLSL 4.60)

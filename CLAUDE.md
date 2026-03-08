# Psychedelic Background Generator

## 概要

ゲーム背景をリアルタイム生成するFlutterデモアプリ。Fragment Shaderでサイケデリックなマーブル模様を描画。

## 技術スタック

- Flutter 3.29 / Dart 3.7
- Fragment Shader (GLSL 4.60)

## アーキテクチャ

```
Interface層 → ShaderConfig (DTO), BackgroundShader (契約)
Manager層   → BackgroundManager (ライフサイクル・Ticker・uniform管理)
Provider層  → ShaderProvider (InheritedWidget)
Widget層    → PsychedelicBackgroundWidget + ColorOverlayWidget
```

## テストファイル配置

```text
lib/
├── interface/
├── manager/
├── provider/
└── widget/
test/
├── interface/
│   └── shader_config_test.dart
├── manager/
│   └── background_manager_test.dart
└── widget/
    ├── psychedelic_background_widget_test.dart
    ├── color_overlay_widget_test.dart
    └── debug_overlay_widget_test.dart
```

## コマンド

```bash
mise run dev                    # macOSデスクトップ実行
mise run dev:ios                # iOSシミュレータ実行
mise run dev:android            # Androidエミュレータ実行
mise run dev:chrome             # Chrome実行
mise run dev:pick               # デバイス選択実行
mise run test                   # テスト実行
mise run analyze                # 静的解析
```

## テスト実行時の注意

Docker環境でテスト実行後にローカルで `mise run test` を実行すると、`.dart_tool/package_config.json` にDockerイメージ内のパス (`/sdks/flutter/`) がキャッシュされてコンパイルエラーになる場合がある。

```bash
# 対処法
mise exec -- flutter clean && mise exec -- flutter pub get
# その後
mise run test
```

## Available Commands

- `/commit` - コミットメッセージ生成
- `/code-review` - コードレビュー
- `/implement` - TDD実装ガイド

## ルール

- TDD必須 (RED→GREEN→REFACTOR)
- 依存はピラミッド型 (上位→下位のみ)
- 1ブランチ = 1機能

## Constraints

- 大きな変更は一度に行わない、段階的に進める
- 不明点があれば実装前に確認する
- 既存のコードスタイルを尊重する
- Dart の最新安定版を前提とする

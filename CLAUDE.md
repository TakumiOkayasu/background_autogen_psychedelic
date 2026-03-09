# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

ゲーム背景をリアルタイム生成するFlutterデモアプリ。Fragment Shaderで6種のサイケデリックパターンを描画し、デバッグオーバーレイからリアルタイムに切替可能。

## 技術スタック

- Flutter 3.41 / Dart 3.11
- Fragment Shader (GLSL 4.60) — 全6シェーダーが同一uniform layout (14 floats)

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

## アーキテクチャ

依存はピラミッド型 (上位→下位のみ)。横参照・段階飛ばし禁止。

```
Interface層 → ShaderPattern (enum), ShaderConfig (DTO + presets)
Manager層   → BackgroundManager (シェーダーキャッシュ・Ticker・uniform管理)
Provider層  → ShaderProvider (InheritedWidget, Widget向けファサード)
Widget層    → PsychedelicBackgroundWidget, ColorOverlayWidget, DebugOverlayWidget
```

### データフロー

1. `BackgroundManager.load()` で全6シェーダーを並列ロード → `Map<ShaderPattern, FragmentProgram>` にキャッシュ
2. `ShaderConfig.pattern` でアクティブパターンを指定 → `createShader()` が対応プログラムからシェーダー生成
3. `ShaderProvider` がWidget層に `configOf` / `patternOf` / `updateConfig` を公開
4. `DebugOverlayWidget` のドロップダウンでパターン・プリセットをリアルタイム切替

### シェーダー (同一uniform layout)

| パターン | アルゴリズム |
|---------|------------|
| marble | domain warping |
| vortex | 極座標ねじり |
| ripple | 同心円波合成 |
| fractal | 反復座標変換 |
| plasma | sin波加算合成 |
| sentai | 放射状セグメント |

### メモリ表示 (conditional import)

`memory_info_stub.dart` → `memory_info_io.dart` (native) / `memory_info_web.dart` (web, `dart:js_interop`)

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

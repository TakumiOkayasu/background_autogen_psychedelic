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

## コマンド
```bash
flutter test                    # テスト実行
flutter analyze                 # 静的解析
flutter run                     # 実機/シミュレータ実行
```

## ルール
- TDD必須 (RED→GREEN→REFACTOR)
- 依存はピラミッド型 (上位→下位のみ)
- 1ブランチ = 1機能

import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/manager/background_manager.dart';

class ShaderProvider extends InheritedNotifier<BackgroundManager> {
  const ShaderProvider({
    super.key,
    required BackgroundManager manager,
    required super.child,
  }) : super(notifier: manager);

  /// 依存登録あり — リビルドが必要なAPI用
  static BackgroundManager of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ShaderProvider>();
    assert(provider != null, 'ShaderProvider not found in widget tree');
    return provider!.notifier!;
  }

  /// 依存登録なし — 副作用系API用
  static BackgroundManager _read(BuildContext context) {
    final provider =
        context.getInheritedWidgetOfExactType<ShaderProvider>();
    assert(provider != null, 'ShaderProvider not found in widget tree');
    return provider!.notifier!;
  }

  // -- Widget層向けAPI (段階飛ばし防止) --

  // リビルド必要（値の読み取り）
  static bool isReady(BuildContext context) => of(context).isReady;
  static ShaderConfig configOf(BuildContext context) => of(context).config;
  static Listenable listenableOf(BuildContext context) => of(context);

  // リビルド不要（副作用のみ）
  static void updateConfig(BuildContext context, ShaderConfig value) {
    _read(context).config = value;
  }

  static ui.Shader? createShader(BuildContext context, ui.Size size) {
    final manager = _read(context);
    if (!manager.isReady) return null;
    return manager.createShader(size);
  }

  static void startTicker(BuildContext context, TickerProvider provider) {
    _read(context).startTicker(provider);
  }

  static void stopTicker(BuildContext context) {
    _read(context).stopTicker();
  }

  static void loadShader(BuildContext context) {
    _read(context).load();
  }

  static void addListener(BuildContext context, VoidCallback listener) {
    _read(context).addListener(listener);
  }

  static void removeListener(BuildContext context, VoidCallback listener) {
    _read(context).removeListener(listener);
  }

  static double elapsedSecondsOf(BuildContext context) =>
      of(context).elapsedSeconds;
}

import 'package:flutter/widgets.dart';

import 'package:psychedelic_bg/manager/background_manager.dart';

class ShaderProvider extends InheritedNotifier<BackgroundManager> {
  const ShaderProvider({
    super.key,
    required BackgroundManager manager,
    required super.child,
  }) : super(notifier: manager);

  static BackgroundManager of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ShaderProvider>();
    assert(provider != null, 'ShaderProvider not found in widget tree');
    return provider!.notifier!;
  }

  static BackgroundManager? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ShaderProvider>()
        ?.notifier;
  }
}

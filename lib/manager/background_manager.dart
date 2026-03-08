import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:psychedelic_bg/interface/shader_config.dart';

class BackgroundManager extends ChangeNotifier {
  ShaderConfig _config;
  bool _isPaused = false;
  double _elapsedSeconds = 0.0;
  Ticker? _ticker;

  BackgroundManager({ShaderConfig config = const ShaderConfig()})
      : _config = config;

  bool get isReady => false;

  ShaderConfig get config => _config;

  set config(ShaderConfig value) {
    if (_config == value) return;
    _config = value;
    notifyListeners();
  }

  bool get isPaused => _isPaused;

  double get elapsedSeconds => _elapsedSeconds;

  void pause() {
    _isPaused = true;
    _ticker?.muted = true;
  }

  void resume() {
    _isPaused = false;
    _ticker?.muted = false;
  }

  void startTicker(TickerProvider provider) {
    _ticker?.dispose();
    _ticker = provider.createTicker(_onTick);
    _ticker!.start();
  }

  void _onTick(Duration elapsed) {
    _elapsedSeconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _ticker = null;
    super.dispose();
  }
}

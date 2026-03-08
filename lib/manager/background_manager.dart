import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:psychedelic_bg/interface/shader_config.dart';

const String _shaderAssetPath = 'shaders/psychedelic_marble.frag';

class BackgroundManager extends ChangeNotifier {
  ShaderConfig _config;
  bool _isPaused = false;
  double _elapsedSeconds = 0.0;
  Ticker? _ticker;
  ui.FragmentProgram? _program;

  BackgroundManager({ShaderConfig config = const ShaderConfig()})
      : _config = config;

  bool get isReady => _program != null;

  ShaderConfig get config => _config;

  set config(ShaderConfig value) {
    if (_config == value) return;
    _config = value;
    notifyListeners();
  }

  bool get isPaused => _isPaused;

  double get elapsedSeconds => _elapsedSeconds;

  Future<void> load() async {
    _program = await ui.FragmentProgram.fromAsset(_shaderAssetPath);
    notifyListeners();
  }

  ui.Shader createShader(ui.Size size) {
    assert(_program != null, 'load() must be called before createShader()');
    final shader = _program!.fragmentShader();

    // uSize (vec2)
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // uTime
    shader.setFloat(2, _elapsedSeconds);

    // uColor1 (vec3)
    shader.setFloat(3, _config.color1.r);
    shader.setFloat(4, _config.color1.g);
    shader.setFloat(5, _config.color1.b);

    // uColor2 (vec3)
    shader.setFloat(6, _config.color2.r);
    shader.setFloat(7, _config.color2.g);
    shader.setFloat(8, _config.color2.b);

    // uColor3 (vec3)
    shader.setFloat(9, _config.color3.r);
    shader.setFloat(10, _config.color3.g);
    shader.setFloat(11, _config.color3.b);

    // uSpeed
    shader.setFloat(12, _config.speed);

    // uComplexity
    shader.setFloat(13, _config.complexity);

    return shader;
  }

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

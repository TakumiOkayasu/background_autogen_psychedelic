import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/interface/shader_pattern.dart';

// Uniform float indices (must match all psychedelic_*.frag layouts)
const int _uSizeX = 0;
const int _uSizeY = 1;
const int _uTime = 2;
const int _uColor1R = 3;
const int _uColor1G = 4;
const int _uColor1B = 5;
const int _uColor2R = 6;
const int _uColor2G = 7;
const int _uColor2B = 8;
const int _uColor3R = 9;
const int _uColor3G = 10;
const int _uColor3B = 11;
const int _uSpeed = 12;
const int _uComplexity = 13;

/// Uniform総数（最後のindex + 1）
const int uniformCount = _uComplexity + 1;

/// 1 uniform = 1 float = 4 bytes
const int bytesPerFloat = 4;

class BackgroundManager extends ChangeNotifier {
  // -- Config management --
  ShaderConfig _config;

  // -- Shader resource management --
  final Map<ShaderPattern, ui.FragmentProgram> _programs = {};
  ui.FragmentShader? _shader;
  ShaderPattern? _activePattern;

  // -- Ticker / lifecycle management --
  bool _isPaused = false;
  double _elapsedSeconds = 0.0;
  Ticker? _ticker;

  BackgroundManager({ShaderConfig config = const ShaderConfig()})
      : _config = config;

  // -- Config management --

  ShaderConfig get config => _config;

  set config(ShaderConfig value) {
    if (_config == value) return;
    final patternChanged = _config.pattern != value.pattern;
    _config = value;
    if (patternChanged) {
      _shader?.dispose();
      _shader = null;
      _activePattern = null;
    }
    notifyListeners();
  }

  // -- Shader resource management --

  bool get isReady => _programs.isNotEmpty;

  Future<void> load() async {
    final results = await Future.wait(
      ShaderPattern.values.map(
        (p) => ui.FragmentProgram.fromAsset(p.assetPath),
      ),
    );
    for (var i = 0; i < ShaderPattern.values.length; i++) {
      _programs[ShaderPattern.values[i]] = results[i];
    }
    notifyListeners();
  }

  ui.Shader createShader(ui.Size size) {
    final pattern = _config.pattern;
    assert(_programs.containsKey(pattern),
        'load() must be called before createShader()');
    if (_activePattern != pattern) {
      _shader?.dispose();
      _shader = null;
      _activePattern = pattern;
    }
    _shader ??= _programs[pattern]!.fragmentShader();
    final shader = _shader!;

    shader.setFloat(_uSizeX, size.width);
    shader.setFloat(_uSizeY, size.height);
    shader.setFloat(_uTime, _elapsedSeconds);
    shader.setFloat(_uColor1R, _config.color1.r);
    shader.setFloat(_uColor1G, _config.color1.g);
    shader.setFloat(_uColor1B, _config.color1.b);
    shader.setFloat(_uColor2R, _config.color2.r);
    shader.setFloat(_uColor2G, _config.color2.g);
    shader.setFloat(_uColor2B, _config.color2.b);
    shader.setFloat(_uColor3R, _config.color3.r);
    shader.setFloat(_uColor3G, _config.color3.g);
    shader.setFloat(_uColor3B, _config.color3.b);
    shader.setFloat(_uSpeed, _config.speed);
    shader.setFloat(_uComplexity, _config.complexity);

    return shader;
  }

  // -- Ticker / lifecycle management --

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

  void stopTicker() {
    _ticker?.dispose();
    _ticker = null;
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

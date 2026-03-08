import 'dart:ui';

import 'package:psychedelic_bg/interface/shader_config.dart';

abstract class BackgroundShader {
  bool get isReady;
  ShaderConfig get config;
  set config(ShaderConfig value);

  Future<void> load();
  void updateTime(double elapsedSeconds);
  Shader createShader(Size size);
  void dispose();
}

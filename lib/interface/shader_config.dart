import 'dart:ui';

import 'package:psychedelic_bg/interface/shader_pattern.dart';

class ShaderConfig {
  final ShaderPattern pattern;
  final Color color1;
  final Color color2;
  final Color color3;
  final double speed;
  final double complexity;
  final double brightness;
  final double noiseIntensity;

  static const double minSpeed = 0.1;
  static const double maxSpeed = 3.0;
  static const double defaultSpeed = 1.0;
  static const double minComplexity = 1.0;
  static const double maxComplexity = 5.0;
  static const double defaultComplexity = 3.0;
  static const double minBrightness = 0.0;
  static const double maxBrightness = 1.0;
  static const double defaultBrightness = 1.0;
  static const double minNoiseIntensity = 0.0;
  static const double maxNoiseIntensity = 1.0;
  static const double defaultNoiseIntensity = 0.0;

  static const Color defaultColor1 = Color(0xFFFF6B35);
  static const Color defaultColor2 = Color(0xFF3366FF);
  static const Color defaultColor3 = Color(0xFF9933FF);

  const ShaderConfig({
    this.pattern = ShaderPattern.marble,
    this.color1 = defaultColor1,
    this.color2 = defaultColor2,
    this.color3 = defaultColor3,
    double speed = defaultSpeed,
    double complexity = defaultComplexity,
    double brightness = defaultBrightness,
    double noiseIntensity = defaultNoiseIntensity,
  })  : speed = speed < minSpeed ? minSpeed : (speed > maxSpeed ? maxSpeed : speed),
        complexity = complexity < minComplexity ? minComplexity : (complexity > maxComplexity ? maxComplexity : complexity),
        brightness = brightness < minBrightness ? minBrightness : (brightness > maxBrightness ? maxBrightness : brightness),
        noiseIntensity = noiseIntensity < minNoiseIntensity ? minNoiseIntensity : (noiseIntensity > maxNoiseIntensity ? maxNoiseIntensity : noiseIntensity);

  // -- Presets --

  static const warm = ShaderConfig(
    color1: defaultColor1,
    color2: Color(0xFFFF3366),
    color3: Color(0xFFFFAA00),
  );

  static const cool = ShaderConfig(
    color1: Color(0xFF0066FF),
    color2: Color(0xFF00CCCC),
    color3: Color(0xFF6633FF),
  );

  static const neon = ShaderConfig(
    color1: Color(0xFFFF00FF),
    color2: Color(0xFF00FF66),
    color3: Color(0xFFFFFF00),
  );

  static const ocean = ShaderConfig(
    color1: Color(0xFF006994),
    color2: Color(0xFF00CED1),
    color3: Color(0xFF40E0D0),
  );

  static const fire = ShaderConfig(
    color1: Color(0xFFFF4500),
    color2: Color(0xFFFF8C00),
    color3: Color(0xFFFFD700),
    speed: 1.5,
  );

  static const pastel = ShaderConfig(
    color1: Color(0xFFFFB3BA),
    color2: Color(0xFFBAE1FF),
    color3: Color(0xFFBAFFBA),
    speed: 0.5,
  );

  static const dark = ShaderConfig(
    color1: Color(0xFF0A1A20),
    color2: Color(0xFF1A3040),
    color3: Color(0xFF0D0D0D),
    brightness: 0.4,
    noiseIntensity: 0.3,
  );

  static const ultraQ = ShaderConfig(
    pattern: ShaderPattern.marble,
    color1: Color(0xFF0A1A1A),
    color2: Color(0xFF1A3A3A),
    color3: Color(0xFF2D5A5A),
    brightness: 0.5,
    noiseIntensity: 0.4,
    speed: 0.5,
  );

  static const minoMusic = ShaderConfig(
    pattern: ShaderPattern.liquid,
    color1: Color(0xFFFF0040),
    color2: Color(0xFF00FF80),
    color3: Color(0xFF4000FF),
    speed: 0.8,
    complexity: 5.0,
  );

  // -- Presets Map --

  static const Map<String, ShaderConfig> presets = {
    'warm': warm,
    'cool': cool,
    'neon': neon,
    'ocean': ocean,
    'fire': fire,
    'pastel': pastel,
    'dark': dark,
    'ultraQ': ultraQ,
    'minoMusic': minoMusic,
  };

  ShaderConfig copyWith({
    ShaderPattern? pattern,
    Color? color1,
    Color? color2,
    Color? color3,
    double? speed,
    double? complexity,
    double? brightness,
    double? noiseIntensity,
  }) {
    return ShaderConfig(
      pattern: pattern ?? this.pattern,
      color1: color1 ?? this.color1,
      color2: color2 ?? this.color2,
      color3: color3 ?? this.color3,
      speed: speed ?? this.speed,
      complexity: complexity ?? this.complexity,
      brightness: brightness ?? this.brightness,
      noiseIntensity: noiseIntensity ?? this.noiseIntensity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShaderConfig &&
        other.pattern == pattern &&
        other.color1 == color1 &&
        other.color2 == color2 &&
        other.color3 == color3 &&
        other.speed == speed &&
        other.complexity == complexity &&
        other.brightness == brightness &&
        other.noiseIntensity == noiseIntensity;
  }

  @override
  int get hashCode =>
      Object.hash(
        pattern,
        color1,
        color2,
        color3,
        speed,
        complexity,
        brightness,
        noiseIntensity,
      );
}

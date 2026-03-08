import 'dart:ui';

class ShaderConfig {
  final Color color1;
  final Color color2;
  final Color color3;
  final double speed;
  final double complexity;

  const ShaderConfig({
    this.color1 = const Color(0xFFFF6B35),
    this.color2 = const Color(0xFF3366FF),
    this.color3 = const Color(0xFF9933FF),
    double speed = 1.0,
    double complexity = 3.0,
  })  : speed = speed < 0.1
            ? 0.1
            : speed > 3.0
                ? 3.0
                : speed,
        complexity = complexity < 1.0
            ? 1.0
            : complexity > 5.0
                ? 5.0
                : complexity;

  ShaderConfig copyWith({
    Color? color1,
    Color? color2,
    Color? color3,
    double? speed,
    double? complexity,
  }) {
    return ShaderConfig(
      color1: color1 ?? this.color1,
      color2: color2 ?? this.color2,
      color3: color3 ?? this.color3,
      speed: speed ?? this.speed,
      complexity: complexity ?? this.complexity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShaderConfig &&
        other.color1 == color1 &&
        other.color2 == color2 &&
        other.color3 == color3 &&
        other.speed == speed &&
        other.complexity == complexity;
  }

  @override
  int get hashCode => Object.hash(color1, color2, color3, speed, complexity);
}

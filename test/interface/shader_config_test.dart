import 'package:flutter_test/flutter_test.dart';
import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/interface/shader_pattern.dart';

void main() {
  group('ShaderConfig', () {
    test('デフォルト値が正しい', () {
      const config = ShaderConfig();

      expect(config.color1, ShaderConfig.defaultColor1);
      expect(config.color2, ShaderConfig.defaultColor2);
      expect(config.color3, ShaderConfig.defaultColor3);
      expect(config.speed, ShaderConfig.defaultSpeed);
      expect(config.complexity, ShaderConfig.defaultComplexity);
    });

    test('copyWithで部分更新できる', () {
      const config = ShaderConfig();
      final updated = config.copyWith(
        color1: ShaderConfig.defaultColor2,
        speed: 2.0,
      );

      expect(updated.color1, ShaderConfig.defaultColor2);
      expect(updated.color2, ShaderConfig.defaultColor2);
      expect(updated.speed, 2.0);
      expect(updated.complexity, ShaderConfig.defaultComplexity);
    });

    test('speedが範囲にクランプされる', () {
      const tooLow = ShaderConfig(speed: 0.0);
      const tooHigh = ShaderConfig(speed: 5.0);

      expect(tooLow.speed, ShaderConfig.minSpeed);
      expect(tooHigh.speed, ShaderConfig.maxSpeed);
    });

    test('complexityが範囲にクランプされる', () {
      const tooLow = ShaderConfig(complexity: 0.0);
      const tooHigh = ShaderConfig(complexity: 10.0);

      expect(tooLow.complexity, ShaderConfig.minComplexity);
      expect(tooHigh.complexity, ShaderConfig.maxComplexity);
    });

    test('同じ値のインスタンスはequalになる', () {
      const a = ShaderConfig();
      const b = ShaderConfig();

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('異なる値のインスタンスはequalにならない', () {
      const a = ShaderConfig();
      const b = ShaderConfig(speed: 2.0);

      expect(a, isNot(equals(b)));
    });

    test('デフォルトのpatternがmarble', () {
      const config = ShaderConfig();
      expect(config.pattern, ShaderPattern.marble);
    });

    test('patternをcopyWithで変更できる', () {
      const config = ShaderConfig();
      final updated = config.copyWith(pattern: ShaderPattern.vortex);
      expect(updated.pattern, ShaderPattern.vortex);
    });

    test('pattern違いはequalにならない', () {
      const a = ShaderConfig();
      const b = ShaderConfig(pattern: ShaderPattern.plasma);
      expect(a, isNot(equals(b)));
    });

    test('presetsマップが存在し空でない', () {
      expect(ShaderConfig.presets.isNotEmpty, isTrue);
    });

    test('presetsにwarm/cool/neonが含まれる', () {
      expect(ShaderConfig.presets.containsKey('warm'), isTrue);
      expect(ShaderConfig.presets.containsKey('cool'), isTrue);
      expect(ShaderConfig.presets.containsKey('neon'), isTrue);
    });

    test('全プリセットがデフォルトpattern(marble)を持つ', () {
      for (final entry in ShaderConfig.presets.entries) {
        expect(
          entry.value.pattern,
          ShaderPattern.marble,
          reason: '${entry.key}プリセットがpatternを上書きしている',
        );
      }
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychedelic_bg/interface/shader_config.dart';

void main() {
  group('ShaderConfig', () {
    test('デフォルト値が正しい', () {
      const config = ShaderConfig();

      expect(config.color1, const Color(0xFFFF6B35));
      expect(config.color2, const Color(0xFF3366FF));
      expect(config.color3, const Color(0xFF9933FF));
      expect(config.speed, 1.0);
      expect(config.complexity, 3.0);
    });

    test('copyWithで部分更新できる', () {
      const config = ShaderConfig();
      final updated = config.copyWith(
        color1: const Color(0xFFFF0000),
        speed: 2.0,
      );

      expect(updated.color1, const Color(0xFFFF0000));
      expect(updated.color2, const Color(0xFF3366FF));
      expect(updated.speed, 2.0);
      expect(updated.complexity, 3.0);
    });

    test('speedが範囲[0.1, 3.0]にクランプされる', () {
      const tooLow = ShaderConfig(speed: 0.0);
      const tooHigh = ShaderConfig(speed: 5.0);

      expect(tooLow.speed, 0.1);
      expect(tooHigh.speed, 3.0);
    });

    test('complexityが範囲[1.0, 5.0]にクランプされる', () {
      const tooLow = ShaderConfig(complexity: 0.0);
      const tooHigh = ShaderConfig(complexity: 10.0);

      expect(tooLow.complexity, 1.0);
      expect(tooHigh.complexity, 5.0);
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
  });
}

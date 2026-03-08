import 'package:flutter_test/flutter_test.dart';
import 'package:psychedelic_bg/interface/shader_pattern.dart';

void main() {
  group('ShaderPattern', () {
    test('6つのパターンが定義されている', () {
      expect(ShaderPattern.values.length, 6);
    });

    test('各パターンのassetPathが正しい', () {
      expect(
        ShaderPattern.marble.assetPath,
        'shaders/psychedelic_marble.frag',
      );
      expect(
        ShaderPattern.vortex.assetPath,
        'shaders/psychedelic_vortex.frag',
      );
      expect(
        ShaderPattern.ripple.assetPath,
        'shaders/psychedelic_ripple.frag',
      );
      expect(
        ShaderPattern.fractal.assetPath,
        'shaders/psychedelic_fractal.frag',
      );
      expect(
        ShaderPattern.plasma.assetPath,
        'shaders/psychedelic_plasma.frag',
      );
      expect(
        ShaderPattern.sentai.assetPath,
        'shaders/psychedelic_sentai.frag',
      );
    });

    test('各パターンのlabelが空でない', () {
      for (final pattern in ShaderPattern.values) {
        expect(pattern.label.isNotEmpty, isTrue);
      }
    });
  });
}

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

    test('全プリセットが有効なShaderPatternを持つ', () {
      for (final entry in ShaderConfig.presets.entries) {
        expect(
          ShaderPattern.values.contains(entry.value.pattern),
          isTrue,
          reason: '${entry.key}プリセットが無効なpatternを持っている',
        );
      }
    });

    group('ShaderPattern enum', () {
      test('12パターンが定義されている', () {
        expect(ShaderPattern.values.length, 12);
      });

      test('全パターンのassetPathが規則に従う', () {
        for (final p in ShaderPattern.values) {
          expect(p.assetPath, 'shaders/psychedelic_${p.name}.frag');
        }
      });

      test('全パターンのlabelがnameの先頭大文字', () {
        for (final p in ShaderPattern.values) {
          expect(p.label, p.name[0].toUpperCase() + p.name.substring(1));
        }
      });
    });

    group('minoMusicプリセット', () {
      test('presetsにminoMusicが含まれる', () {
        expect(ShaderConfig.presets.containsKey('minoMusic'), isTrue);
      });

      test('minoMusicプリセットのpatternがliquid', () {
        expect(ShaderConfig.presets['minoMusic']!.pattern,
            ShaderPattern.liquid);
      });
    });

    group('brightness', () {
      test('デフォルト値が1.0', () {
        const config = ShaderConfig();
        expect(config.brightness, 1.0);
      });

      test('範囲にクランプされる', () {
        const tooLow = ShaderConfig(brightness: -0.5);
        const tooHigh = ShaderConfig(brightness: 2.0);

        expect(tooLow.brightness, ShaderConfig.minBrightness);
        expect(tooHigh.brightness, ShaderConfig.maxBrightness);
      });

      test('copyWithで変更できる', () {
        const config = ShaderConfig();
        final updated = config.copyWith(brightness: 0.5);
        expect(updated.brightness, 0.5);
      });

      test('brightness違いはequalにならない', () {
        const a = ShaderConfig();
        const b = ShaderConfig(brightness: 0.5);
        expect(a, isNot(equals(b)));
      });
    });

    group('noiseIntensity', () {
      test('デフォルト値が0.0', () {
        const config = ShaderConfig();
        expect(config.noiseIntensity, 0.0);
      });

      test('範囲にクランプされる', () {
        const tooLow = ShaderConfig(noiseIntensity: -0.5);
        const tooHigh = ShaderConfig(noiseIntensity: 2.0);

        expect(tooLow.noiseIntensity, ShaderConfig.minNoiseIntensity);
        expect(tooHigh.noiseIntensity, ShaderConfig.maxNoiseIntensity);
      });

      test('copyWithで変更できる', () {
        const config = ShaderConfig();
        final updated = config.copyWith(noiseIntensity: 0.7);
        expect(updated.noiseIntensity, 0.7);
      });

      test('noiseIntensity違いはequalにならない', () {
        const a = ShaderConfig();
        const b = ShaderConfig(noiseIntensity: 0.5);
        expect(a, isNot(equals(b)));
      });
    });

    group('dark/ultraQプリセット', () {
      test('presetsにdarkが含まれる', () {
        expect(ShaderConfig.presets.containsKey('dark'), isTrue);
      });

      test('presetsにultraQが含まれる', () {
        expect(ShaderConfig.presets.containsKey('ultraQ'), isTrue);
      });

      test('darkプリセットのbrightnessが1.0未満', () {
        expect(ShaderConfig.presets['dark']!.brightness, lessThan(1.0));
      });

      test('ultraQプリセットのnoiseIntensityが0.0より大きい', () {
        expect(
          ShaderConfig.presets['ultraQ']!.noiseIntensity,
          greaterThan(0.0),
        );
      });
    });
  });
}

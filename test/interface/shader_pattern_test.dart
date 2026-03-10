import 'package:flutter_test/flutter_test.dart';
import 'package:psychedelic_bg/interface/shader_pattern.dart';

void main() {
  group('ShaderPattern', () {
    test('12のパターンが定義されている', () {
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
}

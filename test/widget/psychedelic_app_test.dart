import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychedelic_bg/main.dart';

void main() {
  group('PsychedelicApp', () {
    testWidgets('横画面に固定される', (tester) async {
      final List<String> orientations = [];

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'SystemChrome.setPreferredOrientations') {
            orientations.addAll(
              (call.arguments as List<dynamic>).cast<String>(),
            );
          }
          return null;
        },
      );

      await tester.pumpWidget(const PsychedelicApp());

      expect(orientations, contains('DeviceOrientation.landscapeLeft'));
      expect(orientations, contains('DeviceOrientation.landscapeRight'));
      expect(
        orientations,
        isNot(contains('DeviceOrientation.portraitUp')),
      );
      expect(
        orientations,
        isNot(contains('DeviceOrientation.portraitDown')),
      );
    });
  });
}

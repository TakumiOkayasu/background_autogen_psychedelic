import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/manager/background_manager.dart';
import 'package:psychedelic_bg/provider/shader_provider.dart';
import 'package:psychedelic_bg/widget/color_overlay_widget.dart';

void main() {
  group('ColorOverlayWidget', () {
    late BackgroundManager manager;

    setUp(() {
      manager = BackgroundManager();
    });

    tearDown(() {
      manager.dispose();
    });

    Widget buildTestWidget() {
      return MaterialApp(
        home: ShaderProvider(
          manager: manager,
          child: const Scaffold(
            body: ColorOverlayWidget(),
          ),
        ),
      );
    }

    testWidgets('トグルボタンでパネルが表示/非表示になる', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(Slider), findsNothing);

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('プリセットボタンが表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.text('暖色'), findsOneWidget);
      expect(find.text('寒色'), findsOneWidget);
      expect(find.text('ネオン'), findsOneWidget);
    });

    testWidgets('プリセット選択でconfigが変わる', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      final originalConfig = manager.config;
      await tester.tap(find.text('寒色'));
      await tester.pumpAndSettle();

      expect(manager.config, isNot(equals(originalConfig)));
    });

    testWidgets('速度スライダーでspeedが変わる', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      final speedSlider = find.byWidgetPredicate(
        (w) =>
            w is Slider &&
            w.value == ShaderConfig.defaultSpeed &&
            w.min == ShaderConfig.minSpeed &&
            w.max == ShaderConfig.maxSpeed,
      );
      expect(speedSlider, findsOneWidget);
    });
  });
}

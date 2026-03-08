import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychedelic_bg/manager/background_manager.dart';
import 'package:psychedelic_bg/provider/shader_provider.dart';
import 'package:psychedelic_bg/widget/color_overlay_widget.dart';

void main() {
  group('ColorOverlayWidget', () {
    late BackgroundManager manager;

    setUp(() {
      manager = BackgroundManager();
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

      // 初期状態: パネル非表示
      expect(find.byType(Slider), findsNothing);

      // トグルボタンをタップ
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      // パネル表示: スライダーが存在
      expect(find.byType(Slider), findsWidgets);

      manager.dispose();
    });

    testWidgets('プリセットボタンが表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      // プリセット名が存在する
      expect(find.text('暖色'), findsOneWidget);
      expect(find.text('寒色'), findsOneWidget);
      expect(find.text('ネオン'), findsOneWidget);

      manager.dispose();
    });

    testWidgets('プリセット選択でconfigが変わる', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      final originalConfig = manager.config;
      await tester.tap(find.text('寒色'));
      await tester.pumpAndSettle();

      expect(manager.config, isNot(equals(originalConfig)));

      manager.dispose();
    });

    testWidgets('速度スライダーでspeedが変わる', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      // 「速度」ラベルのスライダーを探す
      final speedSlider = find.byWidgetPredicate(
        (w) => w is Slider && w.value == 1.0 && w.min == 0.1 && w.max == 3.0,
      );
      expect(speedSlider, findsOneWidget);

      manager.dispose();
    });
  });
}

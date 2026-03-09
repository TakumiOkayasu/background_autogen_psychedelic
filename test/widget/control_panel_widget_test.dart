import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/interface/shader_pattern.dart';
import 'package:psychedelic_bg/manager/background_manager.dart';
import 'package:psychedelic_bg/provider/shader_provider.dart';
import 'package:psychedelic_bg/widget/control_panel_widget.dart';

void main() {
  group('ControlPanelWidget', () {
    late BackgroundManager manager;

    setUp(() {
      manager = BackgroundManager();
    });

    tearDown(() {
      manager.dispose();
    });

    Widget buildTestWidget({Size size = const Size(800, 400)}) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: ShaderProvider(
            manager: manager,
            child: const Scaffold(
              body: ControlPanelWidget(),
            ),
          ),
        ),
      );
    }

    testWidgets('FABでパネルが表示/非表示になる', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(Slider), findsNothing);

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsWidgets);

      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsNothing);
    });

    testWidgets('パターンドロップダウンが表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(
        find.byType(DropdownButton<ShaderPattern>),
        findsOneWidget,
      );
    });

    testWidgets('パターン変更でconfigが更新される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<ShaderPattern>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Vortex').last);
      await tester.pumpAndSettle();

      expect(manager.config.pattern, ShaderPattern.vortex);
    });

    testWidgets('全6プリセットがActionChipで表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      for (final name in ShaderConfig.presets.keys) {
        expect(find.widgetWithText(ActionChip, name), findsOneWidget);
      }
    });

    testWidgets('プリセット選択で全パラメータが上書きされる', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ActionChip, 'ocean'));
      await tester.pumpAndSettle();

      expect(manager.config, ShaderConfig.ocean);
    });

    testWidgets('Speedスライダーが表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      final speedSlider = find.byWidgetPredicate(
        (w) =>
            w is Slider &&
            w.min == ShaderConfig.minSpeed &&
            w.max == ShaderConfig.maxSpeed,
      );
      expect(speedSlider, findsOneWidget);
    });

    testWidgets('Complexityスライダーが表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      final complexitySlider = find.byWidgetPredicate(
        (w) =>
            w is Slider &&
            w.min == ShaderConfig.minComplexity &&
            w.max == ShaderConfig.maxComplexity,
      );
      expect(complexitySlider, findsOneWidget);
    });

    testWidgets('3つのカラーインジケータが表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      expect(find.text('Color 1'), findsOneWidget);
      expect(find.text('Color 2'), findsOneWidget);
      expect(find.text('Color 3'), findsOneWidget);
    });

    testWidgets('カラーインジケータがconfigの色を反映する', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.tune));
      await tester.pumpAndSettle();

      final indicators = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      );

      final colors = indicators
          .map((c) => (c.decoration as BoxDecoration?)?.color)
          .toList();
      expect(colors, contains(ShaderConfig.defaultColor1));
      expect(colors, contains(ShaderConfig.defaultColor2));
      expect(colors, contains(ShaderConfig.defaultColor3));
    });

    testWidgets('右下に配置される', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final aligns = tester
          .widgetList<Align>(
            find.ancestor(
              of: find.byIcon(Icons.tune),
              matching: find.byType(Align),
            ),
          )
          .where((a) => a.alignment == Alignment.bottomRight);
      expect(aligns, isNotEmpty);
    });
  });
}

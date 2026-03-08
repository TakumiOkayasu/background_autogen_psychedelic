import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/manager/background_manager.dart';
import 'package:psychedelic_bg/provider/shader_provider.dart';
import 'package:psychedelic_bg/widget/debug_overlay_widget.dart';

void main() {
  group('DebugOverlayWidget', () {
    late BackgroundManager manager;

    setUp(() {
      manager = BackgroundManager();
    });

    tearDown(() {
      manager.dispose();
    });

    Widget buildTestWidget({Size size = const Size(400, 800)}) {
      return MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: size),
          child: ShaderProvider(
            manager: manager,
            child: const Scaffold(
              body: DebugOverlayWidget(),
            ),
          ),
        ),
      );
    }

    testWidgets('トグルボタンでデバッグパネルが表示/非表示になる', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Memory'), findsNothing);

      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      expect(find.text('Memory'), findsOneWidget);
    });

    testWidgets('メモリ情報が表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      expect(find.text('Memory'), findsOneWidget);
      expect(find.textContaining('RSS'), findsWidgets);
    });

    testWidgets('シェーダー状態が表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      expect(find.text('Shader'), findsOneWidget);
      expect(find.textContaining('Ready'), findsOneWidget);
    });

    testWidgets('シェーダーパラメータが表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      expect(find.text('Parameters'), findsOneWidget);
      expect(find.textContaining('Speed'), findsOneWidget);
      expect(find.textContaining('Complexity'), findsOneWidget);
    });

    testWidgets('speedスライダーで値を変更できる', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      final speedSlider = find.byWidgetPredicate(
        (w) =>
            w is Slider &&
            w.min == ShaderConfig.minSpeed &&
            w.max == ShaderConfig.maxSpeed,
      );
      expect(speedSlider, findsOneWidget);
    });

    testWidgets('complexityスライダーで値を変更できる', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      final complexitySlider = find.byWidgetPredicate(
        (w) =>
            w is Slider &&
            w.min == ShaderConfig.minComplexity &&
            w.max == ShaderConfig.maxComplexity,
      );
      expect(complexitySlider, findsOneWidget);
    });

    testWidgets('Color1/2/3のRGB値が表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      expect(find.textContaining('Color1'), findsOneWidget);
      expect(find.textContaining('Color2'), findsOneWidget);
      expect(find.textContaining('Color3'), findsOneWidget);
    });

    testWidgets('elapsedTimeが表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      expect(find.textContaining('Time'), findsOneWidget);
    });

    testWidgets('横画面でもパネルが表示される', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(size: const Size(800, 400)),
      );

      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      expect(find.text('Memory'), findsOneWidget);
      expect(find.text('Parameters'), findsOneWidget);
    });
  });
}

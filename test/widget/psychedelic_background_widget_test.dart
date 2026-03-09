import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/manager/background_manager.dart';
import 'package:psychedelic_bg/provider/shader_provider.dart';
import 'package:psychedelic_bg/widget/psychedelic_background_widget.dart';

void main() {
  group('PsychedelicBackgroundWidget', () {
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
          child: const PsychedelicBackgroundWidget(),
        ),
      );
    }

    testWidgets('RepaintBoundaryでラップされている', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final backgroundFinder = find.byType(PsychedelicBackgroundWidget);
      expect(
        find.descendant(
          of: backgroundFinder,
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });

    testWidgets('SizedBox.expandで画面全体を占有する', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final backgroundFinder = find.byType(PsychedelicBackgroundWidget);
      expect(
        find.descendant(
          of: backgroundFinder,
          matching: find.byType(SizedBox),
        ),
        findsOneWidget,
      );
    });

    testWidgets('シェーダー未ロード時はフォールバック色を表示', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final backgroundFinder = find.byType(PsychedelicBackgroundWidget);
      expect(
        find.descendant(
          of: backgroundFinder,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is ColoredBox &&
                widget.color == ShaderConfig.defaultColor1,
          ),
        ),
        findsOneWidget,
      );
    });

    testWidgets('横画面でもSizedBox.expandで全体を占有する', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 400)),
            child: ShaderProvider(
              manager: manager,
              child: const PsychedelicBackgroundWidget(),
            ),
          ),
        ),
      );

      final backgroundFinder = find.byType(PsychedelicBackgroundWidget);
      expect(
        find.descendant(
          of: backgroundFinder,
          matching: find.byType(SizedBox),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: backgroundFinder,
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });
  });
}

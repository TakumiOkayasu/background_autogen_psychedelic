import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      expect(find.text('Shader'), findsOneWidget);
    });

    testWidgets('左上に配置される', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final aligns = tester
          .widgetList<Align>(
            find.ancestor(
              of: find.byIcon(Icons.bug_report),
              matching: find.byType(Align),
            ),
          )
          .where((a) => a.alignment == Alignment.topLeft);
      expect(aligns, isNotEmpty);
    });

    testWidgets('Uniform情報のfloat数とbyte数が表示される', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      final expectedUniformCount = ShaderProvider.uniformCountValue;
      final expectedBytes = expectedUniformCount * ShaderProvider.bytesPerFloatValue;
      expect(
        find.textContaining('$expectedUniformCount floats ($expectedBytes bytes)'),
        findsOneWidget,
      );
    });

    testWidgets('パラメータ操作UIが存在しない', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsNothing);
      expect(find.byType(DropdownButton), findsNothing);
    });
  });
}

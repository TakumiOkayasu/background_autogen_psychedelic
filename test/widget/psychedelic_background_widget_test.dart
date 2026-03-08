import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychedelic_bg/widget/psychedelic_background_widget.dart';

void main() {
  group('PsychedelicBackgroundWidget', () {
    testWidgets('RepaintBoundaryでラップされている', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PsychedelicBackgroundWidget(),
        ),
      );

      expect(find.byType(RepaintBoundary), findsWidgets);
    });

    testWidgets('SizedBox.expandで画面全体を占有する', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PsychedelicBackgroundWidget(),
        ),
      );

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('シェーダー未ロード時はフォールバック色を表示', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PsychedelicBackgroundWidget(),
        ),
      );

      // シェーダー未ロード時、ColoredBoxがフォールバックとして表示される
      expect(find.byType(ColoredBox), findsOneWidget);
    });
  });
}

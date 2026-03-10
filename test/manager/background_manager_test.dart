import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/manager/background_manager.dart';

void main() {
  group('BackgroundManager', () {
    late BackgroundManager manager;

    setUp(() {
      manager = BackgroundManager();
    });

    tearDown(() {
      manager.dispose();
    });

    test('uniformCountが16', () {
      expect(uniformCount, 16);
    });

    test('初期状態ではisReadyがfalse', () {
      expect(manager.isReady, isFalse);
    });

    test('デフォルトのconfigが設定されている', () {
      expect(manager.config, const ShaderConfig());
    });

    test('configを更新できる', () {
      const newConfig = ShaderConfig(speed: 2.0);
      manager.config = newConfig;
      expect(manager.config, newConfig);
    });

    test('config変更時にリスナーに通知される', () {
      var notified = false;
      manager.addListener(() => notified = true);
      manager.config = const ShaderConfig(speed: 2.0);
      expect(notified, isTrue);
    });

    test('isPausedの初期値はfalse', () {
      expect(manager.isPaused, isFalse);
    });

    test('pause/resumeで状態が切り替わる', () {
      manager.pause();
      expect(manager.isPaused, isTrue);
      manager.resume();
      expect(manager.isPaused, isFalse);
    });

    test('elapsedSecondsの初期値は0', () {
      expect(manager.elapsedSeconds, 0.0);
    });

    testWidgets('TickerでelapsedSecondsが更新される', (tester) async {
      late _TickerCaptureWidgetState capturedState;
      await tester.pumpWidget(
        MaterialApp(
          home: _TickerCaptureWidget(
            onState: (s) => capturedState = s,
          ),
        ),
      );

      manager.startTicker(capturedState);

      // 最初のフレーム（elapsed=0）を進める
      await tester.pump();
      // 1秒進める
      await tester.pump(const Duration(seconds: 1));

      expect(manager.elapsedSeconds, greaterThan(0.0));

      manager.stopTicker();
    });

    testWidgets('pause中はelapsedSecondsが更新されない', (tester) async {
      late _TickerCaptureWidgetState capturedState;
      await tester.pumpWidget(
        MaterialApp(
          home: _TickerCaptureWidget(
            onState: (s) => capturedState = s,
          ),
        ),
      );

      manager.startTicker(capturedState);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      manager.pause();
      final pausedTime = manager.elapsedSeconds;

      await tester.pump(const Duration(seconds: 1));

      expect(manager.elapsedSeconds, pausedTime);

      manager.stopTicker();
    });
  });
}

class _TickerCaptureWidget extends StatefulWidget {
  const _TickerCaptureWidget({required this.onState});

  final ValueChanged<_TickerCaptureWidgetState> onState;

  @override
  State<_TickerCaptureWidget> createState() => _TickerCaptureWidgetState();
}

class _TickerCaptureWidgetState extends State<_TickerCaptureWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.onState(this);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/provider/shader_provider.dart';

class PsychedelicBackgroundWidget extends StatefulWidget {
  const PsychedelicBackgroundWidget({super.key});

  @override
  State<PsychedelicBackgroundWidget> createState() =>
      _PsychedelicBackgroundWidgetState();
}

class _PsychedelicBackgroundWidgetState
    extends State<PsychedelicBackgroundWidget>
    with SingleTickerProviderStateMixin {
  bool _initialized = false;
  // dispose時にcontextからProviderにアクセスできないためキャッシュ
  VoidCallback? _cachedCleanup;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      ShaderProvider.addListener(context, _onUpdate);
      ShaderProvider.startTicker(context, this);
      ShaderProvider.loadShader(context);

      // dispose用にクリーンアップ関数をキャプチャ
      final manager = ShaderProvider.of(context);
      _cachedCleanup = () {
        manager.removeListener(_onUpdate);
        manager.stopTicker();
      };
    }
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _cachedCleanup?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReady = ShaderProvider.isReady(context);
    return RepaintBoundary(
      child: isReady
          ? SizedBox.expand(
              child: CustomPaint(
                painter: _ShaderPainter(
                  repaintNotifier: ShaderProvider.listenableOf(context),
                  shaderFactory: (size) =>
                      ShaderProvider.createShader(context, size),
                ),
              ),
            )
          : SizedBox.expand(
              child: ColoredBox(
                color: ShaderConfig.defaultColor1,
              ),
            ),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({
    required this.repaintNotifier,
    required this.shaderFactory,
  }) : super(repaint: repaintNotifier);

  final Listenable repaintNotifier;
  final ui.Shader? Function(ui.Size size) shaderFactory;

  @override
  void paint(Canvas canvas, Size size) {
    final shader = shaderFactory(ui.Size(size.width, size.height));
    if (shader == null) return;
    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) => false;
}

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/manager/background_manager.dart';

class PsychedelicBackgroundWidget extends StatefulWidget {
  const PsychedelicBackgroundWidget({super.key});

  @override
  State<PsychedelicBackgroundWidget> createState() =>
      _PsychedelicBackgroundWidgetState();
}

class _PsychedelicBackgroundWidgetState
    extends State<PsychedelicBackgroundWidget>
    with SingleTickerProviderStateMixin {
  final BackgroundManager _manager = BackgroundManager();

  @override
  void initState() {
    super.initState();
    _manager.addListener(_onManagerUpdate);
    _manager.startTicker(this);
    _manager.load();
  }

  void _onManagerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _manager.removeListener(_onManagerUpdate);
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: _manager.isReady
          ? SizedBox.expand(
              child: CustomPaint(
                painter: _ShaderPainter(manager: _manager),
              ),
            )
          : SizedBox.expand(
              child: ColoredBox(
                color: const ShaderConfig().color1,
              ),
            ),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  _ShaderPainter({required this.manager}) : super(repaint: manager);

  final BackgroundManager manager;

  @override
  void paint(Canvas canvas, Size size) {
    if (!manager.isReady) return;

    final shader = manager.createShader(ui.Size(size.width, size.height));
    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _ShaderPainter oldDelegate) => false;
}

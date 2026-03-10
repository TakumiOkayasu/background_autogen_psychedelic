import 'package:flutter/material.dart';

import 'package:psychedelic_bg/provider/shader_provider.dart';
import 'package:psychedelic_bg/widget/memory_info_stub.dart'
    if (dart.library.io) 'package:psychedelic_bg/widget/memory_info_io.dart'
    if (dart.library.js_interop) 'package:psychedelic_bg/widget/memory_info_web.dart';

abstract final class _Style {
  // -- Colors --
  static const Color accentColor = Colors.greenAccent;
  static const Color panelBackground = Colors.black87;
  static const Color buttonBackground = Colors.black45;
  static const Color valueTextColor = Colors.white70;

  // -- Dimensions --
  static const double panelMaxWidth = 320;
  static const double panelMargin = 8;
  static const double panelPadding = 12;
  static const double borderRadius = 8;
  static const double buttonPadding = 8;
  static const double fontSize = 11;
  static const double sectionTitleFontSize = 13;
  static const double sectionSpacing = 12;
  static const double dividerHeight = 8;
  static const double dividerThickness = 0.5;
  static const double infoRowVerticalPadding = 1;
  static const double infoRowGap = 8;

  // -- Typography --
  static const String fontFamily = 'monospace';

  static const TextStyle sectionTitle = TextStyle(
    color: accentColor,
    fontSize: sectionTitleFontSize,
    fontWeight: FontWeight.bold,
    fontFamily: fontFamily,
  );

  static const TextStyle label = TextStyle(
    color: accentColor,
    fontSize: fontSize,
    fontFamily: fontFamily,
  );

  static const TextStyle value = TextStyle(
    color: valueTextColor,
    fontSize: fontSize,
    fontFamily: fontFamily,
  );

  // -- Decoration --
  static const BoxDecoration panelDecoration = BoxDecoration(
    color: panelBackground,
    borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
  );
}

class DebugOverlayWidget extends StatefulWidget {
  const DebugOverlayWidget({super.key});

  @override
  State<DebugOverlayWidget> createState() => _DebugOverlayWidgetState();
}

class _DebugOverlayWidgetState extends State<DebugOverlayWidget> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(_Style.buttonPadding),
              child: IconButton(
                icon: const Icon(Icons.bug_report),
                onPressed: () => setState(() => _isOpen = !_isOpen),
                style: IconButton.styleFrom(
                  backgroundColor: _Style.buttonBackground,
                  foregroundColor: _Style.accentColor,
                ),
              ),
            ),
            if (_isOpen)
              Flexible(
                child: _buildPanel(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final isReady = ShaderProvider.isReady(context);
    final elapsed = ShaderProvider.elapsedSecondsOf(context);

    return Container(
      width: _Style.panelMaxWidth,
      margin: const EdgeInsets.symmetric(horizontal: _Style.panelMargin),
      padding: const EdgeInsets.all(_Style.panelPadding),
      decoration: _Style.panelDecoration,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMemorySection(),
            const SizedBox(height: _Style.sectionSpacing),
            _buildShaderSection(isReady, elapsed),
          ],
        ),
      ),
    );
  }

  Widget _buildMemorySection() {
    return _Section(
      title: 'Memory',
      children: [
        _InfoRow(label: 'RSS', value: formatRss()),
        _InfoRow(label: 'Max RSS', value: formatMaxRss()),
      ],
    );
  }

  Widget _buildShaderSection(bool isReady, double elapsed) {
    final count = ShaderProvider.uniformCountValue;
    final bytes = count * ShaderProvider.bytesPerFloatValue;

    return _Section(
      title: 'Shader',
      children: [
        _InfoRow(label: 'Ready', value: isReady ? 'Yes' : 'No'),
        _InfoRow(label: 'Time', value: '${elapsed.toStringAsFixed(2)}s'),
        _InfoRow(label: 'Uniforms', value: '$count floats ($bytes bytes)'),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: _Style.sectionTitle),
        const Divider(color: _Style.accentColor, height: _Style.dividerHeight, thickness: _Style.dividerThickness),
        ...children,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _Style.infoRowVerticalPadding),
      child: Row(
        children: [
          Text(label, style: _Style.label),
          const SizedBox(width: _Style.infoRowGap),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: _Style.value,
            ),
          ),
        ],
      ),
    );
  }
}

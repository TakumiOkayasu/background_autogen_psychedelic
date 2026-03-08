import 'package:flutter/material.dart';

import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/interface/shader_pattern.dart';
import 'package:psychedelic_bg/manager/background_manager.dart'
    show uniformCount, bytesPerFloat;
import 'package:psychedelic_bg/provider/shader_provider.dart';
// Web: performance.memory, Native: dart:io ProcessInfo
import 'package:psychedelic_bg/widget/memory_info_stub.dart'
    if (dart.library.io) 'package:psychedelic_bg/widget/memory_info_io.dart'
    if (dart.library.js_interop) 'package:psychedelic_bg/widget/memory_info_web.dart';

const double _panelMaxWidth = 320;
const double _fontSize = 11;
const double _sectionTitleFontSize = 13;
const double _sectionSpacing = 12;
const double _itemSpacing = 4;
const double _colorSwatchSize = 12;
const double _sliderLabelWidth = 100;
const double _sliderThumbRadius = 6;
const double _sliderTrackHeight = 2;
const int _sliderInactiveAlpha = 51;
const int _colorChannelScale = 255;

class DebugOverlayWidget extends StatefulWidget {
  const DebugOverlayWidget({super.key});

  @override
  State<DebugOverlayWidget> createState() => _DebugOverlayWidgetState();
}

class _DebugOverlayWidgetState extends State<DebugOverlayWidget> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLandscape = size.width > size.height;

    return Align(
      alignment: isLandscape ? Alignment.topLeft : Alignment.topRight,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: const Icon(Icons.bug_report),
                onPressed: () => setState(() => _isOpen = !_isOpen),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black45,
                  foregroundColor: Colors.greenAccent,
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
    final config = ShaderProvider.configOf(context);
    final isReady = ShaderProvider.isReady(context);
    final elapsed = ShaderProvider.elapsedSecondsOf(context);

    return Container(
      width: _panelMaxWidth,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMemorySection(),
            const SizedBox(height: _sectionSpacing),
            _buildShaderSection(isReady, elapsed),
            const SizedBox(height: _sectionSpacing),
            _buildParametersSection(context, config),
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
    return _Section(
      title: 'Shader',
      children: [
        _InfoRow(label: 'Ready', value: isReady ? 'Yes' : 'No'),
        _InfoRow(label: 'Time', value: '${elapsed.toStringAsFixed(2)}s'),
        _InfoRow(
          label: 'Uniforms',
          value:
              '$uniformCount floats (${uniformCount * bytesPerFloat} bytes)',
        ),
      ],
    );
  }

  Widget _buildParametersSection(BuildContext context, ShaderConfig config) {
    return _Section(
      title: 'Parameters',
      children: [
        _buildPatternDropdown(context, config),
        const SizedBox(height: _itemSpacing),
        _buildPresetDropdown(context),
        const SizedBox(height: _itemSpacing),
        _buildColorRow('Color1', config.color1),
        _buildColorRow('Color2', config.color2),
        _buildColorRow('Color3', config.color3),
        const SizedBox(height: _itemSpacing),
        _buildParamSlider(
          context: context,
          label: 'Speed',
          value: config.speed,
          min: ShaderConfig.minSpeed,
          max: ShaderConfig.maxSpeed,
          onChanged: (v) => ShaderProvider.updateConfig(
            context,
            config.copyWith(speed: v),
          ),
        ),
        _buildParamSlider(
          context: context,
          label: 'Complexity',
          value: config.complexity,
          min: ShaderConfig.minComplexity,
          max: ShaderConfig.maxComplexity,
          onChanged: (v) => ShaderProvider.updateConfig(
            context,
            config.copyWith(complexity: v),
          ),
        ),
      ],
    );
  }

  Widget _buildPatternDropdown(BuildContext context, ShaderConfig config) {
    return Row(
      children: [
        const SizedBox(
          width: _sliderLabelWidth,
          child: Text(
            'Pattern',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: _fontSize,
              fontFamily: 'monospace',
            ),
          ),
        ),
        Expanded(
          child: DropdownButton<ShaderPattern>(
            value: config.pattern,
            isExpanded: true,
            dropdownColor: Colors.black87,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: _fontSize,
              fontFamily: 'monospace',
            ),
            items: ShaderPattern.values
                .map(
                  (p) => DropdownMenuItem(
                    value: p,
                    child: Text(p.label),
                  ),
                )
                .toList(),
            onChanged: (p) {
              if (p != null) {
                ShaderProvider.updateConfig(
                  context,
                  config.copyWith(pattern: p),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPresetDropdown(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: _sliderLabelWidth,
          child: Text(
            'Preset',
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: _fontSize,
              fontFamily: 'monospace',
            ),
          ),
        ),
        Expanded(
          child: DropdownButton<String>(
            value: null,
            hint: const Text(
              'Select...',
              style: TextStyle(
                color: Colors.white38,
                fontSize: _fontSize,
                fontFamily: 'monospace',
              ),
            ),
            isExpanded: true,
            dropdownColor: Colors.black87,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: _fontSize,
              fontFamily: 'monospace',
            ),
            items: ShaderConfig.presets.keys
                .map(
                  (name) => DropdownMenuItem(
                    value: name,
                    child: Text(name),
                  ),
                )
                .toList(),
            onChanged: (name) {
              if (name != null) {
                final preset = ShaderConfig.presets[name];
                if (preset != null) {
                  ShaderProvider.updateConfig(context, preset);
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorRow(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: _colorSwatchSize,
            height: _colorSwatchSize,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: RGB(${(color.r * _colorChannelScale).round()}, ${(color.g * _colorChannelScale).round()}, ${(color.b * _colorChannelScale).round()})',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: _fontSize,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParamSlider({
    required BuildContext context,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: _sliderLabelWidth,
          child: Text(
            '$label: ${value.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: _fontSize,
              fontFamily: 'monospace',
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: _sliderThumbRadius),
              trackHeight: _sliderTrackHeight,
              activeTrackColor: Colors.greenAccent,
              inactiveTrackColor: Colors.greenAccent.withAlpha(_sliderInactiveAlpha),
              thumbColor: Colors.greenAccent,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
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
        Text(
          title,
          style: const TextStyle(
            color: Colors.greenAccent,
            fontSize: _sectionTitleFontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
        const Divider(color: Colors.greenAccent, height: 8, thickness: 0.5),
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
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: _fontSize,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: _fontSize,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

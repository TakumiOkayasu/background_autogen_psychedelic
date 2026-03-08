import 'package:flutter/material.dart';

import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/provider/shader_provider.dart';

class _PresetEntry {
  const _PresetEntry({required this.label, required this.config});
  final String label;
  final ShaderConfig config;
}

const _presets = [
  _PresetEntry(label: '暖色', config: ShaderConfig.warm),
  _PresetEntry(label: '寒色', config: ShaderConfig.cool),
  _PresetEntry(label: 'ネオン', config: ShaderConfig.neon),
];

class ColorOverlayWidget extends StatefulWidget {
  const ColorOverlayWidget({super.key});

  @override
  State<ColorOverlayWidget> createState() => _ColorOverlayWidgetState();
}

class _ColorOverlayWidgetState extends State<ColorOverlayWidget> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_isOpen) _buildPanel(context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FloatingActionButton(
              onPressed: () => setState(() => _isOpen = !_isOpen),
              child: const Icon(Icons.tune),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final config = ShaderProvider.configOf(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            children: _presets
                .map(
                  (p) => ActionChip(
                    label: Text(p.label),
                    onPressed: () => ShaderProvider.updateConfig(
                      context,
                      p.config.copyWith(
                        speed: config.speed,
                        complexity: config.complexity,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _buildSliderRow(
            label: '速度',
            value: config.speed,
            min: ShaderConfig.minSpeed,
            max: ShaderConfig.maxSpeed,
            onChanged: (v) => ShaderProvider.updateConfig(
              context,
              config.copyWith(speed: v),
            ),
          ),
          _buildSliderRow(
            label: '複雑度',
            value: config.complexity,
            min: ShaderConfig.minComplexity,
            max: ShaderConfig.maxComplexity,
            onChanged: (v) => ShaderProvider.updateConfig(
              context,
              config.copyWith(complexity: v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}

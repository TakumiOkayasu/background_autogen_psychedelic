import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

import 'package:psychedelic_bg/interface/shader_config.dart';
import 'package:psychedelic_bg/interface/shader_pattern.dart';
import 'package:psychedelic_bg/provider/shader_provider.dart';

abstract final class _Style {
  // -- Colors --
  static const Color panelBackground = Colors.black54;
  static const Color dropdownBackground = Colors.black87;
  static const Color dropdownTextColor = Colors.white70;
  static const Color sliderLabelColor = Colors.white;

  // -- Dimensions --
  static const double panelMaxWidth = 560;
  static const double columnSpacing = 16;
  static const double buttonPadding = 16;
  static const double panelMargin = 16;
  static const double panelPadding = 16;
  static const double sectionSpacing = 12;
  static const double borderRadius = 12;
  static const double chipSpacing = 8;
  static const double chipRunSpacing = 4;
  static const double dropdownFontSize = 14;
  static const double sliderLabelWidth = 80;
  static const double sliderFontSize = 12;
  static const double colorIndicatorSize = 32;

  // -- Typography --
  static const TextStyle dropdownText = TextStyle(
    color: dropdownTextColor,
    fontSize: dropdownFontSize,
  );
  static const TextStyle sliderLabel = TextStyle(
    color: sliderLabelColor,
    fontSize: sliderFontSize,
  );

  // -- Decoration --
  static const BoxDecoration panelDecoration = BoxDecoration(
    color: panelBackground,
    borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
  );
}

class ControlPanelWidget extends StatefulWidget {
  const ControlPanelWidget({super.key});

  @override
  State<ControlPanelWidget> createState() => _ControlPanelWidgetState();
}

class _ControlPanelWidgetState extends State<ControlPanelWidget> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_isOpen) _buildPanel(context),
            Padding(
              padding: const EdgeInsets.all(_Style.buttonPadding),
              child: FloatingActionButton(
                onPressed: () => setState(() => _isOpen = !_isOpen),
                child: const Icon(Icons.tune),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final config = ShaderProvider.configOf(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: _Style.panelMaxWidth),
      margin: const EdgeInsets.symmetric(horizontal: _Style.panelMargin),
      padding: const EdgeInsets.all(_Style.panelPadding),
      decoration: _Style.panelDecoration,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: pattern, presets, colors
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatternDropdown(context, config),
                  const SizedBox(height: _Style.sectionSpacing),
                  _buildPresetChips(context, config.pattern),
                  const SizedBox(height: _Style.sectionSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: _buildColorRow(
                            'Color 1', config.color1, (c) {
                          ShaderProvider.updateConfig(
                            context,
                            config.copyWith(color1: c),
                          );
                        }),
                      ),
                      Flexible(
                        child: _buildColorRow(
                            'Color 2', config.color2, (c) {
                          ShaderProvider.updateConfig(
                            context,
                            config.copyWith(color2: c),
                          );
                        }),
                      ),
                      Flexible(
                        child: _buildColorRow(
                            'Color 3', config.color3, (c) {
                          ShaderProvider.updateConfig(
                            context,
                            config.copyWith(color3: c),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: _Style.columnSpacing),
            // Right column: sliders
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSliderRow(
                    label: 'Speed',
                    value: config.speed,
                    min: ShaderConfig.minSpeed,
                    max: ShaderConfig.maxSpeed,
                    onChanged: (v) => ShaderProvider.updateConfig(
                      context,
                      config.copyWith(speed: v),
                    ),
                  ),
                  _buildSliderRow(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternDropdown(BuildContext context, ShaderConfig config) {
    return DropdownButton<ShaderPattern>(
      value: config.pattern,
      isExpanded: true,
      dropdownColor: _Style.dropdownBackground,
      style: _Style.dropdownText,
      items: ShaderPattern.values
          .map(
            (p) => DropdownMenuItem(value: p, child: Text(p.label)),
          )
          .toList(),
      onChanged: (p) {
        if (p != null) {
          ShaderProvider.updateConfig(context, config.copyWith(pattern: p));
        }
      },
    );
  }

  Widget _buildPresetChips(BuildContext context, ShaderPattern currentPattern) {
    return Wrap(
      spacing: _Style.chipSpacing,
      runSpacing: _Style.chipRunSpacing,
      children: ShaderConfig.presets.entries
          .map(
            (entry) => ActionChip(
              label: Text(entry.key),
              onPressed: () => ShaderProvider.updateConfig(
                context,
                entry.value.copyWith(pattern: currentPattern),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildColorRow(
    String label,
    Color color,
    ValueChanged<Color> onChanged,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () async {
            final picked = await showColorPickerDialog(
              context,
              color,
              pickersEnabled: const <ColorPickerType, bool>{
                ColorPickerType.wheel: true,
              },
            );
            onChanged(picked);
          },
          child: Container(
            width: _Style.colorIndicatorSize,
            height: _Style.colorIndicatorSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: _Style.sliderLabel),
      ],
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
          width: _Style.sliderLabelWidth,
          child: Text(
            '$label: ${value.toStringAsFixed(2)}',
            style: _Style.sliderLabel,
          ),
        ),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}

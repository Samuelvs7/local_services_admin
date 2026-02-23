// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';

/// A styled slider equivalent to shadcn/ui's Slider.
///
/// Renders a track with a draggable thumb, primary-colored range fill,
/// and focus ring.
///
/// ```dart
/// AppSlider(value: 0.6, onChanged: (v) => setState(() => _val = v))
/// AppSlider(value: 50, min: 0, max: 100, onChanged: (v) {})
/// ```
class AppSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final bool enabled;

  const AppSlider({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.onChanged,
    this.onChangeEnd,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trackBg =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: SliderTheme(
        data: SliderThemeData(
          // Track
          activeTrackColor: theme.colorScheme.primary,
          inactiveTrackColor: trackBg,
          trackHeight: 8,
          trackShape: const RoundedRectSliderTrackShape(),

          // Thumb — 20×20 circle with 2px primary border
          thumbColor: theme.scaffoldBackgroundColor,
          thumbShape: _ShadcnThumbShape(
            borderColor: theme.colorScheme.primary,
            fillColor: theme.scaffoldBackgroundColor,
          ),

          // Overlay on drag / focus
          overlayColor: theme.colorScheme.primary.withAlpha(31),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),

          // Remove value indicator
          showValueIndicator: ShowValueIndicator.never,
        ),
        child: Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: enabled ? onChanged : null,
          onChangeEnd: onChangeEnd,
        ),
      ),
    );
  }
}

/// Custom thumb that mimics shadcn/ui's bordered circle.
///
/// Extends [RoundSliderThumbShape] and delegates to super, then draws
/// a border ring on top. This avoids overriding deprecated parameters.
class _ShadcnThumbShape extends SliderComponentShape {
  final double radius;
  final Color borderColor;
  final Color fillColor;

  const _ShadcnThumbShape({
    this.radius = 10,
    required this.borderColor,
    required this.fillColor,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius);


  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Fill
    canvas.drawCircle(center, radius, Paint()..color = fillColor);

    // Border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }
}


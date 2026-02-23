import 'package:flutter/material.dart';

/// A styled progress bar equivalent to shadcn/ui's Progress.
///
/// Renders a rounded track with an animated indicator that fills
/// from left to right based on [value] (0–100).
///
/// ```dart
/// AppProgress(value: 60)
/// AppProgress(value: progress, color: Colors.green)
/// ```
class AppProgress extends StatelessWidget {
  /// Progress value from 0 to 100.
  final double value;

  /// Height of the bar. Defaults to 16 (matching `h-4`).
  final double height;

  /// Optional override for the indicator color. Falls back to primary.
  final Color? color;

  /// Optional override for the track background color.
  final Color? backgroundColor;

  /// Animation duration when [value] changes.
  final Duration duration;

  const AppProgress({
    super.key,
    required this.value,
    this.height = 16,
    this.color,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trackColor = backgroundColor ??
        (isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51));
    final indicatorColor = color ?? theme.colorScheme.primary;

    final clamped = value.clamp(0.0, 100.0) / 100.0;

    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: AnimatedFractionallySizedBox(
        duration: duration,
        curve: Curves.easeOut,
        alignment: Alignment.centerLeft,
        widthFactor: clamped,
        child: Container(
          decoration: BoxDecoration(
            color: indicatorColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

/// Animated version of [FractionallySizedBox] that smoothly transitions
/// the [widthFactor] property.
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double? widthFactor;
  final double? heightFactor;
  final Alignment alignment;
  final Widget? child;

  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    super.curve,
    this.widthFactor,
    this.heightFactor,
    this.alignment = Alignment.center,
    this.child,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;
  Tween<double>? _heightFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor ?? 1.0,
      (dynamic v) => Tween<double>(begin: v as double),
    ) as Tween<double>?;

    _heightFactor = visitor(
      _heightFactor,
      widget.heightFactor ?? 1.0,
      (dynamic v) => Tween<double>(begin: v as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: widget.alignment,
      widthFactor: _widthFactor?.evaluate(animation),
      heightFactor: _heightFactor?.evaluate(animation),
      child: widget.child,
    );
  }
}

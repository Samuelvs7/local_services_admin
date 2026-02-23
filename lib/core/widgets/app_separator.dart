import 'package:flutter/material.dart';

/// A styled separator equivalent to shadcn/ui's Separator.
///
/// Renders a 1px line — horizontal (full width) or vertical (full height).
///
/// ```dart
/// AppSeparator()                                  // horizontal
/// AppSeparator(orientation: Axis.vertical)        // vertical
/// AppSeparator(color: Colors.red, thickness: 2)   // custom
/// ```
class AppSeparator extends StatelessWidget {
  final Axis orientation;
  final Color? color;
  final double thickness;
  final EdgeInsets? margin;

  const AppSeparator({
    super.key,
    this.orientation = Axis.horizontal,
    this.color,
    this.thickness = 1,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final lineColor = color ??
        (isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51));

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: orientation == Axis.horizontal
          ? Container(height: thickness, color: lineColor)
          : Container(width: thickness, color: lineColor),
    );
  }
}

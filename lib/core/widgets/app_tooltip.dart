import 'package:flutter/material.dart';

/// A styled tooltip equivalent to shadcn/ui's Tooltip.
///
/// Wraps the built-in [Tooltip] with shadcn/ui styling:
/// - Small rounded corners (6px)
/// - Muted border and shadow
/// - Consistent padding and text size
/// - Vertical offset and delay options
///
/// ```dart
/// AppTooltip(
///   message: 'Add to library',
///   child: IconButton(icon: Icon(Icons.add), onPressed: () {}),
/// )
/// ```
class AppTooltip extends StatelessWidget {
  /// The text to display in the tooltip.
  final String? message;

  /// The widget content for the tooltip (alternative to message).
  ///
  /// If provided, this overrides [message].
  final Widget? content;

  /// The widget that triggers the tooltip.
  final Widget child;

  /// Delay before the tooltip is shown.
  final Duration? waitDuration;

  /// Whether the tooltip should prefer to be shown below the child.
  final bool preferBelow;

  /// Distance between the child and the tooltip.
  final double verticalOffset;

  const AppTooltip({
    super.key,
    this.message,
    this.content,
    required this.child,
    this.waitDuration = const Duration(milliseconds: 300),
    this.preferBelow = false,
    this.verticalOffset = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Colors matching shadcn/ui popover styling
    final bgColor = isDark 
        ? const Color(0xFF030712) // bg-popover
        : Colors.white;
    
    final borderColor = isDark
        ? Colors.white.withAlpha(26) // border
        : Colors.grey.withAlpha(51);

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    final decoration = BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(isDark ? 51 : 20),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );

    final textStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: textColor,
    );

    if (content != null) {
      return Tooltip(
        richMessage: WidgetSpan(
          child: DefaultTextStyle(
            style: textStyle,
            child: content!,
          ),
        ),
        decoration: decoration,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        waitDuration: waitDuration,
        preferBelow: preferBelow,
        verticalOffset: verticalOffset,
        child: child,
      );
    }

    return Tooltip(
      message: message,
      textStyle: textStyle,
      decoration: decoration,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      waitDuration: waitDuration,
      preferBelow: preferBelow,
      verticalOffset: verticalOffset,
      child: child,
    );
  }
}

/// A provider-like wrapper if global configuration is needed.
/// (Mainly for API parity with shadcn/ui)
class AppTooltipProvider extends StatelessWidget {
  final Widget child;
  const AppTooltipProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // In Flutter, Tooltip configuration is usually done via Theme.
    return child;
  }
}

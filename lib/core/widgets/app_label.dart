import 'package:flutter/material.dart';

/// A styled label widget equivalent to shadcn/ui's `<Label>`.
///
/// Renders small (14px), medium-weight text with tight leading.
/// Supports a [disabled] state that reduces opacity to 0.7 and
/// an optional [isRequired] flag that appends a red asterisk.
///
/// ```dart
/// AppLabel(text: 'Email')
/// AppLabel(text: 'Password', isRequired: true)
/// AppLabel(text: 'Disabled field', disabled: true)
/// ```
class AppLabel extends StatelessWidget {
  final String text;
  final bool disabled;
  final bool isRequired;
  final Color? color;
  final double fontSize;

  const AppLabel({
    super.key,
    required this.text,
    this.disabled = false,
    this.isRequired = false,
    this.color,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: disabled ? 0.7 : 1.0,
      child: MouseRegion(
        cursor: disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.basic,
        child: Text.rich(
          TextSpan(
            text: text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              height: 1.0,
              color: color ?? theme.textTheme.bodyMedium?.color,
            ),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }
}

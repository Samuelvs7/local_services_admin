import 'package:flutter/material.dart';

enum AppBadgeVariant {
  standard,
  secondary,
  destructive,
  outline,
}

class AppBadge extends StatelessWidget {
  final Widget label;
  final AppBadgeVariant variant;
  final VoidCallback? onTap;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.standard,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color backgroundColor;
    Color textColor;
    Border? border;

    switch (variant) {
      case AppBadgeVariant.standard:
        backgroundColor = theme.colorScheme.primary;
        textColor = theme.colorScheme.onPrimary;
        break;
      case AppBadgeVariant.secondary:
        backgroundColor = isDark ? theme.colorScheme.surface : Colors.grey[200]!;
        textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
        break;
      case AppBadgeVariant.destructive:
        backgroundColor = theme.colorScheme.error;
        textColor = theme.colorScheme.onError;
        break;
      case AppBadgeVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
        border = Border.all(
          color: isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.4),
        );
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(100),
          border: border,
        ),
        child: DefaultTextStyle(
          style: theme.textTheme.labelSmall!.copyWith(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          child: label,
        ),
      ),
    );
  }
}

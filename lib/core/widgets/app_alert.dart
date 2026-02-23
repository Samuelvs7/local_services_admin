import 'package:flutter/material.dart';

enum AppAlertVariant {
  standard,
  destructive,
}

class AppAlert extends StatelessWidget {
  final IconData? icon;
  final String? title;
  final String description;
  final AppAlertVariant variant;

  const AppAlert({
    super.key,
    this.icon,
    this.title,
    required this.description,
    this.variant = AppAlertVariant.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color borderColor;
    Color textColor;
    Color iconColor;
    Color backgroundColor;

    if (variant == AppAlertVariant.destructive) {
      borderColor = theme.colorScheme.error.withOpacity(isDark ? 0.5 : 0.3);
      textColor = theme.colorScheme.error;
      iconColor = theme.colorScheme.error;
      backgroundColor = isDark ? theme.colorScheme.error.withOpacity(0.05) : theme.colorScheme.error.withOpacity(0.02);
    } else {
      borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2);
      textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
      iconColor = textColor;
      backgroundColor = theme.cardTheme.color ?? theme.scaffoldBackgroundColor;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      title!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: textColor,
                        height: 1.0,
                      ),
                    ),
                  ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: variant == AppAlertVariant.destructive 
                        ? textColor.withOpacity(0.9) 
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

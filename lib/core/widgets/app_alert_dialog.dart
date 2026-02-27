import 'package:flutter/material.dart';

class AppAlertDialog extends StatelessWidget {
  final Widget title;
  final Widget description;
  final Widget cancel;
  final Widget action;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.description,
    required this.cancel,
    required this.action,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget title,
    required Widget description,
    required Widget cancel,
    required Widget action,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Alert Dialog',
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: AppAlertDialog(
            title: title,
            description: description,
            cancel: cancel,
            action: action,
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOut),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 512, // sm:max-w-lg (approx 512px)
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            DefaultTextStyle(
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: theme.textTheme.bodyLarge?.color,
              ),
              child: title,
            ),
            const SizedBox(height: 8),
            // Description
            DefaultTextStyle(
              style: theme.textTheme.bodyMedium!.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14,
                height: 1.5,
              ),
              child: description,
            ),
            const SizedBox(height: 24),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel Button (Outline Style)
                cancel,
                const SizedBox(width: 8),
                // Action Button (Primary Style)
                action,
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Convenience wrapper for Buttons to match shadcn styles
class AppAlertDialogCancel extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AppAlertDialogCancel({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.textTheme.bodyLarge?.color,
        side: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}

class AppAlertDialogAction extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const AppAlertDialogAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}

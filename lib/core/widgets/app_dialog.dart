import 'package:flutter/material.dart';

/// A general-purpose dialog widget equivalent to shadcn/ui's Dialog.
///
/// Unlike [AppAlertDialog] (which is purpose-built for confirm/cancel flows),
/// this dialog accepts arbitrary content and is fully composable using
/// [AppDialogHeader], [AppDialogFooter], [AppDialogTitle],
/// [AppDialogDescription], and [AppDialogClose].
class AppDialog extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AppDialog({
    super.key,
    required this.child,
    this.maxWidth = 512,
  });

  /// Shows this dialog using [showGeneralDialog] with fade + scale animation
  /// and a dark barrier overlay — matching shadcn/ui behaviour.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double maxWidth = 512,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: Colors.black.withAlpha(204), // ~0.8 opacity
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: AppDialog(
            maxWidth: maxWidth,
            child: child,
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
        width: maxWidth,
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(26)
                : Colors.grey.withAlpha(51),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(102), // ~0.4 opacity
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: child,
            ),

            // Close button (top-right X)
            Positioned(
              top: 16,
              right: 16,
              child: AppDialogClose(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Close button for the dialog — equivalent to `<DialogClose>`.
///
/// Calls `Navigator.of(context).pop()` when tapped. Can also be used
/// standalone inside dialog content.
class AppDialogClose extends StatelessWidget {
  final VoidCallback? onClose;

  const AppDialogClose({super.key, this.onClose});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onClose ?? () => Navigator.of(context).pop(),
        child: Opacity(
          opacity: 0.7,
          child: Icon(
            Icons.close_rounded,
            size: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

/// Header layout for the dialog — equivalent to `<DialogHeader>`.
///
/// Arranges its children in a vertical column with tight spacing,
/// left-aligned on desktop (matching `sm:text-left`).
class AppDialogHeader extends StatelessWidget {
  final List<Widget> children;

  const AppDialogHeader({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}

/// Footer layout for the dialog — equivalent to `<DialogFooter>`.
///
/// Arranges actions in a row, right-aligned with spacing between them.
class AppDialogFooter extends StatelessWidget {
  final List<Widget> children;

  const AppDialogFooter({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// Title text for the dialog — equivalent to `<DialogTitle>`.
class AppDialogTitle extends StatelessWidget {
  final String text;

  const AppDialogTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 24), // avoid overlapping close btn
      child: Text(
        text,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          height: 1.2,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

/// Description text for the dialog — equivalent to `<DialogDescription>`.
class AppDialogDescription extends StatelessWidget {
  final String text;

  const AppDialogDescription({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontSize: 14,
        height: 1.5,
      ),
    );
  }
}

/// A trigger widget that opens an [AppDialog] when tapped —
/// equivalent to `<DialogTrigger>`.
class AppDialogTrigger extends StatelessWidget {
  final Widget child;
  final Widget dialog;
  final double maxWidth;
  final bool barrierDismissible;

  const AppDialogTrigger({
    super.key,
    required this.child,
    required this.dialog,
    this.maxWidth = 512,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppDialog.show(
        context: context,
        child: dialog,
        maxWidth: maxWidth,
        barrierDismissible: barrierDismissible,
      ),
      child: child,
    );
  }
}

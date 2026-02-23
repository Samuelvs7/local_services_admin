import 'package:flutter/material.dart';

/// A styled bottom-sheet drawer equivalent to shadcn/ui's Drawer (vaul).
///
/// Features a drag handle, dark barrier overlay, rounded top corners,
/// and composable [AppDrawerHeader], [AppDrawerFooter], [AppDrawerTitle],
/// [AppDrawerDescription] sub-widgets.
class AppDrawer extends StatelessWidget {
  final Widget child;
  final double? maxHeight;

  const AppDrawer({
    super.key,
    required this.child,
    this.maxHeight,
  });

  /// Shows the drawer as a modal bottom sheet with custom styling.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    double? maxHeight,
    bool isDismissible = true,
    bool enableDrag = true,
    bool showDragHandle = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);

    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(204), // ~0.8 opacity
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight ??
                MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.scaffoldBackgroundColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border(
              top: BorderSide(color: borderColor),
              left: BorderSide(color: borderColor),
              right: BorderSide(color: borderColor),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              if (showDragHandle) const AppDrawerHandle(),
              // Content
              Flexible(child: child),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// The small drag-handle pill at the top of the drawer.
class AppDrawerHandle extends StatelessWidget {
  const AppDrawerHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Center(
        child: Container(
          width: 100,
          height: 6,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withAlpha(26)
                : Colors.grey.withAlpha(77),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

/// Trigger widget that opens an [AppDrawer] when tapped —
/// equivalent to `<DrawerTrigger>`.
class AppDrawerTrigger extends StatelessWidget {
  final Widget child;
  final Widget drawer;
  final double? maxHeight;
  final bool isDismissible;
  final bool enableDrag;

  const AppDrawerTrigger({
    super.key,
    required this.child,
    required this.drawer,
    this.maxHeight,
    this.isDismissible = true,
    this.enableDrag = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppDrawer.show(
        context: context,
        child: drawer,
        maxHeight: maxHeight,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
      ),
      child: child,
    );
  }
}

/// Close button / tap target that pops the drawer —
/// equivalent to `<DrawerClose>`.
class AppDrawerClose extends StatelessWidget {
  final Widget child;

  const AppDrawerClose({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: child,
    );
  }
}

/// Header layout for the drawer — equivalent to `<DrawerHeader>`.
///
/// Vertical column with centered text on small screens, left-aligned on larger.
class AppDrawerHeader extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;

  const AppDrawerHeader({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

/// Footer layout for the drawer — equivalent to `<DrawerFooter>`.
///
/// Vertical column of actions at the bottom with spacing.
class AppDrawerFooter extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;

  const AppDrawerFooter({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Title text for the drawer — equivalent to `<DrawerTitle>`.
class AppDrawerTitle extends StatelessWidget {
  final String text;

  const AppDrawerTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        height: 1.2,
        letterSpacing: -0.2,
      ),
    );
  }
}

/// Description text for the drawer — equivalent to `<DrawerDescription>`.
class AppDrawerDescription extends StatelessWidget {
  final String text;

  const AppDrawerDescription({super.key, required this.text});

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

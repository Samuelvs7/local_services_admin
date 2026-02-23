import 'package:flutter/material.dart';

class AppBreadcrumb extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const AppBreadcrumb({
    super.key,
    required this.children,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: spacing,
      children: children,
    );
  }
}

class AppBreadcrumbLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const AppBreadcrumbLink({
    super.key,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class AppBreadcrumbPage extends StatelessWidget {
  final String label;

  const AppBreadcrumbPage({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.textTheme.bodyLarge?.color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class AppBreadcrumbSeparator extends StatelessWidget {
  final Widget? icon;

  const AppBreadcrumbSeparator({
    super.key,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return icon ?? Icon(
      Icons.chevron_right_rounded,
      size: 16,
      color: isDark ? Colors.grey[600] : Colors.grey[400],
    );
  }
}

class AppBreadcrumbEllipsis extends StatelessWidget {
  const AppBreadcrumbEllipsis({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Icon(
      Icons.more_horiz_rounded,
      size: 16,
      color: isDark ? Colors.grey[600] : Colors.grey[400],
    );
  }
}

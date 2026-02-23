import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final Color? color;
  final double? elevation;

  const AppCard({
    super.key,
    required this.children,
    this.padding,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color ?? theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 51 : 13),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class AppCardHeader extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets padding;

  const AppCardHeader({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(24.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.map((child) {
          if (child != children.last) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: child,
            );
          }
          return child;
        }).toList(),
      ),
    );
  }
}

class AppCardTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const AppCardTitle(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.0,
        color: theme.textTheme.bodyLarge?.color,
      ).merge(style),
    );
  }
}

class AppCardDescription extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const AppCardDescription(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: isDark ? Colors.grey[400] : Colors.grey[600],
        fontSize: 14,
        height: 1.4,
      ).merge(style),
    );
  }
}

class AppCardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AppCardContent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 24),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

class AppCardFooter extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AppCardFooter({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 0, 24, 24),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: child,
    );
  }
}

import 'package:flutter/material.dart';

/// A utility widget equivalent to React Router's `NavLink`.
///
/// It determines if the current route matches [to] and provides that
/// state to the [builder]. It also handles navigation on tap.
///
/// ```dart
/// AppNavLink(
///   to: '/dashboard',
///   builder: (context, isActive) => Text(
///     'Dashboard',
///     style: TextStyle(
///       color: isActive ? Colors.blue : Colors.grey,
///       fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
///     ),
///   ),
/// )
/// ```
class AppNavLink extends StatelessWidget {
  /// The target route name.
  final String to;

  /// A builder that provides the [isActive] state.
  final Widget Function(BuildContext context, bool isActive) builder;

  /// Whether to use [pushReplacementNamed] instead of [pushNamed].
  final bool replace;

  /// Optional callback after navigation.
  final VoidCallback? onTap;

  /// Whether to consider sub-routes as active (exact match vs prefix).
  /// Default is true (exact match).
  final bool exact;

  const AppNavLink({
    super.key,
    required this.to,
    required this.builder,
    this.replace = false,
    this.onTap,
    this.exact = true,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    
    final bool isActive;
    if (exact) {
      isActive = currentRoute == to;
    } else {
      isActive = currentRoute.startsWith(to);
    }

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          if (replace) {
            Navigator.of(context).pushReplacementNamed(to);
          } else {
            Navigator.of(context).pushNamed(to);
          }
        }
        onTap?.call();
      },
      child: builder(context, isActive),
    );
  }
}

/// A simplified NavLink that works well for Sidebar items.
class AppNavButton extends StatelessWidget {
  final String to;
  final Widget icon;
  final String label;
  final bool replace;

  const AppNavButton({
    super.key,
    required this.to,
    required this.icon,
    required this.label,
    this.replace = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppNavLink(
      to: to,
      replace: replace,
      builder: (context, isActive) {
        // This is a placeholder for a styled button that uses 
        // the active state. Many existing widgets (like AppSidebarMenuButton)
        // already take an `isActive` prop. This bridge makes it automatic.
        return _AppNavButtonContent(
          icon: icon,
          label: label,
          isActive: isActive,
        );
      },
    );
  }
}

// Internal content that mimics the Sidebar menu button style
class _AppNavButtonContent extends StatefulWidget {
  final Widget icon;
  final String label;
  final bool isActive;

  const _AppNavButtonContent({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  @override
  State<_AppNavButtonContent> createState() => _AppNavButtonContentState();
}

class _AppNavButtonContentState extends State<_AppNavButtonContent> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accentBg = isDark
        ? Colors.white.withAlpha(13)
        : Colors.grey.withAlpha(26);

    final bgColor = widget.isActive
        ? accentBg
        : (_hovered ? accentBg : Colors.transparent);

    final textColor = widget.isActive
        ? theme.textTheme.bodyLarge?.color
        : (isDark ? Colors.grey[400] : Colors.grey[600]);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            IconTheme(
              data: IconThemeData(
                size: 20,
                color: textColor,
              ),
              child: widget.icon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (widget.isActive)
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

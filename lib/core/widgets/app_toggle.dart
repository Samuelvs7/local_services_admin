import 'package:flutter/material.dart';

/// Variant for the toggle button.
enum AppToggleVariant { defaultVariant, outline }

/// Size for the toggle button.
enum AppToggleSize { defaultSize, sm, lg }

/// A styled toggle button equivalent to shadcn/ui's Toggle.
///
/// A two-state button that can be on or off. Styling matches the
/// shadcn design system with hover effects and "on" state highlights.
class AppToggle extends StatefulWidget {
  final bool pressed;
  final ValueChanged<bool>? onPressedChange;
  final AppToggleVariant variant;
  final AppToggleSize size;
  final Widget child;
  final bool enabled;

  const AppToggle({
    super.key,
    required this.pressed,
    this.onPressedChange,
    this.variant = AppToggleVariant.defaultVariant,
    this.size = AppToggleSize.defaultSize,
    required this.child,
    this.enabled = true,
  });

  @override
  State<AppToggle> createState() => _AppToggleState();
}

class _AppToggleState extends State<AppToggle> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = _getBgColor(isDark, theme);
    final foregroundColor = _getForegroundColor(isDark, theme);
    final borderColor = _getBorderColor(isDark, theme);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
      child: GestureDetector(
        onTap: widget.enabled ? () => widget.onPressedChange?.call(!widget.pressed) : null,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: _getPadding(),
            height: _getHeight(),
            constraints: const BoxConstraints(minWidth: 40),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: widget.variant == AppToggleVariant.outline ? Border.all(color: borderColor) : null,
            ),
            child: Center(
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: widget.size == AppToggleSize.sm ? 12 : 14,
                  fontWeight: FontWeight.w500,
                  color: foregroundColor,
                ),
                child: IconTheme.merge(
                  data: IconThemeData(
                    size: widget.size == AppToggleSize.sm ? 16 : 18,
                    color: foregroundColor,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBgColor(bool isDark, ThemeData theme) {
    if (widget.pressed) {
      return isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51); // bg-accent
    }
    if (_hovered) {
      return isDark ? Colors.white.withAlpha(15) : Colors.grey.withAlpha(20); // hover:bg-muted
    }
    return Colors.transparent;
  }

  Color _getForegroundColor(bool isDark, ThemeData theme) {
    if (widget.pressed) {
      return isDark ? Colors.white : Colors.black; // text-accent-foreground
    }
    if (_hovered) {
      return isDark ? Colors.grey[300]! : Colors.grey[700]!; // hover:text-muted-foreground
    }
    return isDark ? Colors.white : Colors.black;
  }

  Color _getBorderColor(bool isDark, ThemeData theme) {
    return isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51); // border-input
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case AppToggleSize.sm:
        return const EdgeInsets.symmetric(horizontal: 10);
      case AppToggleSize.lg:
        return const EdgeInsets.symmetric(horizontal: 20);
      default:
        return const EdgeInsets.symmetric(horizontal: 12);
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case AppToggleSize.sm:
        return 36;
      case AppToggleSize.lg:
        return 44;
      default:
        return 40;
    }
  }
}

import 'package:flutter/material.dart';

/// A styled checkbox widget equivalent to shadcn/ui's Checkbox.
///
/// Supports checked, unchecked, and indeterminate (tristate) modes,
/// with proper focus ring, disabled state, and dark-theme styling.
class AppCheckbox extends StatefulWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final bool enabled;
  final double size;
  final Color? activeColor;
  final Color? checkColor;
  final Color? borderColor;
  final String? semanticLabel;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.enabled = true,
    this.size = 16,
    this.activeColor,
    this.checkColor,
    this.borderColor,
    this.semanticLabel,
  });

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.value == true || (widget.tristate && widget.value == null)) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AppCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isActive =
        widget.value == true || (widget.tristate && widget.value == null);
    if (isActive) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled || widget.onChanged == null) return;

    if (widget.tristate) {
      // Cycle: false -> true -> null -> false
      if (widget.value == false) {
        widget.onChanged!(true);
      } else if (widget.value == true) {
        widget.onChanged!(null);
      } else {
        widget.onChanged!(false);
      }
    } else {
      widget.onChanged!(!(widget.value ?? false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor =
        widget.activeColor ?? theme.colorScheme.primary;
    final onPrimaryColor =
        widget.checkColor ?? theme.colorScheme.onPrimary;
    final border = widget.borderColor ??
        (isDark
            ? Colors.white.withAlpha(51) // ~0.2 opacity
            : Colors.grey.withAlpha(128)); // ~0.5 opacity

    final isActive =
        widget.value == true || (widget.tristate && widget.value == null);
    final effectiveOpacity = widget.enabled ? 1.0 : 0.5;

    return Semantics(
      label: widget.semanticLabel,
      checked: widget.value,
      enabled: widget.enabled,
      child: Opacity(
        opacity: effectiveOpacity,
        child: FocusableActionDetector(
          enabled: widget.enabled,
          mouseCursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          onShowFocusHighlight: (focused) =>
              setState(() => _isFocused = focused),
          onShowHoverHighlight: (_) {},
          actions: <Type, Action<Intent>>{
            ActivateIntent:
                CallbackAction<ActivateIntent>(onInvoke: (_) {
                  _handleTap();
                  return null;
                }),
          },
          child: GestureDetector(
            onTap: _handleTap,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: isActive
                        ? primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isActive ? primaryColor : border,
                      width: 1.5,
                    ),
                    boxShadow: _isFocused
                        ? [
                            BoxShadow(
                              color: primaryColor.withAlpha(77), // ~0.3 opacity
                              blurRadius: 0,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: widget.value == null && widget.tristate
                          ? _IndeterminateIcon(
                              color: onPrimaryColor,
                              size: widget.size * 0.7,
                            )
                          : Icon(
                              Icons.check_rounded,
                              size: widget.size * 0.75,
                              color: onPrimaryColor,
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// The horizontal dash icon shown in indeterminate state.
class _IndeterminateIcon extends StatelessWidget {
  final Color color;
  final double size;

  const _IndeterminateIcon({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Container(
          width: size * 0.7,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}

/// A convenience widget that pairs an [AppCheckbox] with a tappable label,
/// similar to how checkboxes are commonly used with `<label>` in HTML.
class AppCheckboxWithLabel extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final Widget label;
  final bool tristate;
  final bool enabled;
  final double checkboxSize;
  final double gap;
  final CrossAxisAlignment alignment;

  const AppCheckboxWithLabel({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.tristate = false,
    this.enabled = true,
    this.checkboxSize = 16,
    this.gap = 8,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: enabled && onChanged != null
          ? () {
              if (tristate) {
                if (value == false) {
                  onChanged!(true);
                } else if (value == true) {
                  onChanged!(null);
                } else {
                  onChanged!(false);
                }
              } else {
                onChanged!(!(value ?? false));
              }
            }
          : null,
      child: MouseRegion(
        cursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: alignment,
          children: [
            AppCheckbox(
              value: value,
              onChanged: onChanged,
              tristate: tristate,
              enabled: enabled,
              size: checkboxSize,
            ),
            SizedBox(width: gap),
            DefaultTextStyle(
              style: theme.textTheme.bodyMedium!.copyWith(
                color: enabled
                    ? null
                    : theme.textTheme.bodyMedium?.color?.withAlpha(128),
                height: 1.2,
              ),
              child: label,
            ),
          ],
        ),
      ),
    );
  }
}

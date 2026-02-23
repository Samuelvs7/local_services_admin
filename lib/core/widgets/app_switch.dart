import 'package:flutter/material.dart';

/// A styled switch toggle equivalent to shadcn/ui's Switch.
///
/// 44×24 rounded track with a 20×20 sliding thumb, primary color when on,
/// muted when off, animated transition, focus ring, and disabled state.
///
/// ```dart
/// AppSwitch(value: _on, onChanged: (v) => setState(() => _on = v))
/// ```
class AppSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<AppSwitch> createState() => _AppSwitchState();
}

class _AppSwitchState extends State<AppSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _thumbPosition;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _thumbPosition = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.value) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant AppSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!widget.enabled) return;
    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final trackColorOff =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(64);

    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,

        child: GestureDetector(
          onTap: _toggle,
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.5,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _thumbPosition.value;

                final trackColor = Color.lerp(
                  trackColorOff,
                  theme.colorScheme.primary,
                  t,
                )!;

                return Container(
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: trackColor,
                    boxShadow: _focused
                        ? [
                            BoxShadow(
                              color:
                                  theme.colorScheme.primary.withAlpha(51),
                              blurRadius: 0,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Align(
                    alignment:
                        Alignment.lerp(
                          Alignment.centerLeft,
                          Alignment.centerRight,
                          t,
                        )!,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.scaffoldBackgroundColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(51),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
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

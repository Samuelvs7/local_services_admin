import 'package:flutter/material.dart';

/// A styled radio group equivalent to shadcn/ui's RadioGroup.
///
/// Renders a vertical list of radio items with a filled-circle indicator
/// for the selected value, focus ring, and disabled state support.
///
/// ```dart
/// AppRadioGroup<String>(
///   value: _selected,
///   onChanged: (v) => setState(() => _selected = v),
///   items: [
///     AppRadioGroupItem(value: 'default', label: 'Default'),
///     AppRadioGroupItem(value: 'comfortable', label: 'Comfortable'),
///     AppRadioGroupItem(value: 'compact', label: 'Compact'),
///   ],
/// )
/// ```
class AppRadioGroup<T> extends StatelessWidget {
  final T? value;
  final ValueChanged<T>? onChanged;
  final List<AppRadioGroupItem<T>> items;
  final double spacing;

  const AppRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.items,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _RadioRow<T>(
            item: items[i],
            selected: items[i].value == value,
            onTap: items[i].disabled || onChanged == null
                ? null
                : () => onChanged!(items[i].value),
          ),
          if (i < items.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}

/// Definition for a single radio item.
class AppRadioGroupItem<T> {
  final T value;
  final String label;
  final String? description;
  final bool disabled;

  const AppRadioGroupItem({
    required this.value,
    required this.label,
    this.description,
    this.disabled = false,
  });
}

// ---------------------------------------------------------------------------
// Internal radio row
// ---------------------------------------------------------------------------

class _RadioRow<T> extends StatefulWidget {
  final AppRadioGroupItem<T> item;
  final bool selected;
  final VoidCallback? onTap;

  const _RadioRow({
    required this.item,
    required this.selected,
    this.onTap,
  });

  @override
  State<_RadioRow<T>> createState() => _RadioRowState<T>();
}

class _RadioRowState<T> extends State<_RadioRow<T>>
    with SingleTickerProviderStateMixin {
  bool _focused = false;

  late AnimationController _dotController;
  late Animation<double> _dotScale;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _dotScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dotController, curve: Curves.easeOutCubic),
    );
    if (widget.selected) _dotController.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _RadioRow<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      widget.selected
          ? _dotController.forward()
          : _dotController.reverse();
    }
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDisabled = widget.item.disabled;

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: MouseRegion(
        cursor: isDisabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: Focus(
            onFocusChange: (focused) =>
                setState(() => _focused = focused),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: widget.item.description != null
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                // Radio circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.selected
                          ? theme.colorScheme.primary
                          : (isDark
                              ? Colors.white.withAlpha(51)
                              : Colors.grey.withAlpha(102)),
                      width: 1.5,
                    ),
                    // Focus ring
                    boxShadow: _focused
                        ? [
                            BoxShadow(
                              color:
                                  theme.colorScheme.primary.withAlpha(77),
                              blurRadius: 0,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: ScaleTransition(
                      scale: _dotScale,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Label + optional description
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.item.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      if (widget.item.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.item.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.grey[500]
                                : Colors.grey[400],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

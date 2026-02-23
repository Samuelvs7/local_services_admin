import 'package:flutter/material.dart';

/// A styled select dropdown equivalent to shadcn/ui's Select.
///
/// Renders a trigger that looks like a form input (40px, border, chevron)
/// and opens a scrollable list of items with check indicators.
///
/// ```dart
/// AppSelect<String>(
///   value: _selected,
///   placeholder: 'Select a fruit',
///   onChanged: (v) => setState(() => _selected = v),
///   items: [
///     AppSelectItem(value: 'apple', label: 'Apple'),
///     AppSelectItem(value: 'banana', label: 'Banana'),
///     AppSelectItem(value: 'cherry', label: 'Cherry'),
///   ],
/// )
/// ```
class AppSelect<T> extends StatefulWidget {
  final T? value;
  final String? placeholder;
  final ValueChanged<T>? onChanged;
  final List<AppSelectEntry<T>> items;
  final bool enabled;
  final double? width;

  const AppSelect({
    super.key,
    this.value,
    this.placeholder,
    this.onChanged,
    required this.items,
    this.enabled = true,
    this.width,
  });

  @override
  State<AppSelect<T>> createState() => _AppSelectState<T>();
}

class _AppSelectState<T> extends State<AppSelect<T>>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _close(immediate: true);
    _animController.dispose();
    super.dispose();
  }

  String? get _selectedLabel {
    for (final entry in widget.items) {
      if (entry is AppSelectItem<T> && entry.value == widget.value) {
        return entry.label;
      }
      if (entry is AppSelectGroup<T>) {
        for (final item in entry.items) {
          if (item.value == widget.value) return item.label;
        }
      }
    }
    return null;
  }

  void _toggle() {
    _isOpen ? _close() : _open();
  }

  void _open() {
    if (_isOpen || !widget.enabled) return;
    _isOpen = true;

    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward();
    setState(() {});
  }

  Future<void> _close({bool immediate = false}) async {
    if (!_isOpen) return;

    if (immediate) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
      return;
    }

    await _animController.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
    if (mounted) setState(() {});
  }

  void _selectValue(T value) {
    widget.onChanged?.call(value);
    _close();
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final borderColor =
            isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);
        final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;

        return Stack(
          children: [
            // Dismiss barrier
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _close(),
              ),
            ),

            // Dropdown content
            UnconstrainedBox(
              child: CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 4),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    alignment: Alignment.topCenter,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: 128,
                          maxWidth: widget.width ?? 320,
                          maxHeight: 384, // max-h-96
                        ),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(64),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: _buildItems(
                                  context, isDark, borderColor),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildItems(
      BuildContext context, bool isDark, Color borderColor) {
    final widgets = <Widget>[];

    for (final entry in widget.items) {
      if (entry is AppSelectItem<T>) {
        widgets.add(_SelectItemTile<T>(
          item: entry,
          isSelected: entry.value == widget.value,
          onTap: () => _selectValue(entry.value),
        ));
      } else if (entry is AppSelectGroup<T>) {
        // Group label
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 32, right: 8, top: 8, bottom: 4),
          child: Text(
            entry.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ));
        for (final item in entry.items) {
          widgets.add(_SelectItemTile<T>(
            item: item,
            isSelected: item.value == widget.value,
            onTap: () => _selectValue(item.value),
          ));
        }
      } else if (entry is AppSelectSeparator<T>) {
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Divider(
            height: 1,
            color: isDark
                ? Colors.white.withAlpha(18)
                : Colors.grey.withAlpha(38),
          ),
        ));
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = _isOpen
        ? theme.colorScheme.primary
        : (isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51));
    final borderWidth = _isOpen ? 1.5 : 1.0;

    final fillColor = isDark
        ? Colors.white.withAlpha(8)
        : Colors.grey.withAlpha(13);

    final label = _selectedLabel;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: widget.enabled ? _toggle : null,
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 40,
              width: widget.width,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: _isOpen
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(51),
                          blurRadius: 0,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Value or placeholder
                  Expanded(
                    child: Text(
                      label ?? widget.placeholder ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: label != null
                            ? theme.textTheme.bodyMedium?.color
                            : (isDark
                                ? Colors.grey[600]
                                : Colors.grey[400]),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Chevron
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Opacity(
                      opacity: 0.5,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Entry types
// ---------------------------------------------------------------------------

/// Base class for select entries.
sealed class AppSelectEntry<T> {
  const AppSelectEntry();
}

/// A selectable item — equivalent to `<SelectItem>`.
class AppSelectItem<T> extends AppSelectEntry<T> {
  final T value;
  final String label;
  final bool disabled;

  const AppSelectItem({
    required this.value,
    required this.label,
    this.disabled = false,
  });
}

/// A group of items with a label — equivalent to `<SelectGroup>` + `<SelectLabel>`.
class AppSelectGroup<T> extends AppSelectEntry<T> {
  final String label;
  final List<AppSelectItem<T>> items;

  const AppSelectGroup({
    required this.label,
    required this.items,
  });
}

/// A separator line — equivalent to `<SelectSeparator>`.
class AppSelectSeparator<T> extends AppSelectEntry<T> {
  const AppSelectSeparator();
}

// ---------------------------------------------------------------------------
// Item tile
// ---------------------------------------------------------------------------

class _SelectItemTile<T> extends StatefulWidget {
  final AppSelectItem<T> item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectItemTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SelectItemTile<T>> createState() => _SelectItemTileState<T>();
}

class _SelectItemTileState<T> extends State<_SelectItemTile<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = _hovered
        ? (isDark ? Colors.white.withAlpha(13) : Colors.grey.withAlpha(26))
        : Colors.transparent;

    return MouseRegion(
      cursor: widget.item.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.item.disabled ? null : widget.onTap,
        child: Opacity(
          opacity: widget.item.disabled ? 0.5 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                // Check indicator
                SizedBox(
                  width: 20,
                  child: widget.isSelected
                      ? Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: isDark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: const TextStyle(fontSize: 13),
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

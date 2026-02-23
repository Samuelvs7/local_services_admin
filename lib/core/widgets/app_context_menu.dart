import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// AppContextMenu — root wrapper, equivalent to <ContextMenu> + <ContextMenuTrigger>
// ---------------------------------------------------------------------------

/// Wraps a [child] and shows a styled context menu on right-click / long-press.
///
/// Pass the menu structure via [items]. Supports regular items, checkbox items,
/// radio groups, sub-menus, labels, separators, and shortcuts.
class AppContextMenu extends StatelessWidget {
  final Widget child;
  final List<AppContextMenuEntry> items;

  const AppContextMenu({
    super.key,
    required this.child,
    required this.items,
  });

  void _show(BuildContext context, Offset globalPosition) {
    _showContextMenu(
      context: context,
      position: globalPosition,
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (d) => _show(context, d.globalPosition),
      onLongPressStart: (d) => _show(context, d.globalPosition),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Internal — show the overlay menu
// ---------------------------------------------------------------------------

Future<void> _showContextMenu({
  required BuildContext context,
  required Offset position,
  required List<AppContextMenuEntry> items,
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final borderColor =
      isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);
  final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;

  final result = await showMenu<VoidCallback?>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx + 1,
      position.dy + 1,
    ),
    constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
    color: surfaceColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: borderColor),
    ),
    elevation: 8,
    shadowColor: Colors.black.withAlpha(100),
    items: items
        .map((entry) => entry._toPopupEntry(context, isDark, borderColor))
        .toList(),
  );

  // Execute the callback after the menu closes to avoid navigator conflicts.
  result?.call();
}

// ---------------------------------------------------------------------------
// AppContextMenuEntry — sealed base for all menu entry types
// ---------------------------------------------------------------------------

/// Base class for all context menu entries.
sealed class AppContextMenuEntry {
  const AppContextMenuEntry();

  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor);
}

// ---------------------------------------------------------------------------
// AppContextMenuItem — regular item
// ---------------------------------------------------------------------------

/// A standard menu item — equivalent to `<ContextMenuItem>`.
class AppContextMenuItem extends AppContextMenuEntry {
  final String label;
  final Widget? leading;
  final String? shortcut;
  final VoidCallback? onSelect;
  final bool disabled;
  final bool inset;
  final bool isDestructive;

  const AppContextMenuItem({
    required this.label,
    this.leading,
    this.shortcut,
    this.onSelect,
    this.disabled = false,
    this.inset = false,
    this.isDestructive = false,
  });

  @override
  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor) {
    final theme = Theme.of(context);

    return PopupMenuItem<VoidCallback?>(
      enabled: !disabled,
      value: onSelect,
      height: 32,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.only(
          left: inset ? 32 : 8,
          right: 8,
          top: 6,
          bottom: 6,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme(
                data: IconThemeData(
                  size: 16,
                  color: isDestructive
                      ? theme.colorScheme.error
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                child: leading!,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDestructive ? theme.colorScheme.error : null,
                ),
              ),
            ),
            if (shortcut != null) ...[
              const SizedBox(width: 16),
              Text(
                shortcut!,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.0,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppContextMenuCheckboxItem — item with a checkbox indicator
// ---------------------------------------------------------------------------

/// A menu item with a check indicator — equivalent to `<ContextMenuCheckboxItem>`.
class AppContextMenuCheckboxItem extends AppContextMenuEntry {
  final String label;
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final bool disabled;

  const AppContextMenuCheckboxItem({
    required this.label,
    required this.checked,
    this.onChanged,
    this.disabled = false,
  });

  @override
  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor) {
    return PopupMenuItem<VoidCallback?>(
      enabled: !disabled,
      value: onChanged != null ? () => onChanged!(!checked) : null,
      height: 32,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: checked
                  ? Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppContextMenuRadioGroup + AppContextMenuRadioItem
// ---------------------------------------------------------------------------

/// A group of radio items — equivalent to `<ContextMenuRadioGroup>`.
///
/// Each [AppContextMenuRadioItem] inside carries its own value. The group's
/// [value] determines which one shows the filled-circle indicator.
class AppContextMenuRadioGroup<T> extends AppContextMenuEntry {
  final T? value;
  final List<AppContextMenuRadioItem<T>> items;
  final ValueChanged<T>? onChanged;

  const AppContextMenuRadioGroup({
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor) {
    // We expand each radio item into its own PopupMenuItem.
    // Since _toPopupEntry returns a single entry, we wrap them in a
    // _MultiEntry helper.
    return _MultiPopupMenuEntry(
      children: items
          .map((item) => item._buildEntry(
                context,
                isDark,
                selected: item.value == value,
                onChanged: onChanged,
              ))
          .toList(),
    );
  }
}

/// A single radio item inside an [AppContextMenuRadioGroup].
class AppContextMenuRadioItem<T> {
  final String label;
  final T value;
  final bool disabled;

  const AppContextMenuRadioItem({
    required this.label,
    required this.value,
    this.disabled = false,
  });

  PopupMenuItem<VoidCallback?> _buildEntry(
    BuildContext context,
    bool isDark, {
    required bool selected,
    ValueChanged<T>? onChanged,
  }) {
    return PopupMenuItem<VoidCallback?>(
      enabled: !disabled,
      value: onChanged != null ? () => onChanged(value) : null,
      height: 32,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: selected
                  ? Icon(
                      Icons.circle,
                      size: 8,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppContextMenuLabel — non-interactive heading
// ---------------------------------------------------------------------------

/// A non-interactive label / heading — equivalent to `<ContextMenuLabel>`.
class AppContextMenuLabel extends AppContextMenuEntry {
  final String label;
  final bool inset;

  const AppContextMenuLabel({
    required this.label,
    this.inset = false,
  });

  @override
  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor) {
    return PopupMenuItem<VoidCallback?>(
      enabled: false,
      height: 28,
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.only(
          left: inset ? 32 : 8,
          right: 8,
          top: 6,
          bottom: 6,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.grey[300]
                : Colors.grey[800],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppContextMenuSeparator — horizontal divider line
// ---------------------------------------------------------------------------

/// A separator line — equivalent to `<ContextMenuSeparator>`.
class AppContextMenuSeparator extends AppContextMenuEntry {
  const AppContextMenuSeparator();

  @override
  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor) {
    return const PopupMenuDivider(height: 1);
  }
}

// ---------------------------------------------------------------------------
// AppContextMenuSub — sub-menu with nested items
// ---------------------------------------------------------------------------

/// A sub-menu trigger that opens a nested menu — equivalent to
/// `<ContextMenuSub>` + `<ContextMenuSubTrigger>` + `<ContextMenuSubContent>`.
class AppContextMenuSub extends AppContextMenuEntry {
  final String label;
  final Widget? leading;
  final List<AppContextMenuEntry> items;
  final bool inset;
  final bool disabled;

  const AppContextMenuSub({
    required this.label,
    this.leading,
    required this.items,
    this.inset = false,
    this.disabled = false,
  });

  @override
  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor) {
    return PopupMenuItem<VoidCallback?>(
      enabled: !disabled,
      height: 32,
      padding: EdgeInsets.zero,
      // When tapped, open a nested showMenu at the item's position.
      value: () => _openSubMenu(context),
      child: Padding(
        padding: EdgeInsets.only(
          left: inset ? 32 : 8,
          right: 8,
          top: 6,
          bottom: 6,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme(
                data: IconThemeData(
                  size: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                child: leading!,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13)),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _openSubMenu(BuildContext context) {
    // Position the sub-menu slightly offset from the cursor.
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;

    _showContextMenu(
      context: context,
      position: Offset(offset.dx + size.width, offset.dy),
      items: items,
    );
  }
}

// ---------------------------------------------------------------------------
// _MultiPopupMenuEntry — helper to expand a radio group into multiple entries
// ---------------------------------------------------------------------------

class _MultiPopupMenuEntry extends PopupMenuEntry<VoidCallback?> {
  final List<PopupMenuItem<VoidCallback?>> children;

  const _MultiPopupMenuEntry({required this.children});

  @override
  double get height =>
      children.fold(0.0, (sum, child) => sum + child.height);

  @override
  bool represents(VoidCallback? value) => false;

  @override
  State<_MultiPopupMenuEntry> createState() => _MultiPopupMenuEntryState();
}

class _MultiPopupMenuEntryState extends State<_MultiPopupMenuEntry> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.children,
    );
  }
}

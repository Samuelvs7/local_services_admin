import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// AppDropdownMenu — root wrapper, equivalent to
// <DropdownMenu> + <DropdownMenuTrigger> + <DropdownMenuContent>
// ---------------------------------------------------------------------------

/// Wraps a [trigger] widget and shows a styled dropdown menu on tap.
///
/// Structurally identical to [AppContextMenu] but activated by a regular
/// tap instead of right-click / long-press.
class AppDropdownMenu extends StatelessWidget {
  final Widget trigger;
  final List<AppDropdownMenuEntry> items;
  final Offset offset;

  const AppDropdownMenu({
    super.key,
    required this.trigger,
    required this.items,
    this.offset = const Offset(0, 4),
  });

  void _show(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _showDropdownMenu(
      context: context,
      position: Offset(
        position.dx + offset.dx,
        position.dy + size.height + offset.dy,
      ),
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _show(context),
      behavior: HitTestBehavior.opaque,
      child: trigger,
    );
  }
}

// ---------------------------------------------------------------------------
// Internal — show the overlay menu
// ---------------------------------------------------------------------------

Future<void> _showDropdownMenu({
  required BuildContext context,
  required Offset position,
  required List<AppDropdownMenuEntry> items,
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
    constraints: const BoxConstraints(minWidth: 128, maxWidth: 260),
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

  result?.call();
}

// ---------------------------------------------------------------------------
// AppDropdownMenuEntry — sealed base
// ---------------------------------------------------------------------------

/// Base class for all dropdown menu entries.
sealed class AppDropdownMenuEntry {
  const AppDropdownMenuEntry();

  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor);
}

// ---------------------------------------------------------------------------
// AppDropdownMenuItem — regular item
// ---------------------------------------------------------------------------

/// A standard menu item — equivalent to `<DropdownMenuItem>`.
class AppDropdownMenuItem extends AppDropdownMenuEntry {
  final String label;
  final Widget? leading;
  final String? shortcut;
  final VoidCallback? onSelect;
  final bool disabled;
  final bool inset;
  final bool isDestructive;

  const AppDropdownMenuItem({
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
              Opacity(
                opacity: 0.6,
                child: Text(
                  shortcut!,
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
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
// AppDropdownMenuCheckboxItem
// ---------------------------------------------------------------------------

/// A menu item with a check indicator — equivalent to `<DropdownMenuCheckboxItem>`.
class AppDropdownMenuCheckboxItem extends AppDropdownMenuEntry {
  final String label;
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final bool disabled;

  const AppDropdownMenuCheckboxItem({
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
// AppDropdownMenuRadioGroup + AppDropdownMenuRadioItem
// ---------------------------------------------------------------------------

/// A group of radio items — equivalent to `<DropdownMenuRadioGroup>`.
class AppDropdownMenuRadioGroup<T> extends AppDropdownMenuEntry {
  final T? value;
  final List<AppDropdownMenuRadioItem<T>> items;
  final ValueChanged<T>? onChanged;

  const AppDropdownMenuRadioGroup({
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor) {
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

/// A single radio item inside an [AppDropdownMenuRadioGroup].
class AppDropdownMenuRadioItem<T> {
  final String label;
  final T value;
  final bool disabled;

  const AppDropdownMenuRadioItem({
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
// AppDropdownMenuLabel
// ---------------------------------------------------------------------------

/// A non-interactive label / heading — equivalent to `<DropdownMenuLabel>`.
class AppDropdownMenuLabel extends AppDropdownMenuEntry {
  final String label;
  final bool inset;

  const AppDropdownMenuLabel({
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
            color: isDark ? Colors.grey[300] : Colors.grey[800],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppDropdownMenuSeparator
// ---------------------------------------------------------------------------

/// A separator line — equivalent to `<DropdownMenuSeparator>`.
class AppDropdownMenuSeparator extends AppDropdownMenuEntry {
  const AppDropdownMenuSeparator();

  @override
  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor) {
    return const PopupMenuDivider(height: 1);
  }
}

// ---------------------------------------------------------------------------
// AppDropdownMenuSub — sub-menu with nested items
// ---------------------------------------------------------------------------

/// A sub-menu trigger that opens a nested menu — equivalent to
/// `<DropdownMenuSub>` + `<DropdownMenuSubTrigger>` + `<DropdownMenuSubContent>`.
class AppDropdownMenuSub extends AppDropdownMenuEntry {
  final String label;
  final Widget? leading;
  final List<AppDropdownMenuEntry> items;
  final bool inset;
  final bool disabled;

  const AppDropdownMenuSub({
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
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;

    _showDropdownMenu(
      context: context,
      position: Offset(offset.dx + size.width, offset.dy),
      items: items,
    );
  }
}

// ---------------------------------------------------------------------------
// _MultiPopupMenuEntry — helper for radio groups
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

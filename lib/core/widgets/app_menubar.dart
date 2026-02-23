import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// AppMenubar — horizontal bar with trigger buttons
// ---------------------------------------------------------------------------

/// A styled menubar equivalent to shadcn/ui's Menubar.
///
/// Renders a horizontal row of [AppMenubarMenu] items, each with a trigger
/// that opens a dropdown of menu entries.
///
/// ```dart
/// AppMenubar(
///   menus: [
///     AppMenubarMenu(label: 'File', items: [
///       AppMenubarItem(label: 'New', shortcut: '⌘N', onSelect: () {}),
///       AppMenubarSeparator(),
///       AppMenubarItem(label: 'Quit', shortcut: '⌘Q', onSelect: () {}),
///     ]),
///     AppMenubarMenu(label: 'Edit', items: [...]),
///   ],
/// )
/// ```
class AppMenubar extends StatelessWidget {
  final List<AppMenubarMenu> menus;

  const AppMenubar({super.key, required this.menus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);

    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < menus.length; i++) ...[
            _MenubarTrigger(menu: menus[i]),
            if (i < menus.length - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppMenubarMenu — a single top-level menu definition
// ---------------------------------------------------------------------------

/// Defines one top-level menu in the bar (e.g. "File", "Edit").
class AppMenubarMenu {
  final String label;
  final List<AppMenubarEntry> items;

  const AppMenubarMenu({
    required this.label,
    required this.items,
  });
}

// ---------------------------------------------------------------------------
// Trigger button for each menu
// ---------------------------------------------------------------------------

class _MenubarTrigger extends StatelessWidget {
  final AppMenubarMenu menu;

  const _MenubarTrigger({required this.menu});

  void _showMenu(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);
    final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;

    _showMenubarDropdown(
      context: context,
      position: Offset(position.dx, position.dy + size.height + 8),
      items: menu.items,
      surfaceColor: surfaceColor,
      borderColor: borderColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: () => _showMenu(context),
        borderRadius: BorderRadius.circular(4),
        hoverColor: isDark
            ? Colors.white.withAlpha(13)
            : Colors.grey.withAlpha(26),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            menu.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Internal — show the dropdown for a menu
// ---------------------------------------------------------------------------

Future<void> _showMenubarDropdown({
  required BuildContext context,
  required Offset position,
  required List<AppMenubarEntry> items,
  required Color surfaceColor,
  required Color borderColor,
}) async {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  final result = await showMenu<VoidCallback?>(
    context: context,
    position: RelativeRect.fromLTRB(
      position.dx,
      position.dy,
      position.dx + 1,
      position.dy + 1,
    ),
    constraints: const BoxConstraints(minWidth: 192, maxWidth: 280),
    color: surfaceColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(color: borderColor),
    ),
    elevation: 8,
    shadowColor: Colors.black.withAlpha(100),
    items: items
        .map((e) => e._toPopupEntry(context, isDark, borderColor))
        .toList(),
  );

  result?.call();
}

// ---------------------------------------------------------------------------
// AppMenubarEntry — sealed base for all menu entry types
// ---------------------------------------------------------------------------

/// Base class for all menubar dropdown entries.
sealed class AppMenubarEntry {
  const AppMenubarEntry();

  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor);
}

// ---------------------------------------------------------------------------
// AppMenubarItem — regular item
// ---------------------------------------------------------------------------

/// A standard menu item — equivalent to `<MenubarItem>`.
class AppMenubarItem extends AppMenubarEntry {
  final String label;
  final Widget? leading;
  final String? shortcut;
  final VoidCallback? onSelect;
  final bool disabled;
  final bool inset;

  const AppMenubarItem({
    required this.label,
    this.leading,
    this.shortcut,
    this.onSelect,
    this.disabled = false,
    this.inset = false,
  });

  @override
  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor) {
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
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                child: leading!,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13)),
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
// AppMenubarCheckboxItem
// ---------------------------------------------------------------------------

/// A menu item with a check indicator — equivalent to `<MenubarCheckboxItem>`.
class AppMenubarCheckboxItem extends AppMenubarEntry {
  final String label;
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final bool disabled;

  const AppMenubarCheckboxItem({
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
                  ? Icon(Icons.check_rounded,
                      size: 16,
                      color: isDark ? Colors.grey[300] : Colors.grey[700])
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
// AppMenubarRadioGroup + AppMenubarRadioItem
// ---------------------------------------------------------------------------

/// A group of radio items — equivalent to `<MenubarRadioGroup>`.
class AppMenubarRadioGroup<T> extends AppMenubarEntry {
  final T? value;
  final List<AppMenubarRadioItem<T>> items;
  final ValueChanged<T>? onChanged;

  const AppMenubarRadioGroup({
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

/// A single radio item inside an [AppMenubarRadioGroup].
class AppMenubarRadioItem<T> {
  final String label;
  final T value;
  final bool disabled;

  const AppMenubarRadioItem({
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
                  ? Icon(Icons.circle,
                      size: 8,
                      color: isDark ? Colors.grey[300] : Colors.grey[700])
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
// AppMenubarLabel
// ---------------------------------------------------------------------------

/// A non-interactive label — equivalent to `<MenubarLabel>`.
class AppMenubarLabel extends AppMenubarEntry {
  final String label;
  final bool inset;

  const AppMenubarLabel({required this.label, this.inset = false});

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
// AppMenubarSeparator
// ---------------------------------------------------------------------------

/// A separator — equivalent to `<MenubarSeparator>`.
class AppMenubarSeparator extends AppMenubarEntry {
  const AppMenubarSeparator();

  @override
  PopupMenuEntry<VoidCallback?> _toPopupEntry(
      BuildContext context, bool isDark, Color borderColor) {
    return const PopupMenuDivider(height: 1);
  }
}

// ---------------------------------------------------------------------------
// AppMenubarSub — sub-menu
// ---------------------------------------------------------------------------

/// Sub-menu trigger — equivalent to
/// `<MenubarSub>` + `<MenubarSubTrigger>` + `<MenubarSubContent>`.
class AppMenubarSub extends AppMenubarEntry {
  final String label;
  final Widget? leading;
  final List<AppMenubarEntry> items;
  final bool inset;
  final bool disabled;

  const AppMenubarSub({
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
          left: inset ? 32 : 8, right: 8, top: 6, bottom: 6),
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
            Icon(Icons.chevron_right_rounded,
                size: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _openSubMenu(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;

    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);
    final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;

    _showMenubarDropdown(
      context: context,
      position: Offset(offset.dx + size.width, offset.dy),
      items: items,
      surfaceColor: surfaceColor,
      borderColor: borderColor,
    );
  }
}

// ---------------------------------------------------------------------------
// _MultiPopupMenuEntry helper
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

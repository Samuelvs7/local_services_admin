import 'package:flutter/material.dart';

/// Root command palette container — equivalent to shadcn/ui's `<Command>`.
///
/// Provides a composable structure: wrap [AppCommandInput], [AppCommandList],
/// [AppCommandEmpty], [AppCommandGroup], etc. inside this widget.
class AppCommand extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;

  const AppCommand({
    super.key,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Shows a [AppCommand] inside a dialog — equivalent to `<CommandDialog>`.
class AppCommandDialog extends StatelessWidget {
  final Widget child;
  final bool open;
  final VoidCallback? onClose;

  const AppCommandDialog({
    super.key,
    required this.child,
    this.open = true,
    this.onClose,
  });

  /// Convenience method to show the command dialog.
  static Future<void> show(
    BuildContext context, {
    required Widget child,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Search input row with a search icon — equivalent to `<CommandInput>`.
class AppCommandInput extends StatelessWidget {
  final TextEditingController? controller;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const AppCommandInput({
    super.key,
    this.controller,
    this.placeholder = 'Type a command or search...',
    this.onChanged,
    this.autofocus = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 16,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                isDense: true,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

/// Scrollable list area for command items — equivalent to `<CommandList>`.
class AppCommandList extends StatelessWidget {
  final List<Widget> children;
  final double maxHeight;

  const AppCommandList({
    super.key,
    required this.children,
    this.maxHeight = 300,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: children,
      ),
    );
  }
}

/// "No results" message — equivalent to `<CommandEmpty>`.
class AppCommandEmpty extends StatelessWidget {
  final String message;

  const AppCommandEmpty({
    super.key,
    this.message = 'No results found.',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}

/// A group of items with an optional heading — equivalent to `<CommandGroup>`.
class AppCommandGroup extends StatelessWidget {
  final String? heading;
  final List<Widget> children;

  const AppCommandGroup({
    super.key,
    this.heading,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (heading != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                heading!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

/// A horizontal separator line — equivalent to `<CommandSeparator>`.
class AppCommandSeparator extends StatelessWidget {
  const AppCommandSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      color: isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51),
    );
  }
}

/// A single selectable item — equivalent to `<CommandItem>`.
class AppCommandItem extends StatelessWidget {
  final Widget? leading;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onSelect;
  final bool disabled;
  final bool selected;

  const AppCommandItem({
    super.key,
    this.leading,
    required this.child,
    this.trailing,
    this.onSelect,
    this.disabled = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedColor = isDark
        ? Colors.white.withAlpha(20)
        : Colors.grey.withAlpha(30);
    final hoverColor = isDark
        ? Colors.white.withAlpha(13)
        : Colors.grey.withAlpha(26);

    return Material(
      color: selected ? selectedColor : Colors.transparent,
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: disabled ? null : onSelect,
        borderRadius: BorderRadius.circular(4),
        hoverColor: hoverColor,
        child: Opacity(
          opacity: disabled ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                  child: DefaultTextStyle(
                    style: theme.textTheme.bodyMedium!.copyWith(fontSize: 14),
                    child: child,
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Keyboard shortcut label — equivalent to `<CommandShortcut>`.
class AppCommandShortcut extends StatelessWidget {
  final String shortcut;

  const AppCommandShortcut({
    super.key,
    required this.shortcut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      shortcut,
      style: TextStyle(
        fontSize: 12,
        letterSpacing: 1.2,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
    );
  }
}

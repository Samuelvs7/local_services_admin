import 'package:flutter/material.dart';

/// A styled table root equivalent to shadcn/ui's Table.
///
/// Wraps a column of table sections in a scrollable horizontal viewport.
///
/// ```dart
/// AppTable(
///   children: [
///     AppTableHeader(children: [...]),
///     AppTableBody(children: [...]),
///   ],
/// )
/// ```
class AppTable extends StatelessWidget {
  final List<Widget> children;
  final double? minWidth;

  const AppTable({
    super.key,
    required this.children,
    this.minWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth ?? MediaQuery.of(context).size.width,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// Styled table header equivalent to shadcn/ui's TableHeader.
class AppTableHeader extends StatelessWidget {
  final List<AppTableRow> children;

  const AppTableHeader({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// Styled table body equivalent to shadcn/ui's TableBody.
class AppTableBody extends StatelessWidget {
  final List<AppTableRow> children;

  const AppTableBody({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

/// Styled table row equivalent to shadcn/ui's TableRow.
class AppTableRow extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback? onTap;
  final bool selected;

  const AppTableRow({
    super.key,
    required this.children,
    this.onTap,
    this.selected = false,
  });

  @override
  State<AppTableRow> createState() => _AppTableRowState();
}

class _AppTableRowState extends State<AppTableRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);

    final hoverColor = isDark
        ? Colors.white.withAlpha(8)
        : Colors.grey.withAlpha(13);

    final selectedColor = isDark
        ? Colors.white.withAlpha(18)
        : Colors.grey.withAlpha(38);

    final bgColor = widget.selected
        ? selectedColor
        : (_hovered ? hoverColor : Colors.transparent);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              bottom: BorderSide(color: borderColor),
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }
}

/// Styled table head cell (header) equivalent to shadcn/ui's TableHead.
class AppTableHead extends StatelessWidget {
  final Widget child;
  final int flex;
  final double? width;
  final Alignment alignment;

  const AppTableHead({
    super.key,
    required this.child,
    this.flex = 1,
    this.width,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Container(
      height: 48, // h-12 in tailwind is 48px
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: alignment,
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
        child: child,
      ),
    );

    return width != null
        ? SizedBox(width: width, child: content)
        : Expanded(flex: flex, child: content);
  }
}

/// Styled table cell equivalent to shadcn/ui's TableCell.
class AppTableCell extends StatelessWidget {
  final Widget child;
  final int flex;
  final double? width;
  final Alignment alignment;

  const AppTableCell({
    super.key,
    required this.child,
    this.flex = 1,
    this.width,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      alignment: alignment,
      child: DefaultTextStyle(
        style: theme.textTheme.bodyMedium!.copyWith(fontSize: 14),
        child: child,
      ),
    );

    return width != null
        ? SizedBox(width: width, child: content)
        : Expanded(flex: flex, child: content);
  }
}

/// Styled table footer equivalent to shadcn/ui's TableFooter.
class AppTableFooter extends StatelessWidget {
  final List<Widget> children;

  const AppTableFooter({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? Colors.white.withAlpha(8)
        : Colors.grey.withAlpha(13);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51),
          ),
        ),
      ),
      child: Row(
        children: children,
      ),
    );
  }
}

/// Styled table caption equivalent to shadcn/ui's TableCaption.
class AppTableCaption extends StatelessWidget {
  final String text;

  const AppTableCaption({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.grey[500] : Colors.grey[600],
        ),
      ),
    );
  }
}

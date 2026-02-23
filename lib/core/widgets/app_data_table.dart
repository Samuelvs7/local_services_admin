import 'package:flutter/material.dart';

/// Defines a single column in an [AppDataTable].
///
/// [accessor] can be either a key string to look up in a Map-based row,
/// or a builder function that returns a widget for full custom rendering.
class AppDataColumn<T> {
  final String header;
  final Widget Function(T row) cellBuilder;
  final double? width;
  final Alignment alignment;

  /// Creates a column with a custom cell builder.
  const AppDataColumn({
    required this.header,
    required this.cellBuilder,
    this.width,
    this.alignment = Alignment.centerLeft,
  });
}

/// A styled data table widget equivalent to shadcn/ui's DataTable.
///
/// Renders a scrollable table with typed rows, styled header, hover effects,
/// optional row tap handler, and an empty-state message.
///
/// ```dart
/// AppDataTable<User>(
///   columns: [
///     AppDataColumn(header: 'Name', cellBuilder: (u) => Text(u.name)),
///     AppDataColumn(header: 'Email', cellBuilder: (u) => Text(u.email)),
///   ],
///   data: users,
///   onRowTap: (user) => print(user.id),
/// )
/// ```
class AppDataTable<T> extends StatelessWidget {
  final List<AppDataColumn<T>> columns;
  final List<T> data;
  final ValueChanged<T>? onRowTap;
  final String emptyMessage;
  final bool showHeader;
  final double rowHeight;
  final EdgeInsets cellPadding;
  final ScrollController? scrollController;

  const AppDataTable({
    super.key,
    required this.columns,
    required this.data,
    this.onRowTap,
    this.emptyMessage = 'No records found.',
    this.showHeader = true,
    this.rowHeight = 48,
    this.cellPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);
    final headerTextColor = isDark ? Colors.grey[500] : Colors.grey[400];
    final hoverColor = isDark
        ? Colors.white.withAlpha(8)
        : Colors.grey.withAlpha(15);

    return Scrollbar(
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          // Ensure the table fills at least the available width.
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              if (showHeader)
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: borderColor),
                    ),
                  ),
                  child: Row(
                    children: columns.map((col) {
                      return _HeaderCell(
                        text: col.header,
                        width: col.width,
                        alignment: col.alignment,
                        padding: cellPadding,
                        textColor: headerTextColor,
                      );
                    }).toList(),
                  ),
                ),

              // ── Body ──
              if (data.isEmpty)
                _EmptyRow(
                  message: emptyMessage,
                  textColor: headerTextColor,
                  columnCount: columns.length,
                  padding: cellPadding,
                )
              else
                ...data.map((row) {
                  return _DataRow<T>(
                    row: row,
                    columns: columns,
                    onTap: onRowTap,
                    cellPadding: cellPadding,
                    borderColor: borderColor.withAlpha((borderColor.a * 255).round() ~/ 2),
                    hoverColor: hoverColor,
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header cell
// ---------------------------------------------------------------------------

class _HeaderCell extends StatelessWidget {
  final String text;
  final double? width;
  final Alignment alignment;
  final EdgeInsets padding;
  final Color? textColor;

  const _HeaderCell({
    required this.text,
    this.width,
    required this.alignment,
    required this.padding,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      padding: padding,
      alignment: alignment,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );

    return width != null
        ? SizedBox(width: width, child: child)
        : Expanded(child: child);
  }
}

// ---------------------------------------------------------------------------
// Data row
// ---------------------------------------------------------------------------

class _DataRow<T> extends StatefulWidget {
  final T row;
  final List<AppDataColumn<T>> columns;
  final ValueChanged<T>? onTap;
  final EdgeInsets cellPadding;
  final Color borderColor;
  final Color hoverColor;

  const _DataRow({
    required this.row,
    required this.columns,
    this.onTap,
    required this.cellPadding,
    required this.borderColor,
    required this.hoverColor,
  });

  @override
  State<_DataRow<T>> createState() => _DataRowState<T>();
}

class _DataRowState<T> extends State<_DataRow<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap != null ? () => widget.onTap!(widget.row) : null,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? widget.hoverColor : Colors.transparent,
            border: Border(
              bottom: BorderSide(color: widget.borderColor),
            ),
          ),
          child: Row(
            children: widget.columns.map((col) {
              final cellContent = col.cellBuilder(widget.row);
              final cell = Container(
                padding: widget.cellPadding,
                alignment: col.alignment,
                child: DefaultTextStyle(
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontSize: 14),
                  child: cellContent,
                ),
              );

              return col.width != null
                  ? SizedBox(width: col.width, child: cell)
                  : Expanded(child: cell);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state row
// ---------------------------------------------------------------------------

class _EmptyRow extends StatelessWidget {
  final String message;
  final Color? textColor;
  final int columnCount;
  final EdgeInsets padding;

  const _EmptyRow({
    required this.message,
    this.textColor,
    required this.columnCount,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

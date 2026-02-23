import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A styled pagination widget equivalent to shadcn/ui's Pagination.
///
/// Renders Previous / page numbers / Next with automatic ellipsis for
/// large page counts.
///
/// ```dart
/// AppPagination(
///   currentPage: 3,
///   totalPages: 10,
///   onPageChanged: (page) => setState(() => _page = page),
/// )
/// ```
class AppPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  /// Max visible page buttons (excluding prev/next/ellipsis).
  final int maxVisible;

  const AppPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.maxVisible = 5,
  });

  List<_PageSlot> _buildSlots() {
    if (totalPages <= maxVisible) {
      return List.generate(
          totalPages, (i) => _PageSlot.page(i + 1));
    }

    final slots = <_PageSlot>[];
    final half = maxVisible ~/ 2;

    // Always show first page
    slots.add(_PageSlot.page(1));

    int start = math.max(2, currentPage - half + 1);
    int end = math.min(totalPages - 1, currentPage + half - 1);

    // Adjust window to maintain constant visible count
    if (currentPage <= half + 1) {
      end = math.min(totalPages - 1, maxVisible - 1);
    }
    if (currentPage >= totalPages - half) {
      start = math.max(2, totalPages - maxVisible + 2);
    }

    // Leading ellipsis
    if (start > 2) {
      slots.add(_PageSlot.ellipsis());
    }

    // Middle pages
    for (int i = start; i <= end; i++) {
      slots.add(_PageSlot.page(i));
    }

    // Trailing ellipsis
    if (end < totalPages - 1) {
      slots.add(_PageSlot.ellipsis());
    }

    // Always show last page
    slots.add(_PageSlot.page(totalPages));

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final slots = _buildSlots();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous
        _PaginationPrevNext(
          label: 'Previous',
          icon: Icons.chevron_left_rounded,
          iconFirst: true,
          enabled: currentPage > 1,
          onTap: () => onPageChanged(currentPage - 1),
        ),

        const SizedBox(width: 4),

        // Page slots
        for (final slot in slots) ...[
          if (slot.isEllipsis)
            const _PaginationEllipsis()
          else
            _PaginationPageButton(
              page: slot.page!,
              isActive: slot.page == currentPage,
              onTap: () => onPageChanged(slot.page!),
            ),
          const SizedBox(width: 4),
        ],

        // Next
        _PaginationPrevNext(
          label: 'Next',
          icon: Icons.chevron_right_rounded,
          iconFirst: false,
          enabled: currentPage < totalPages,
          onTap: () => onPageChanged(currentPage + 1),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Internal slot model
// ---------------------------------------------------------------------------

class _PageSlot {
  final int? page;
  final bool isEllipsis;

  const _PageSlot.page(this.page) : isEllipsis = false;
  const _PageSlot.ellipsis()
      : page = null,
        isEllipsis = true;
}

// ---------------------------------------------------------------------------
// Page number button
// ---------------------------------------------------------------------------

class _PaginationPageButton extends StatefulWidget {
  final int page;
  final bool isActive;
  final VoidCallback onTap;

  const _PaginationPageButton({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_PaginationPageButton> createState() => _PaginationPageButtonState();
}

class _PaginationPageButtonState extends State<_PaginationPageButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);

    Color bgColor;
    if (widget.isActive) {
      bgColor = isDark
          ? Colors.white.withAlpha(13)
          : Colors.grey.withAlpha(26);
    } else if (_hovered) {
      bgColor = isDark
          ? Colors.white.withAlpha(8)
          : Colors.grey.withAlpha(18);
    } else {
      bgColor = Colors.transparent;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
            border: widget.isActive
                ? Border.all(color: borderColor)
                : null,
          ),
          child: Text(
            '${widget.page}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight:
                  widget.isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ellipsis indicator
// ---------------------------------------------------------------------------

class _PaginationEllipsis extends StatelessWidget {
  const _PaginationEllipsis();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 36,
      height: 36,
      child: Center(
        child: Icon(
          Icons.more_horiz_rounded,
          size: 16,
          color: isDark ? Colors.grey[500] : Colors.grey[400],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Previous / Next button
// ---------------------------------------------------------------------------

class _PaginationPrevNext extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool iconFirst;
  final bool enabled;
  final VoidCallback onTap;

  const _PaginationPrevNext({
    required this.label,
    required this.icon,
    required this.iconFirst,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_PaginationPrevNext> createState() => _PaginationPrevNextState();
}

class _PaginationPrevNextState extends State<_PaginationPrevNext> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = widget.enabled
        ? (isDark ? Colors.grey[300] : Colors.grey[700])
        : (isDark ? Colors.grey[700] : Colors.grey[300]);

    final bgColor = _hovered && widget.enabled
        ? (isDark ? Colors.white.withAlpha(8) : Colors.grey.withAlpha(18))
        : Colors.transparent;

    final iconWidget = Icon(widget.icon, size: 16, color: color);
    final textWidget = Text(
      widget.label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          padding: EdgeInsets.only(
            left: widget.iconFirst ? 8 : 12,
            right: widget.iconFirst ? 12 : 8,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.iconFirst
                ? [iconWidget, const SizedBox(width: 4), textWidget]
                : [textWidget, const SizedBox(width: 4), iconWidget],
          ),
        ),
      ),
    );
  }
}

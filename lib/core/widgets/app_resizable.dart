import 'package:flutter/material.dart';

/// Direction for the resizable panel group.
enum ResizableDirection { horizontal, vertical }

/// A resizable panel group equivalent to shadcn/ui's ResizablePanelGroup.
///
/// Lays out [panels] separated by draggable handles. Each panel has
/// an [initialRatio] (0–1) that determines its share of the available space.
///
/// ```dart
/// AppResizablePanelGroup(
///   direction: ResizableDirection.horizontal,
///   panels: [
///     AppResizablePanel(initialRatio: 0.35, child: SideBar()),
///     AppResizablePanel(initialRatio: 0.65, child: MainContent()),
///   ],
/// )
/// ```
class AppResizablePanelGroup extends StatefulWidget {
  final ResizableDirection direction;
  final List<AppResizablePanel> panels;
  final bool withHandle;

  const AppResizablePanelGroup({
    super.key,
    this.direction = ResizableDirection.horizontal,
    required this.panels,
    this.withHandle = false,
  });

  @override
  State<AppResizablePanelGroup> createState() =>
      _AppResizablePanelGroupState();
}

class _AppResizablePanelGroupState extends State<AppResizablePanelGroup> {
  late List<double> _ratios;

  @override
  void initState() {
    super.initState();
    _initRatios();
  }

  @override
  void didUpdateWidget(covariant AppResizablePanelGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.panels.length != widget.panels.length) {
      _initRatios();
    }
  }

  void _initRatios() {
    _ratios =
        widget.panels.map((p) => p.initialRatio).toList();

    // Normalise so they sum to 1
    final sum = _ratios.fold(0.0, (a, b) => a + b);
    if (sum > 0) {
      for (int i = 0; i < _ratios.length; i++) {
        _ratios[i] /= sum;
      }
    }
  }

  bool get _isHorizontal =>
      widget.direction == ResizableDirection.horizontal;

  void _onDrag(int handleIndex, double delta, double totalSize) {
    if (totalSize <= 0) return;

    final deltaRatio = delta / totalSize;
    final leftIdx = handleIndex;
    final rightIdx = handleIndex + 1;

    final minRatio = widget.panels[leftIdx].minRatio;
    final maxRatioLeft = widget.panels[leftIdx].maxRatio;
    final minRatioRight = widget.panels[rightIdx].minRatio;
    final maxRatioRight = widget.panels[rightIdx].maxRatio;

    double newLeft = _ratios[leftIdx] + deltaRatio;
    double newRight = _ratios[rightIdx] - deltaRatio;

    // Clamp
    if (newLeft < minRatio) {
      newRight += (minRatio - newLeft);
      newLeft = minRatio;
    }
    if (newRight < minRatioRight) {
      newLeft += (minRatioRight - newRight);
      newRight = minRatioRight;
    }
    if (newLeft > maxRatioLeft) {
      newRight += (newLeft - maxRatioLeft);
      newLeft = maxRatioLeft;
    }
    if (newRight > maxRatioRight) {
      newLeft += (newRight - maxRatioRight);
      newRight = maxRatioRight;
    }

    setState(() {
      _ratios[leftIdx] = newLeft;
      _ratios[rightIdx] = newRight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSize = _isHorizontal
            ? constraints.maxWidth
            : constraints.maxHeight;

        final children = <Widget>[];

        for (int i = 0; i < widget.panels.length; i++) {
          // Panel
          final panelSize = _ratios[i] * totalSize;

          children.add(
            SizedBox(
              width: _isHorizontal ? panelSize : null,
              height: _isHorizontal ? null : panelSize,
              child: widget.panels[i].child,
            ),
          );

          // Handle between panels
          if (i < widget.panels.length - 1) {
            children.add(
              _ResizableHandle(
                direction: widget.direction,
                withHandle: widget.withHandle,
                onDrag: (delta) => _onDrag(i, delta, totalSize),
              ),
            );
          }
        }

        return _isHorizontal
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              );
      },
    );
  }
}

/// Definition for a single panel inside an [AppResizablePanelGroup].
class AppResizablePanel {
  final double initialRatio;
  final double minRatio;
  final double maxRatio;
  final Widget child;

  const AppResizablePanel({
    required this.initialRatio,
    this.minRatio = 0.1,
    this.maxRatio = 0.9,
    required this.child,
  });
}

// ---------------------------------------------------------------------------
// Drag handle
// ---------------------------------------------------------------------------

class _ResizableHandle extends StatefulWidget {
  final ResizableDirection direction;
  final bool withHandle;
  final ValueChanged<double> onDrag;

  const _ResizableHandle({
    required this.direction,
    required this.withHandle,
    required this.onDrag,
  });

  @override
  State<_ResizableHandle> createState() => _ResizableHandleState();
}

class _ResizableHandleState extends State<_ResizableHandle> {
  bool _hovered = false;
  bool _dragging = false;

  bool get _isHorizontal =>
      widget.direction == ResizableDirection.horizontal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);
    final activeColor = theme.colorScheme.primary.withAlpha(128);

    final lineColor =
        _dragging ? activeColor : (_hovered ? activeColor : borderColor);

    return MouseRegion(
      cursor: _isHorizontal
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.resizeRow,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onPanStart: (_) => setState(() => _dragging = true),
        onPanEnd: (_) => setState(() => _dragging = false),
        onPanCancel: () => setState(() => _dragging = false),
        onPanUpdate: (details) {
          widget.onDrag(
            _isHorizontal ? details.delta.dx : details.delta.dy,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: _isHorizontal ? (_dragging ? 3 : 1) : double.infinity,
          height: _isHorizontal ? double.infinity : (_dragging ? 3 : 1),
          color: lineColor,
          child: widget.withHandle
              ? Center(child: _GripIcon(isHorizontal: _isHorizontal))
              : null,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grip icon overlay
// ---------------------------------------------------------------------------

class _GripIcon extends StatelessWidget {
  final bool isHorizontal;

  const _GripIcon({required this.isHorizontal});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor =
        isDark ? Colors.white.withAlpha(38) : Colors.grey.withAlpha(77);

    return Transform.rotate(
      angle: isHorizontal ? 0 : 1.5708, // 90° for vertical
      child: Container(
        width: 12,
        height: 16,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1F2937) : Colors.grey[200],
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(isDark),
              const SizedBox(height: 2),
              _dot(isDark),
              const SizedBox(height: 2),
              _dot(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 2,
          height: 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
        ),
        const SizedBox(width: 2),
        Container(
          width: 2,
          height: 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

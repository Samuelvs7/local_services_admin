import 'package:flutter/material.dart';

/// A styled popover widget equivalent to shadcn/ui's Popover.
///
/// Shows a content panel anchored to a [trigger] widget on tap,
/// with fade + scale animation. Dismissed by tapping outside.
///
/// ```dart
/// AppPopover(
///   trigger: AppButton(label: 'Open', onPressed: null),
///   content: Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Popover content'),
///   ),
/// )
/// ```
class AppPopover extends StatefulWidget {
  final Widget trigger;
  final Widget content;
  final double contentWidth;
  final double sideOffset;
  final AppPopoverAlign align;
  final bool barrierDismissible;

  const AppPopover({
    super.key,
    required this.trigger,
    required this.content,
    this.contentWidth = 288, // w-72
    this.sideOffset = 4,
    this.align = AppPopoverAlign.center,
    this.barrierDismissible = true,
  });

  @override
  State<AppPopover> createState() => _AppPopoverState();
}

/// Horizontal alignment of the popover relative to its trigger.
enum AppPopoverAlign { start, center, end }

class _AppPopoverState extends State<AppPopover>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _close(immediate: true);
    _animController.dispose();
    super.dispose();
  }

  Alignment get _targetAnchor {
    switch (widget.align) {
      case AppPopoverAlign.start:
        return Alignment.bottomLeft;
      case AppPopoverAlign.center:
        return Alignment.bottomCenter;
      case AppPopoverAlign.end:
        return Alignment.bottomRight;
    }
  }

  Alignment get _followerAnchor {
    switch (widget.align) {
      case AppPopoverAlign.start:
        return Alignment.topLeft;
      case AppPopoverAlign.center:
        return Alignment.topCenter;
      case AppPopoverAlign.end:
        return Alignment.topRight;
    }
  }

  void _toggle() {
    _isOpen ? _close() : _open();
  }

  void _open() {
    if (_isOpen) return;
    _isOpen = true;

    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward();
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
            // Barrier — dismiss on outside tap
            if (widget.barrierDismissible)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => _close(),
                ),
              ),

            // Content
            UnconstrainedBox(
              child: CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: _targetAnchor,
                followerAnchor: _followerAnchor,
                offset: Offset(0, widget.sideOffset),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    alignment: Alignment.topCenter,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: widget.contentWidth,
                        padding: const EdgeInsets.all(16),
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
                        child: widget.content,
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

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: widget.trigger,
      ),
    );
  }
}

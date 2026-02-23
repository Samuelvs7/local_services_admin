import 'package:flutter/material.dart';

/// A styled hover card equivalent to shadcn/ui's HoverCard.
///
/// Shows a popover card when the user hovers over the [trigger] widget.
/// On touch devices it falls back to a tap-to-toggle behaviour.
///
/// ```dart
/// AppHoverCard(
///   trigger: Text('Hover me'),
///   content: Padding(
///     padding: EdgeInsets.all(16),
///     child: Text('Hello from the hover card!'),
///   ),
/// )
/// ```
class AppHoverCard extends StatefulWidget {
  final Widget trigger;
  final Widget content;
  final double contentWidth;
  final Duration openDelay;
  final Duration closeDelay;
  final Alignment alignment;
  final double sideOffset;

  const AppHoverCard({
    super.key,
    required this.trigger,
    required this.content,
    this.contentWidth = 256,
    this.openDelay = const Duration(milliseconds: 200),
    this.closeDelay = const Duration(milliseconds: 150),
    this.alignment = Alignment.center,
    this.sideOffset = 4,
  });

  @override
  State<AppHoverCard> createState() => _AppHoverCardState();
}

class _AppHoverCardState extends State<AppHoverCard>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  bool _isHoveringTrigger = false;
  bool _isHoveringContent = false;

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
    _removeOverlay(immediate: true);
    _animController.dispose();
    super.dispose();
  }

  void _show() {
    if (_isOpen) return;
    _isOpen = true;

    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward();
  }

  Future<void> _hide() async {
    if (!_isOpen) return;
    await _animController.reverse();
    _removeOverlay(immediate: true);
  }

  void _removeOverlay({bool immediate = false}) {
    if (immediate) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
    }
  }

  void _onTriggerEnter() {
    _isHoveringTrigger = true;
    Future.delayed(widget.openDelay, () {
      if (_isHoveringTrigger && mounted) _show();
    });
  }

  void _onTriggerExit() {
    _isHoveringTrigger = false;
    Future.delayed(widget.closeDelay, () {
      if (!_isHoveringTrigger && !_isHoveringContent && mounted) _hide();
    });
  }

  void _onContentEnter() {
    _isHoveringContent = true;
  }

  void _onContentExit() {
    _isHoveringContent = false;
    Future.delayed(widget.closeDelay, () {
      if (!_isHoveringTrigger && !_isHoveringContent && mounted) _hide();
    });
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        final borderColor =
            isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);
        final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;

        return UnconstrainedBox(
          child: CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomCenter,
            followerAnchor: Alignment.topCenter,
            offset: Offset(0, widget.sideOffset),
            child: MouseRegion(
              onEnter: (_) => _onContentEnter(),
              onExit: (_) => _onContentExit(),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  alignment: Alignment.topCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: widget.contentWidth,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _onTriggerEnter(),
        onExit: (_) => _onTriggerExit(),
        // Fallback: tap to toggle on touch devices
        child: GestureDetector(
          onTap: () {
            if (_isOpen) {
              _hide();
            } else {
              _show();
            }
          },
          child: widget.trigger,
        ),
      ),
    );
  }
}

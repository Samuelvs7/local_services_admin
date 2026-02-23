import 'package:flutter/material.dart';
import 'dart:math' as math;

// ---------------------------------------------------------------------------
// AppNavigationMenu — horizontal nav bar with dropdown panels
// ---------------------------------------------------------------------------

/// A styled navigation menu equivalent to shadcn/ui's NavigationMenu.
///
/// Renders a horizontal list of triggers; tapping a trigger reveals a
/// content panel below it with fade + scale animation.
///
/// ```dart
/// AppNavigationMenu(
///   items: [
///     AppNavigationMenuItem.trigger(
///       label: 'Getting started',
///       content: Padding(
///         padding: EdgeInsets.all(16),
///         child: Text('Content panel'),
///       ),
///     ),
///     AppNavigationMenuItem.link(
///       label: 'Documentation',
///       onTap: () => launch(url),
///     ),
///   ],
/// )
/// ```
class AppNavigationMenu extends StatefulWidget {
  final List<AppNavigationMenuItem> items;

  const AppNavigationMenu({super.key, required this.items});

  @override
  State<AppNavigationMenu> createState() => _AppNavigationMenuState();
}

class _AppNavigationMenuState extends State<AppNavigationMenu>
    with SingleTickerProviderStateMixin {
  int _activeIndex = -1;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _removeOverlay(immediate: true);
    _animController.dispose();
    super.dispose();
  }

  void _open(int index) {
    if (_activeIndex == index) {
      _close();
      return;
    }

    final item = widget.items[index];
    final content = item._content;
    if (content == null) {
      // Plain link — no panel to open
      _close();
      item._onTap?.call();
      return;
    }

    _removeOverlay(immediate: true);
    setState(() => _activeIndex = index);

    _overlayEntry = _buildOverlay(content);
    Overlay.of(context).insert(_overlayEntry!);
    _animController.forward(from: 0);
  }

  Future<void> _close() async {
    if (_activeIndex == -1) return;
    await _animController.reverse();
    _removeOverlay(immediate: true);
    setState(() => _activeIndex = -1);
  }

  void _removeOverlay({bool immediate = false}) {
    if (immediate) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _buildOverlay(Widget content) {
    return OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        final borderColor =
            isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);
        final surfaceColor = isDark ? const Color(0xFF111827) : Colors.white;

        return Stack(
          children: [
            // Dismiss on outside tap
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _close(),
              ),
            ),

            // Content panel
            UnconstrainedBox(
              child: CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 6),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    alignment: Alignment.topCenter,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(64),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: content,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < widget.items.length; i++) ...[
            _NavTrigger(
              label: widget.items[i]._label,
              isActive: _activeIndex == i,
              hasPanelContent: widget.items[i]._content != null,
              onTap: () => _open(i),
            ),
            if (i < widget.items.length - 1) const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppNavigationMenuItem
// ---------------------------------------------------------------------------

/// Definition for a single navigation menu item.
///
/// Use [AppNavigationMenuItem.trigger] for items that open a content panel,
/// or [AppNavigationMenuItem.link] for simple navigation links.
class AppNavigationMenuItem {
  final String _label;
  final Widget? _content;
  final VoidCallback? _onTap;

  const AppNavigationMenuItem._({
    required String label,
    Widget? content,
    VoidCallback? onTap,
  })  : _label = label,
        _content = content,
        _onTap = onTap;

  /// Creates a trigger that opens a [content] panel below the nav bar.
  factory AppNavigationMenuItem.trigger({
    required String label,
    required Widget content,
  }) =>
      AppNavigationMenuItem._(label: label, content: content);

  /// Creates a plain link that calls [onTap] without opening a panel.
  factory AppNavigationMenuItem.link({
    required String label,
    required VoidCallback onTap,
  }) =>
      AppNavigationMenuItem._(label: label, onTap: onTap);
}

// ---------------------------------------------------------------------------
// _NavTrigger — individual trigger button
// ---------------------------------------------------------------------------

class _NavTrigger extends StatefulWidget {
  final String label;
  final bool isActive;
  final bool hasPanelContent;
  final VoidCallback onTap;

  const _NavTrigger({
    required this.label,
    required this.isActive,
    required this.hasPanelContent,
    required this.onTap,
  });

  @override
  State<_NavTrigger> createState() => _NavTriggerState();
}

class _NavTriggerState extends State<_NavTrigger>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;

  late AnimationController _chevronController;

  @override
  void initState() {
    super.initState();
    _chevronController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    if (widget.isActive) _chevronController.forward();
  }

  @override
  void didUpdateWidget(covariant _NavTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      widget.isActive
          ? _chevronController.forward()
          : _chevronController.reverse();
    }
  }

  @override
  void dispose() {
    _chevronController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isHighlighted = _hovered || widget.isActive;
    final bgColor = isHighlighted
        ? (isDark ? Colors.white.withAlpha(13) : Colors.grey.withAlpha(26))
        : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.hasPanelContent) ...[
                const SizedBox(width: 4),
                AnimatedBuilder(
                  animation: _chevronController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _chevronController.value * math.pi,
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

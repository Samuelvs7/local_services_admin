import 'package:flutter/material.dart';

/// Side from which the sheet slides in.
enum AppSheetSide { top, bottom, left, right }

/// A styled sheet overlay equivalent to shadcn/ui's Sheet.
///
/// Slides a panel from any edge of the screen with a dark backdrop,
/// close button, and composable header/footer/title/description.
///
/// ```dart
/// AppSheet.show(
///   context: context,
///   side: AppSheetSide.right,
///   title: 'Edit profile',
///   description: 'Make changes to your profile here.',
///   builder: (ctx) => Column(children: [...]),
/// );
/// ```
class AppSheet extends StatelessWidget {
  final AppSheetSide side;
  final String? title;
  final String? description;
  final Widget child;
  final VoidCallback onClose;
  final Widget? footer;

  const AppSheet({
    super.key,
    this.side = AppSheetSide.right,
    this.title,
    this.description,
    required this.child,
    required this.onClose,
    this.footer,
  });

  /// Shows the sheet as a route with slide + fade animation.
  static Future<T?> show<T>({
    required BuildContext context,
    AppSheetSide side = AppSheetSide.right,
    String? title,
    String? description,
    Widget? footer,
    required Widget Function(BuildContext context) builder,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Sheet',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return AppSheet(
          side: side,
          title: title,
          description: description,
          onClose: () => Navigator.of(ctx).pop(),
          footer: footer,
          child: builder(ctx),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return child; // animations handled internally
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SheetAnimator(
      side: side,
      onClose: onClose,
      child: _SheetPanel(
        side: side,
        title: title,
        description: description,
        onClose: onClose,
        footer: footer,
        child: child,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animator — backdrop + slide animation
// ---------------------------------------------------------------------------

class _SheetAnimator extends StatefulWidget {
  final AppSheetSide side;
  final VoidCallback onClose;
  final Widget child;

  const _SheetAnimator({
    required this.side,
    required this.onClose,
    required this.child,
  });

  @override
  State<_SheetAnimator> createState() => _SheetAnimatorState();
}

class _SheetAnimatorState extends State<_SheetAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnim = Tween<Offset>(
      begin: _beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  Offset get _beginOffset {
    switch (widget.side) {
      case AppSheetSide.top:
        return const Offset(0, -1);
      case AppSheetSide.bottom:
        return const Offset(0, 1);
      case AppSheetSide.left:
        return const Offset(-1, 0);
      case AppSheetSide.right:
        return const Offset(1, 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Overlay backdrop
        Positioned.fill(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(color: Colors.black.withAlpha(204)), // 80%
            ),
          ),
        ),

        // Panel
        _positionedPanel(
          child: SlideTransition(
            position: _slideAnim,
            child: widget.child,
          ),
        ),
      ],
    );
  }

  Widget _positionedPanel({required Widget child}) {
    switch (widget.side) {
      case AppSheetSide.left:
        return Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: _sideWidth(context),
          child: child,
        );
      case AppSheetSide.right:
        return Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: _sideWidth(context),
          child: child,
        );
      case AppSheetSide.top:
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: child,
        );
      case AppSheetSide.bottom:
        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: child,
        );
    }
  }

  double _sideWidth(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    // w-3/4 sm:max-w-sm
    final threeQuarters = screenW * 0.75;
    return threeQuarters.clamp(0, 384).toDouble();
  }
}

// ---------------------------------------------------------------------------
// Panel body
// ---------------------------------------------------------------------------

class _SheetPanel extends StatelessWidget {
  final AppSheetSide side;
  final String? title;
  final String? description;
  final VoidCallback onClose;
  final Widget child;
  final Widget? footer;

  const _SheetPanel({
    required this.side,
    this.title,
    this.description,
    required this.onClose,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);

    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Container(
        decoration: BoxDecoration(
          border: _border(borderColor),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with close button
              if (title != null || description != null)
                _SheetHeader(
                  title: title,
                  description: description,
                  onClose: onClose,
                ),

              // Close button only (no header)
              if (title == null && description == null)
                Align(
                  alignment: Alignment.topRight,
                  child: _CloseButton(onClose: onClose),
                ),

              // Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: child,
                ),
              ),

              // Footer
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: footer!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Border? _border(Color borderColor) {
    switch (side) {
      case AppSheetSide.left:
        return Border(right: BorderSide(color: borderColor));
      case AppSheetSide.right:
        return Border(left: BorderSide(color: borderColor));
      case AppSheetSide.top:
        return Border(bottom: BorderSide(color: borderColor));
      case AppSheetSide.bottom:
        return Border(top: BorderSide(color: borderColor));
    }
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _SheetHeader extends StatelessWidget {
  final String? title;
  final String? description;
  final VoidCallback onClose;

  const _SheetHeader({
    this.title,
    this.description,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                  ),
                ],
              ],
            ),
          ),
          _CloseButton(onClose: onClose),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Close button
// ---------------------------------------------------------------------------

class _CloseButton extends StatefulWidget {
  final VoidCallback onClose;

  const _CloseButton({required this.onClose});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onClose,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Opacity(
            opacity: _hovered ? 1.0 : 0.7,
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}

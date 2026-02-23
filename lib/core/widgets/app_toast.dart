import 'package:flutter/material.dart';

/// Variant for the toast message.
enum AppToastVariant { defaultVariant, destructive }

/// A styled toast notification equivalent to shadcn/ui's Toast.
///
/// Displayed as a floating snackbar with a title, description,
/// and optional action button.
///
/// ```dart
/// AppToast.show(
///   context: context,
///   title: 'Success!',
///   description: 'Your changes have been saved.',
///   variant: AppToastVariant.defaultVariant,
/// );
/// ```
class AppToast extends StatelessWidget {
  final String title;
  final String? description;
  final AppToastVariant variant;
  final Widget? action;
  final VoidCallback onClose;

  const AppToast({
    super.key,
    required this.title,
    this.description,
    this.variant = AppToastVariant.defaultVariant,
    this.action,
    required this.onClose,
  });

  /// Static helper to show the toast via Overlay.
  static void show({
    required BuildContext context,
    required String title,
    String? description,
    AppToastVariant variant = AppToastVariant.defaultVariant,
    Widget? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        title: title,
        description: description,
        variant: variant,
        action: action,
        duration: duration,
        onRemove: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    // This is used internally by _ToastOverlay
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isDestructive = variant == AppToastVariant.destructive;

    final bgColor = isDestructive
        ? theme.colorScheme.error
        : (isDark ? const Color(0xFF111827) : Colors.white);

    final borderColor = isDestructive
        ? Colors.white.withAlpha(51)
        : (isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51));

    final textColor = isDestructive
        ? Colors.white
        : (isDark ? Colors.white : Colors.black);

    final subTextColor = isDestructive
        ? Colors.white.withAlpha(204)
        : (isDark ? Colors.grey[400] : Colors.grey[600]);

    return Container(
      width: 420,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
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
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 48, 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(width: 16),
                  action!,
                ],
              ],
            ),
          ),

          // Close button
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: onClose,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: subTextColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Overlay logic with slide/fade animation
// ---------------------------------------------------------------------------

class _ToastOverlay extends StatefulWidget {
  final String title;
  final String? description;
  final AppToastVariant variant;
  final Widget? action;
  final Duration duration;
  final VoidCallback onRemove;

  const _ToastOverlay({
    required this.title,
    this.description,
    required this.variant,
    this.action,
    required this.duration,
    required this.onRemove,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
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
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _show();
  }

  Future<void> _show() async {
    await _controller.forward();
    await Future.delayed(widget.duration);
    if (mounted) {
      await _controller.reverse();
      widget.onRemove();
    }
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onRemove();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: AppToast(
              title: widget.title,
              description: widget.description,
              variant: widget.variant,
              action: widget.action,
              onClose: _dismiss,
            ),
          ),
        ),
      ),
    );
  }
}

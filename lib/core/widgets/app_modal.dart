import 'dart:ui';

import 'package:flutter/material.dart';

/// Modal size presets matching the React `sizeMap`.
enum AppModalSize {
  sm, // max-w-sm  ~384px
  md, // max-w-md  ~448px
  lg, // max-w-lg  ~512px
  xl, // max-w-2xl ~672px
}

/// A glassmorphic modal with backdrop blur, styled header with close button,
/// and arbitrary body content — equivalent to the custom `<Modal>` component.
///
/// ```dart
/// AppModal.show(
///   context: context,
///   title: 'Create item',
///   description: 'Fill in the details below.',
///   size: AppModalSize.md,
///   builder: (ctx) => Column(children: [...]),
/// );
/// ```
class AppModal extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;
  final VoidCallback onClose;
  final AppModalSize size;

  const AppModal({
    super.key,
    required this.title,
    this.description,
    required this.child,
    required this.onClose,
    this.size = AppModalSize.md,
  });

  static double _maxWidth(AppModalSize size) {
    switch (size) {
      case AppModalSize.sm:
        return 384;
      case AppModalSize.md:
        return 448;
      case AppModalSize.lg:
        return 512;
      case AppModalSize.xl:
        return 672;
    }
  }

  /// Shows the modal as a general dialog with fade-in animation and
  /// blurred backdrop.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    AppModalSize size = AppModalSize.md,
    required Widget Function(BuildContext context) builder,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Modal',
      barrierColor: Colors.transparent, // we draw our own barrier
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return AppModal(
          title: title,
          description: description,
          size: size,
          onClose: () => Navigator.of(ctx).pop(),
          child: builder(ctx),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final maxW = _maxWidth(size);

    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);

    return Stack(
      children: [
        // Backdrop — blurred + tinted
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: (isDark ? Colors.black : Colors.white)
                    .withAlpha(204), // ~0.8
              ),
            ),
          ),
        ),

        // Modal panel
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: maxW,
                decoration: BoxDecoration(
                  // Glass effect
                  color: isDark
                      ? const Color(0xFF111827).withAlpha(230)
                      : Colors.white.withAlpha(230),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(77),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _ModalHeader(
                      title: title,
                      description: description,
                      onClose: onClose,
                      borderColor: borderColor,
                    ),

                    // Body
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _ModalHeader extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback onClose;
  final Color borderColor;

  const _ModalHeader({
    required this.title,
    this.description,
    required this.onClose,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Close button
          const SizedBox(width: 12),
          _CloseButton(onClose: onClose),
        ],
      ),
    );
  }
}

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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _hovered
                ? (isDark ? Colors.white.withAlpha(13) : Colors.grey.withAlpha(26))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.close_rounded,
            size: 16,
            color: _hovered
                ? (isDark ? Colors.grey[300] : Colors.grey[700])
                : (isDark ? Colors.grey[500] : Colors.grey[400]),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ConfirmModal
// ---------------------------------------------------------------------------

/// Variant for the confirm modal — equivalent to `<ConfirmModal>`.
enum AppConfirmVariant { standard, danger }

/// A confirmation modal with cancel / confirm buttons.
///
/// ```dart
/// AppConfirmModal.show(
///   context: context,
///   title: 'Delete item?',
///   description: 'This action cannot be undone.',
///   confirmLabel: 'Delete',
///   variant: AppConfirmVariant.danger,
///   onConfirm: () => deleteItem(),
/// );
/// ```
class AppConfirmModal {
  AppConfirmModal._();

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String description,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    AppConfirmVariant variant = AppConfirmVariant.standard,
  }) {
    return AppModal.show<bool>(
      context: context,
      title: title,
      size: AppModalSize.sm,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final isDark = theme.brightness == Brightness.dark;
        final borderColor =
            isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);

        final isDanger = variant == AppConfirmVariant.danger;
        final confirmBg =
            isDanger ? theme.colorScheme.error : theme.colorScheme.primary;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel
                OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.textTheme.bodyLarge?.color,
                    side: BorderSide(color: borderColor),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(cancelLabel,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 12),
                // Confirm
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: confirmBg,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(confirmLabel,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

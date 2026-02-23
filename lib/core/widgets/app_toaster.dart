import 'package:flutter/material.dart';
import 'app_toast.dart';

/// A toast data model matching shadcn's toast props.
class AppToastData {
  final String id;
  final String title;
  final String? description;
  final AppToastVariant variant;
  final Widget? action;
  final Duration duration;

  const AppToastData({
    required this.id,
    required this.title,
    this.description,
    this.variant = AppToastVariant.defaultVariant,
    this.action,
    this.duration = const Duration(seconds: 4),
  });
}

/// A global manager for toasts, equivalent to `useToast`.
class AppToastManager extends ChangeNotifier {
  static final AppToastManager instance = AppToastManager._();
  AppToastManager._();

  final List<AppToastData> _toasts = [];
  List<AppToastData> get toasts => List.unmodifiable(_toasts);

  void show({
    required String title,
    String? description,
    AppToastVariant variant = AppToastVariant.defaultVariant,
    Widget? action,
    Duration duration = const Duration(seconds: 4),
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final toast = AppToastData(
      id: id,
      title: title,
      description: description,
      variant: variant,
      action: action,
      duration: duration,
    );

    _toasts.add(toast);
    notifyListeners();

    // Auto-remove after duration
    Future.delayed(duration + const Duration(milliseconds: 500), () {
      remove(id);
    });
  }

  void remove(String id) {
    _toasts.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}

/// The Toaster component equivalent to `<Toaster>`.
///
/// Should be placed at the root of your app (e.g. in [MaterialApp.builder])
/// to render active toasts.
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) {
///     return Stack(
///       children: [
///         child!,
///         const AppToaster(),
///       ],
///     );
///   },
/// )
/// ```
class AppToaster extends StatelessWidget {
  const AppToaster({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppToastManager.instance,
      builder: (context, child) {
        final toasts = AppToastManager.instance.toasts;

        return Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: toasts.map((toast) {
                return _ToastItem(
                  key: ValueKey(toast.id),
                  toast: toast,
                  onClose: () => AppToastManager.instance.remove(toast.id),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _ToastItem extends StatefulWidget {
  final AppToastData toast;
  final VoidCallback onClose;

  const _ToastItem({
    super.key,
    required this.toast,
    required this.onClose,
  });

  @override
  State<_ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends State<_ToastItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: AppToast(
          title: widget.toast.title,
          description: widget.toast.description,
          variant: widget.toast.variant,
          action: widget.toast.action,
          onClose: () async {
            await _controller.reverse();
            widget.onClose();
          },
        ),
      ),
    );
  }
}

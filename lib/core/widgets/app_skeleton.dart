import 'package:flutter/material.dart';

/// A styled skeleton loading placeholder equivalent to shadcn/ui's Skeleton.
///
/// Renders a pulsing rounded rectangle used as a placeholder while content
/// is loading.
///
/// ```dart
/// AppSkeleton(width: 200, height: 16)                   // text line
/// AppSkeleton(width: 40, height: 40, circular: true)     // avatar
/// AppSkeleton(height: 120)                               // card block
/// ```
class AppSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final bool circular;
  final BorderRadius? borderRadius;

  const AppSkeleton({
    super.key,
    this.width,
    this.height,
    this.circular = false,
    this.borderRadius,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark
        ? Colors.white.withAlpha(26)
        : Colors.grey.withAlpha(51);

    final shape = widget.circular
        ? BoxShape.circle
        : BoxShape.rectangle;

    final radius = widget.circular
        ? null
        : (widget.borderRadius ?? BorderRadius.circular(6));

    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: bgColor,
          shape: shape,
          borderRadius: radius,
        ),
      ),
    );
  }
}

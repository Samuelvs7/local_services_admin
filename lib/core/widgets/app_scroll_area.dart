import 'package:flutter/material.dart';

/// Scroll direction for the scroll area.
enum AppScrollOrientation { vertical, horizontal, both }

/// A styled scroll area equivalent to shadcn/ui's ScrollArea.
///
/// Wraps content in a scrollable viewport with a thin, rounded scrollbar
/// thumb that matches the admin design system.
///
/// ```dart
/// AppScrollArea(
///   height: 300,
///   child: Column(children: items),
/// )
///
/// AppScrollArea(
///   orientation: AppScrollOrientation.horizontal,
///   child: Row(children: items),
/// )
/// ```
class AppScrollArea extends StatefulWidget {
  final Widget child;
  final AppScrollOrientation orientation;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final ScrollController? controller;

  const AppScrollArea({
    super.key,
    required this.child,
    this.orientation = AppScrollOrientation.vertical,
    this.height,
    this.width,
    this.padding,
    this.controller,
  });

  @override
  State<AppScrollArea> createState() => _AppScrollAreaState();
}

class _AppScrollAreaState extends State<AppScrollArea> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final thumbColor =
        isDark ? Colors.white.withAlpha(38) : Colors.grey.withAlpha(77);

    final scrollbarTheme = ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(thumbColor),
      radius: const Radius.circular(100),
      thickness: WidgetStatePropertyAll(
        widget.orientation == AppScrollOrientation.horizontal ? 10.0 : 10.0,
      ),
      crossAxisMargin: 1,
      mainAxisMargin: 1,
      minThumbLength: 36,
      thumbVisibility: const WidgetStatePropertyAll(true),
    );

    Widget content = widget.child;

    if (widget.padding != null) {
      content = Padding(padding: widget.padding!, child: content);
    }

    Widget scrollView;

    switch (widget.orientation) {
      case AppScrollOrientation.vertical:
        scrollView = ScrollbarTheme(
          data: scrollbarTheme,
          child: Scrollbar(
            controller: _controller,
            child: SingleChildScrollView(
              controller: _controller,
              child: content,
            ),
          ),
        );
        break;

      case AppScrollOrientation.horizontal:
        scrollView = ScrollbarTheme(
          data: scrollbarTheme,
          child: Scrollbar(
            controller: _controller,
            child: SingleChildScrollView(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              child: content,
            ),
          ),
        );
        break;

      case AppScrollOrientation.both:
        // For bidirectional scrolling, wrap vertical in horizontal
        final hController = ScrollController();
        scrollView = ScrollbarTheme(
          data: scrollbarTheme,
          child: Scrollbar(
            controller: _controller,
            child: SingleChildScrollView(
              controller: _controller,
              child: Scrollbar(
                controller: hController,
                notificationPredicate: (n) => n.depth == 0,
                child: SingleChildScrollView(
                  controller: hController,
                  scrollDirection: Axis.horizontal,
                  child: content,
                ),
              ),
            ),
          ),
        );
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(0), // inherits parent's radius
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: scrollView,
      ),
    );
  }
}

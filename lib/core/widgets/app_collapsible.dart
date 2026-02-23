import 'package:flutter/material.dart';

/// A styled collapsible widget equivalent to shadcn/ui's Collapsible.
///
/// Unlike the Accordion, the Collapsible is a single standalone
/// expand/collapse panel with an explicit trigger widget.
class AppCollapsible extends StatefulWidget {
  final Widget trigger;
  final Widget content;
  final bool initiallyOpen;
  final ValueChanged<bool>? onOpenChange;

  const AppCollapsible({
    super.key,
    required this.trigger,
    required this.content,
    this.initiallyOpen = false,
    this.onOpenChange,
  });

  @override
  State<AppCollapsible> createState() => _AppCollapsibleState();
}

class _AppCollapsibleState extends State<AppCollapsible>
    with SingleTickerProviderStateMixin {
  late bool _isOpen;
  late AnimationController _controller;
  late Animation<double> _heightFactor;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.initiallyOpen;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightFactor = _controller.drive(CurveTween(curve: Curves.easeInOut));

    if (_isOpen) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onOpenChange?.call(_isOpen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Trigger — wraps the user-provided trigger with a tap handler
        GestureDetector(
          onTap: toggle,
          behavior: HitTestBehavior.opaque,
          child: widget.trigger,
        ),

        // Collapsible content
        AnimatedBuilder(
          animation: _controller.view,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topLeft,
                heightFactor: _heightFactor.value,
                child: child,
              ),
            );
          },
          child: widget.content,
        ),
      ],
    );
  }
}

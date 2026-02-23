import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A styled OTP / PIN input widget equivalent to shadcn/ui's InputOTP.
///
/// Renders a row of individual digit slots with animated focus caret,
/// auto-advance on input, and optional separators between groups.
///
/// ```dart
/// AppInputOTP(
///   length: 6,
///   groupSize: 3, // creates 2 groups of 3 with a separator
///   onCompleted: (code) => print('OTP: $code'),
/// )
/// ```
class AppInputOTP extends StatefulWidget {
  final int length;
  final int? groupSize;
  final bool enabled;
  final bool obscure;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final TextEditingController? controller;

  const AppInputOTP({
    super.key,
    this.length = 6,
    this.groupSize,
    this.enabled = true,
    this.obscure = false,
    this.onChanged,
    this.onCompleted,
    this.controller,
  });

  @override
  State<AppInputOTP> createState() => _AppInputOTPState();
}

class _AppInputOTPState extends State<AppInputOTP> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  int _activeIndex = -1;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    // Sync with external controller if provided
    if (widget.controller != null) {
      final text = widget.controller!.text;
      for (int i = 0; i < widget.length && i < text.length; i++) {
        _controllers[i].text = text[i];
      }
    }

    for (int i = 0; i < widget.length; i++) {
      _focusNodes[i].addListener(() {
        setState(() {
          _activeIndex = _focusNodes[i].hasFocus ? i : _activeIndex;
        });
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentValue =>
      _controllers.map((c) => c.text).join();

  void _syncExternalController() {
    widget.controller?.text = _currentValue;
  }

  void _onSlotChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste: distribute characters across slots
      _handlePaste(value, index);
      return;
    }

    setState(() {});
    _syncExternalController();
    widget.onChanged?.call(_currentValue);

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_currentValue.length == widget.length) {
      widget.onCompleted?.call(_currentValue);
    }
  }

  void _handlePaste(String pasted, int startIndex) {
    final chars = pasted.split('');
    for (int i = 0; i < chars.length && startIndex + i < widget.length; i++) {
      _controllers[startIndex + i].text = chars[i];
    }
    setState(() {});
    _syncExternalController();
    widget.onChanged?.call(_currentValue);

    final lastFilled =
        (startIndex + chars.length).clamp(0, widget.length - 1);
    _focusNodes[lastFilled].requestFocus();

    if (_currentValue.length == widget.length) {
      widget.onCompleted?.call(_currentValue);
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        setState(() {});
        _syncExternalController();
        widget.onChanged?.call(_currentValue);
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft && index > 0) {
      _focusNodes[index - 1].requestFocus();
    } else if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
        index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final slots = <Widget>[];
    final groupSize = widget.groupSize;

    for (int i = 0; i < widget.length; i++) {
      // Insert separator between groups
      if (groupSize != null && i > 0 && i % groupSize == 0) {
        slots.add(const AppInputOTPSeparator());
      }

      final isFirst = groupSize != null ? i % groupSize == 0 : i == 0;
      final isLast = groupSize != null
          ? i % groupSize == groupSize - 1 || i == widget.length - 1
          : i == widget.length - 1;

      slots.add(
        _OTPSlot(
          controller: _controllers[i],
          focusNode: _focusNodes[i],
          isActive: _activeIndex == i,
          isFirst: isFirst,
          isLast: isLast,
          enabled: widget.enabled,
          obscure: widget.obscure,
          onChanged: (v) => _onSlotChanged(i, v),
          onKey: (e) => _onKeyEvent(i, e),
        ),
      );
    }

    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: slots,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual OTP slot
// ---------------------------------------------------------------------------

class _OTPSlot extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isActive;
  final bool isFirst;
  final bool isLast;
  final bool enabled;
  final bool obscure;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKey;

  const _OTPSlot({
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.isFirst,
    required this.isLast,
    required this.enabled,
    required this.obscure,
    required this.onChanged,
    required this.onKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);

    final borderRadius = BorderRadius.only(
      topLeft: isFirst ? const Radius.circular(6) : Radius.zero,
      bottomLeft: isFirst ? const Radius.circular(6) : Radius.zero,
      topRight: isLast ? const Radius.circular(6) : Radius.zero,
      bottomRight: isLast ? const Radius.circular(6) : Radius.zero,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(
          color: isActive ? theme.colorScheme.primary : borderColor,
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withAlpha(51),
                  blurRadius: 0,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: KeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKeyEvent: onKey,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          obscureText: obscure,
          textAlign: TextAlign.center,
          maxLength: 1,
          keyboardType: TextInputType.number,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.singleLineFormatter,
          ],
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Separator dot between OTP groups
// ---------------------------------------------------------------------------

/// A separator widget (dot) between OTP slot groups —
/// equivalent to `<InputOTPSeparator>`.
class AppInputOTPSeparator extends StatelessWidget {
  const AppInputOTPSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(
        Icons.fiber_manual_record,
        size: 8,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'app_input.dart';

/// A styled multiline text area equivalent to shadcn/ui's Textarea.
///
/// Wraps [AppInput] with [AppInputType.multiline] and a default [minLines] of 3.
/// Perfect for long-form text entry like descriptions or bios.
///
/// ```dart
/// AppTextarea(
///   placeholder: 'Tell us about yourself',
///   onChanged: (v) => setState(() => bio = v),
/// )
/// ```
class AppTextarea extends StatelessWidget {
  final String? placeholder;
  final String? initialValue;
  final bool enabled;
  final bool readOnly;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final int? maxLength;
  final int minLines;
  final int maxLines;
  final String? errorText;
  final String? Function(String?)? validator;

  const AppTextarea({
    super.key,
    this.placeholder,
    this.initialValue,
    this.enabled = true,
    this.readOnly = false,
    this.controller,
    this.onChanged,
    this.focusNode,
    this.maxLength,
    this.minLines = 3,
    this.maxLines = 10,
    this.errorText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppInput(
      placeholder: placeholder,
      initialValue: initialValue,
      type: AppInputType.multiline,
      enabled: enabled,
      readOnly: readOnly,
      controller: controller,
      onChanged: onChanged,
      focusNode: focusNode,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      errorText: errorText,
      validator: validator,
    );
  }
}

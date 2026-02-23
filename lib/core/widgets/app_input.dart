import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Supported input types — mirrors the HTML `type` attribute.
enum AppInputType {
  text,
  password,
  number,
  email,
  search,
  url,
  phone,
  multiline,
}

/// A styled text input widget equivalent to shadcn/ui's `<Input>`.
///
/// Provides consistent height (40px), border, focus ring, disabled state,
/// and placeholder styling matching the admin panel design system.
///
/// ```dart
/// AppInput(
///   placeholder: 'Email',
///   type: AppInputType.email,
///   onChanged: (v) => setState(() => email = v),
/// )
/// ```
class AppInput extends StatefulWidget {
  final String? placeholder;
  final String? initialValue;
  final AppInputType type;
  final bool enabled;
  final bool readOnly;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int maxLines;
  final int minLines;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final String? errorText;

  const AppInput({
    super.key,
    this.placeholder,
    this.initialValue,
    this.type = AppInputType.text,
    this.enabled = true,
    this.readOnly = false,
    this.controller,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.inputFormatters,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.validator,
    this.errorText,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true; // only used for password type

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  bool get _isPassword => widget.type == AppInputType.password;
  bool get _isMultiline => widget.type == AppInputType.multiline;

  TextInputType get _keyboardType {
    switch (widget.type) {
      case AppInputType.number:
        return TextInputType.number;
      case AppInputType.email:
        return TextInputType.emailAddress;
      case AppInputType.url:
        return TextInputType.url;
      case AppInputType.phone:
        return TextInputType.phone;
      case AppInputType.search:
        return TextInputType.text;
      case AppInputType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final borderColor = hasError
        ? theme.colorScheme.error
        : _isFocused
            ? theme.colorScheme.primary
            : (isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51));

    final borderWidth = _isFocused || hasError ? 1.5 : 1.0;

    final fillColor = widget.enabled
        ? (isDark ? Colors.white.withAlpha(8) : Colors.grey.withAlpha(13))
        : (isDark ? Colors.white.withAlpha(5) : Colors.grey.withAlpha(8));

    final effectiveSuffix = _isPassword
        ? GestureDetector(
            onTap: () => setState(() => _obscureText = !_obscureText),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
          )
        : widget.suffixIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: _isMultiline ? null : 40,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor, width: borderWidth),
            // Focus ring glow
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: (hasError
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary)
                          .withAlpha(51), // ~0.2 opacity
                      blurRadius: 0,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.5,
            child: TextFormField(
              controller: widget.controller,
              initialValue:
                  widget.controller == null ? widget.initialValue : null,
              focusNode: _focusNode,
              enabled: widget.enabled,
              readOnly: widget.readOnly,
              obscureText: _isPassword && _obscureText,
              keyboardType: _keyboardType,
              textCapitalization: widget.textCapitalization,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.inputFormatters,
              maxLength: widget.maxLength,
              maxLines: _isMultiline ? widget.maxLines : 1,
              minLines: _isMultiline ? widget.minLines : 1,
              style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
              onChanged: widget.onChanged,
              onEditingComplete: widget.onEditingComplete,
              onFieldSubmitted: widget.onSubmitted,
              validator: widget.validator,
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: IconTheme(
                          data: IconThemeData(
                            size: 16,
                            color: isDark
                                ? Colors.grey[500]
                                : Colors.grey[400],
                          ),
                          child: widget.prefixIcon!,
                        ),
                      )
                    : null,
                prefixIconConstraints: const BoxConstraints(),
                suffixIcon: effectiveSuffix,
                suffixIconConstraints: const BoxConstraints(),
                prefixText: widget.prefixText,
                suffixText: widget.suffixText,
                prefixStyle: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
                suffixStyle: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
                // All borders handled by the AnimatedContainer above
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                // Suppress built-in error text; consumer uses AppFormItem.
                errorStyle: const TextStyle(height: 0, fontSize: 0),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: _isMultiline ? 10 : 0,
                ),
                isDense: true,
                counterText: '',
                filled: false,
              ),
            ),
          ),
        ),

        // Inline error text (shown when used standalone, not inside AppFormItem)
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

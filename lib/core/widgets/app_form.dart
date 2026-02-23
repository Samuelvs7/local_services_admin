import 'package:flutter/material.dart';

/// A styled form-field layout widget equivalent to shadcn/ui's Form components.
///
/// In React, shadcn wraps `react-hook-form` with styled layout primitives.
/// In Flutter, form state is managed natively by [Form] + [TextFormField] etc.
/// This widget focuses on the **layout & styling** layer: label, control,
/// description text, and error message — all with consistent spacing.
///
/// ```dart
/// AppFormItem(
///   label: 'Email',
///   description: 'We\'ll never share your email.',
///   error: emailError,
///   child: TextFormField(...),
/// )
/// ```
class AppFormItem extends StatelessWidget {
  final String? label;
  final String? description;
  final String? error;
  final Widget child;
  final bool isRequired;
  final EdgeInsets padding;

  const AppFormItem({
    super.key,
    this.label,
    this.description,
    this.error,
    required this.child,
    this.isRequired = false,
    this.padding = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          if (label != null) ...[
            AppFormLabel(
              text: label!,
              isRequired: isRequired,
              hasError: hasError,
            ),
            const SizedBox(height: 8),
          ],

          // Control (the actual input widget)
          child,

          // Description
          if (description != null && !hasError) ...[
            const SizedBox(height: 6),
            AppFormDescription(text: description!),
          ],

          // Error message
          if (hasError) ...[
            const SizedBox(height: 6),
            AppFormMessage(text: error!),
          ],
        ],
      ),
    );
  }
}

/// Styled label — equivalent to `<FormLabel>`.
///
/// Turns red when [hasError] is true, matching shadcn's `text-destructive`
/// behaviour on validation failure.
class AppFormLabel extends StatelessWidget {
  final String text;
  final bool isRequired;
  final bool hasError;

  const AppFormLabel({
    super.key,
    required this.text,
    this.isRequired = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text.rich(
      TextSpan(
        text: text,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: hasError
              ? theme.colorScheme.error
              : theme.textTheme.bodyMedium?.color,
        ),
        children: isRequired
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]
            : null,
      ),
    );
  }
}

/// Helper / description text — equivalent to `<FormDescription>`.
class AppFormDescription extends StatelessWidget {
  final String text;

  const AppFormDescription({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.grey[500] : Colors.grey[400],
        height: 1.4,
      ),
    );
  }
}

/// Error message text — equivalent to `<FormMessage>`.
class AppFormMessage extends StatelessWidget {
  final String text;

  const AppFormMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.error,
        height: 1.4,
      ),
    );
  }
}

/// A convenience wrapper that provides a Flutter [Form] with the standard
/// shadcn-style input decoration applied to all descendant [TextFormField]s.
///
/// Equivalent to shadcn's `<Form>` (which wraps `FormProvider`).
class AppForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final AutovalidateMode autovalidateMode;
  final VoidCallback? onSubmit;

  const AppForm({
    super.key,
    required this.formKey,
    required this.children,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  /// Validates and calls [onSubmit] if the form is valid.
  bool validate() {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState!.save();
      onSubmit?.call();
      return true;
    }
    return false;
  }
}

/// Provides a consistent [InputDecoration] matching the dark admin theme.
///
/// Use this to style any [TextFormField] / [TextField] inside an [AppFormItem].
class AppFormInputDecoration {
  AppFormInputDecoration._();

  static InputDecoration standard({
    required BuildContext context,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? prefix,
    String? suffix,
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);
    final fillColor = isDark
        ? Colors.white.withAlpha(8)
        : Colors.grey.withAlpha(13);

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
      ),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixText: prefix,
      suffixText: suffix,
      filled: true,
      fillColor: fillColor,
      enabled: enabled,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(
          color: theme.colorScheme.error,
          width: 1.5,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: borderColor.withAlpha(13)),
      ),
      // Hide the built-in error text since AppFormItem handles it.
      errorStyle: const TextStyle(height: 0, fontSize: 0),
    );
  }
}

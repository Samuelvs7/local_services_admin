import 'package:flutter/material.dart';


enum AppButtonVariant {
  standard,
  destructive,
  outline,
  secondary,
  ghost,
  link,
}

enum AppButtonSize {
  standard,
  sm,
  lg,
  icon,
}

class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final double? width;

  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = AppButtonVariant.standard,
    this.size = AppButtonSize.standard,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Size configuration
    double height;
    EdgeInsets padding;
    double fontSize = 14;

    switch (size) {
      case AppButtonSize.sm:
        height = 36;
        padding = const EdgeInsets.symmetric(horizontal: 12);
        break;
      case AppButtonSize.lg:
        height = 44;
        padding = const EdgeInsets.symmetric(horizontal: 32);
        break;
      case AppButtonSize.icon:
        height = 40;
        padding = EdgeInsets.zero;
        break;
      default:
        height = 40;
        padding = const EdgeInsets.symmetric(horizontal: 16);
    }

    // Style configuration
    ButtonStyle style;
    
    switch (variant) {
      case AppButtonVariant.destructive:
        style = ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: Colors.white,
          elevation: 0,
        );
        break;
      case AppButtonVariant.outline:
        style = OutlinedButton.styleFrom(
          foregroundColor: theme.textTheme.bodyLarge?.color,
          side: BorderSide(
            color: isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51),
          ),
          backgroundColor: Colors.transparent,
        );
        break;
      case AppButtonVariant.secondary:
        style = ElevatedButton.styleFrom(
          backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey[100],
          foregroundColor: theme.textTheme.bodyLarge?.color,
          elevation: 0,
        );
        break;
      case AppButtonVariant.ghost:
        style = TextButton.styleFrom(
          foregroundColor: theme.textTheme.bodyLarge?.color,
          padding: padding,
        );
        break;
      case AppButtonVariant.link:
        style = TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          padding: padding,
        ).copyWith(
          overlayColor: WidgetStateProperty.all(Colors.transparent),
        );
        break;
      default:
        style = ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        );
    }

    // Wrap the content based on loading/size
    Widget buttonContent = isLoading
        ? const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : DefaultTextStyle(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              decoration: variant == AppButtonVariant.link ? TextDecoration.underline : null,
            ),
            child: child,
          );

    final finalPadding = size == AppButtonSize.icon ? EdgeInsets.zero : padding;
    final finalShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));

    final actualStyle = style.copyWith(
      minimumSize: WidgetStateProperty.all(Size(width ?? (size == AppButtonSize.icon ? height : 0), height)),
      padding: WidgetStateProperty.all(finalPadding),
      shape: WidgetStateProperty.all(finalShape),
    );

    if (variant == AppButtonVariant.outline) {
      return OutlinedButton(onPressed: isLoading ? null : onPressed, style: actualStyle, child: buttonContent);
    } else if (variant == AppButtonVariant.ghost || variant == AppButtonVariant.link) {
      return TextButton(onPressed: isLoading ? null : onPressed, style: actualStyle, child: buttonContent);
    } else {
      return ElevatedButton(onPressed: isLoading ? null : onPressed, style: actualStyle, child: buttonContent);
    }
  }
}

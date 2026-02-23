import 'package:flutter/material.dart';
import 'app_toggle.dart';

/// Context for shared toggle group state (variants and sizes).
class _ToggleGroupState extends InheritedWidget {
  final AppToggleVariant variant;
  final AppToggleSize size;
  final dynamic value;
  final ValueChanged<dynamic> onValueSelect;
  final bool isMultiple;

  const _ToggleGroupState({
    required this.variant,
    required this.size,
    required this.value,
    required this.onValueSelect,
    required this.isMultiple,
    required super.child,
  });

  static _ToggleGroupState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ToggleGroupState>();
  }

  @override
  bool updateShouldNotify(_ToggleGroupState oldWidget) {
    return variant != oldWidget.variant || 
           size != oldWidget.size || 
           value != oldWidget.value;
  }
}

/// A styled toggle group equivalent to shadcn/ui's ToggleGroup.
///
/// Manages a set of toggles that can be used for single or multiple selection.
///
/// ```dart
/// AppToggleGroup<String>(
///   value: _selectedValue,
///   onValueChange: (v) => setState(() => _selectedValue = v),
///   children: [
///     AppToggleGroupItem(value: 'bold', child: Icon(Icons.format_bold)),
///     AppToggleGroupItem(value: 'italic', child: Icon(Icons.format_italic)),
///   ],
/// )
/// ```
class AppToggleGroup<T> extends StatelessWidget {
  final T? value;
  final List<T>? values;
  final ValueChanged<T?>? onValueChange;
  final ValueChanged<List<T>>? onValuesChange;
  final AppToggleVariant variant;
  final AppToggleSize size;
  final List<Widget> children;
  final String? className;

  const AppToggleGroup({
    super.key,
    this.value,
    this.onValueChange,
    this.variant = AppToggleVariant.defaultVariant,
    this.size = AppToggleSize.defaultSize,
    required this.children,
    this.className,
  })  : values = null,
        onValuesChange = null;

  const AppToggleGroup.multiple({
    super.key,
    required this.values,
    required this.onValuesChange,
    this.variant = AppToggleVariant.defaultVariant,
    this.size = AppToggleSize.defaultSize,
    required this.children,
    this.className,
  })  : value = null,
        onValueChange = null;

  @override
  Widget build(BuildContext context) {
    return _ToggleGroupState(
      variant: variant,
      size: size,
      value: value ?? values,
      isMultiple: values != null,
      onValueSelect: (val) {
        if (values != null) {
          final current = List<T>.from(values!);
          if (current.contains(val)) {
            current.remove(val);
          } else {
            current.add(val as T);
          }
          onValuesChange?.call(current);
        } else {
          onValueChange?.call(val == value ? null : val as T);
        }
      },
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: children,
      ),
    );
  }
}

/// An individual item within a [AppToggleGroup].
class AppToggleGroupItem<T> extends StatelessWidget {
  final T value;
  final Widget child;
  final AppToggleVariant? variant;
  final AppToggleSize? size;
  final bool enabled;

  const AppToggleGroupItem({
    super.key,
    required this.value,
    required this.child,
    this.variant,
    this.size,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final state = _ToggleGroupState.of(context);
    final bool isPressed;
    
    if (state?.isMultiple ?? false) {
      isPressed = (state?.value as List<T>? ?? []).contains(value);
    } else {
      isPressed = state?.value == value;
    }

    return AppToggle(
      pressed: isPressed,
      onPressedChange: (_) => state?.onValueSelect(value),
      variant: variant ?? state?.variant ?? AppToggleVariant.defaultVariant,
      size: size ?? state?.size ?? AppToggleSize.defaultSize,
      enabled: enabled,
      child: child,
    );
  }
}

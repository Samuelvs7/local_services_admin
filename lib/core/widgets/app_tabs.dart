import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// AppTabsState — Context for shared tab state
// ---------------------------------------------------------------------------

class AppTabsState extends InheritedWidget {
  final String value;
  final ValueChanged<String> onValueChange;

  const AppTabsState({
    super.key,
    required this.value,
    required this.onValueChange,
    required super.child,
  });

  static AppTabsState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppTabsState>();
  }

  static AppTabsState of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No AppTabsState found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant AppTabsState oldWidget) =>
      value != oldWidget.value;
}

// ---------------------------------------------------------------------------
// AppTabs — Root component
// ---------------------------------------------------------------------------

/// The root tabs component equivalent to `<Tabs>`.
///
/// Manages the selected tab state and provides it to descendants.
///
/// ```dart
/// AppTabs(
///   defaultValue: 'account',
///   child: Column(
///     children: [
///       AppTabsList(
///         children: [
///           AppTabsTrigger(value: 'account', label: 'Account'),
///           AppTabsTrigger(value: 'password', label: 'Password'),
///         ],
///       ),
///       AppTabsContent(value: 'account', child: Text('Account Settings')),
///       AppTabsContent(value: 'password', child: Text('Password Settings')),
///     ],
///   ),
/// )
/// ```
class AppTabs extends StatefulWidget {
  final String defaultValue;
  final Widget child;
  final ValueChanged<String>? onValueChange;

  const AppTabs({
    super.key,
    required this.defaultValue,
    required this.child,
    this.onValueChange,
  });

  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.defaultValue;
  }

  void _handleValueChange(String newValue) {
    setState(() => _currentValue = newValue);
    widget.onValueChange?.call(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return AppTabsState(
      value: _currentValue,
      onValueChange: _handleValueChange,
      child: widget.child,
    );
  }
}

// ---------------------------------------------------------------------------
// AppTabsList — Trigger container
// ---------------------------------------------------------------------------

/// The trigger container equivalent to `<TabsList>`.
///
/// Styled as a muted horizontal track for the tab triggers.
class AppTabsList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;

  const AppTabsList({
    super.key,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark
        ? Colors.white.withAlpha(26) // bg-muted
        : Colors.grey.withAlpha(51);

    return Container(
      height: 40, // h-10
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppTabsTrigger — Tab button
// ---------------------------------------------------------------------------

/// The individual tab button equivalent to `<TabsTrigger>`.
///
/// Animates to show a background "pill" when active.
class AppTabsTrigger extends StatefulWidget {
  final String value;
  final String label;
  final bool enabled;

  const AppTabsTrigger({
    super.key,
    required this.value,
    required this.label,
    this.enabled = true,
  });

  @override
  State<AppTabsTrigger> createState() => _AppTabsTriggerState();
}

class _AppTabsTriggerState extends State<AppTabsTrigger> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final tabsState = AppTabsState.of(context);
    final isActive = tabsState.value == widget.value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeBgColor = isDark ? const Color(0xFF030712) : Colors.white;
    final activeTextColor = isDark ? Colors.white : Colors.black;
    final inactiveTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? () => tabsState.onValueChange(widget.value) : null,
        child: Opacity(
          opacity: widget.enabled ? 1.0 : 0.5,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isActive ? activeBgColor : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 51 : 20),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? activeTextColor
                    : (_hovered ? activeTextColor : inactiveTextColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// AppTabsContent — Tab body
// ---------------------------------------------------------------------------

/// The content container equivalent to `<TabsContent>`.
///
/// Only renders its [child] if the current tab value matches its [value].
class AppTabsContent extends StatelessWidget {
  final String value;
  final Widget child;

  const AppTabsContent({
    super.key,
    required this.value,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final tabsState = AppTabsState.of(context);
    final isActive = tabsState.value == value;

    if (!isActive) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: child,
    );
  }
}

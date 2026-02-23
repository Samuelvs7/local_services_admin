import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const double kSidebarWidth = 256; // 16rem
const double kSidebarWidthMobile = 288; // 18rem
const double kSidebarWidthIcon = 48; // 3rem

// ---------------------------------------------------------------------------
// AppSidebarState — InheritedWidget for sidebar context
// ---------------------------------------------------------------------------

/// Provides sidebar state to descendants, equivalent to `useSidebar()`.
class AppSidebarState extends InheritedWidget {
  final bool isExpanded;
  final bool isMobile;
  final VoidCallback toggleSidebar;

  const AppSidebarState({
    super.key,
    required this.isExpanded,
    required this.isMobile,
    required this.toggleSidebar,
    required super.child,
  });

  static AppSidebarState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppSidebarState>();
  }

  static AppSidebarState of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No AppSidebarState found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant AppSidebarState oldWidget) =>
      isExpanded != oldWidget.isExpanded || isMobile != oldWidget.isMobile;
}

// ---------------------------------------------------------------------------
// AppSidebarProvider — manages expanded/collapsed + mobile sheet
// ---------------------------------------------------------------------------

/// Root provider that manages sidebar state and layout.
///
/// Wraps [child] with an [AppSidebarState] and handles keyboard shortcut
/// (Ctrl+B) for toggling.
///
/// ```dart
/// AppSidebarProvider(
///   sidebar: AppSidebar(children: [...]),
///   child: MainContent(),
/// )
/// ```
class AppSidebarProvider extends StatefulWidget {
  final Widget sidebar;
  final Widget child;
  final bool defaultOpen;
  final AppSidebarSide side;
  final AppSidebarVariant variant;
  final double mobileBreakpoint;

  const AppSidebarProvider({
    super.key,
    required this.sidebar,
    required this.child,
    this.defaultOpen = true,
    this.side = AppSidebarSide.left,
    this.variant = AppSidebarVariant.sidebar,
    this.mobileBreakpoint = 768,
  });

  @override
  State<AppSidebarProvider> createState() => _AppSidebarProviderState();
}

enum AppSidebarSide { left, right }

enum AppSidebarVariant { sidebar, floating, inset }

class _AppSidebarProviderState extends State<AppSidebarProvider> {
  late bool _isExpanded;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.defaultOpen;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _toggle() {
    final isMobile = _isMobile(context);
    if (isMobile) {
      _openMobileSheet(context);
    } else {
      setState(() => _isExpanded = !_isExpanded);
    }
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < widget.mobileBreakpoint;
  }

  void _openMobileSheet(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Sidebar',
      barrierColor: Colors.black.withAlpha(204),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        final slide = Tween<Offset>(
          begin: widget.side == AppSidebarSide.left
              ? const Offset(-1, 0)
              : const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        return Stack(
          children: [
            // Dismiss barrier
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ),
            Positioned(
              left: widget.side == AppSidebarSide.left ? 0 : null,
              right: widget.side == AppSidebarSide.right ? 0 : null,
              top: 0,
              bottom: 0,
              width: kSidebarWidthMobile,
              child: SlideTransition(
                position: slide,
                child: Material(
                  color: Theme.of(ctx).scaffoldBackgroundColor,
                  child: AppSidebarState(
                    isExpanded: true,
                    isMobile: true,
                    toggleSidebar: () => Navigator.of(ctx).pop(),
                    child: widget.sidebar,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = _isMobile(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);

    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.keyB &&
            HardwareKeyboard.instance.isControlPressed) {
          _toggle();
        }
      },
      child: AppSidebarState(
        isExpanded: _isExpanded,
        isMobile: isMobile,
        toggleSidebar: _toggle,
        child: Row(
          children: [
            // Sidebar (hidden on mobile — shown via sheet)
            if (!isMobile &&
                widget.side == AppSidebarSide.left)
              _DesktopSidebar(
                isExpanded: _isExpanded,
                variant: widget.variant,
                borderSide: BorderSide(color: borderColor),
                borderOnRight: true,
                child: widget.sidebar,
              ),

            // Main content
            Expanded(child: widget.child),

            if (!isMobile &&
                widget.side == AppSidebarSide.right)
              _DesktopSidebar(
                isExpanded: _isExpanded,
                variant: widget.variant,
                borderSide: BorderSide(color: borderColor),
                borderOnRight: false,
                child: widget.sidebar,
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Desktop sidebar wrapper with animated width
// ---------------------------------------------------------------------------

class _DesktopSidebar extends StatelessWidget {
  final bool isExpanded;
  final AppSidebarVariant variant;
  final BorderSide borderSide;
  final bool borderOnRight;
  final Widget child;

  const _DesktopSidebar({
    required this.isExpanded,
    required this.variant,
    required this.borderSide,
    required this.borderOnRight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final targetWidth = isExpanded ? kSidebarWidth : kSidebarWidthIcon;
    final theme = Theme.of(context);

    final isFloating = variant == AppSidebarVariant.floating;
    final isInset = variant == AppSidebarVariant.inset;

    Widget sidebarBody = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: targetWidth,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          maxWidth: kSidebarWidth,
          minWidth: kSidebarWidth,
          child: child,
        ),
      ),
    );

    if (isFloating) {
      sidebarBody = Padding(
        padding: const EdgeInsets.all(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: isExpanded
              ? kSidebarWidth - 16
              : kSidebarWidthIcon - 16 + 8,
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderSide.color),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxWidth: kSidebarWidth - 16,
            minWidth: kSidebarWidth - 16,
            child: child,
          ),
        ),
      );
    } else if (!isInset) {
      sidebarBody = Container(
        decoration: BoxDecoration(
          border: Border(
            right: borderOnRight ? borderSide : BorderSide.none,
            left: borderOnRight ? BorderSide.none : borderSide,
          ),
        ),
        child: sidebarBody,
      );
    }

    return sidebarBody;
  }
}

// ---------------------------------------------------------------------------
// Composable sidebar sub-widgets
// ---------------------------------------------------------------------------

/// Sidebar header section — equivalent to `<SidebarHeader>`.
class AppSidebarHeader extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AppSidebarHeader({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}

/// Sidebar footer section — equivalent to `<SidebarFooter>`.
class AppSidebarFooter extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AppSidebarFooter({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(padding: padding, child: child);
  }
}

/// Scrollable content area — equivalent to `<SidebarContent>`.
class AppSidebarContent extends StatelessWidget {
  final List<Widget> children;

  const AppSidebarContent({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// Group with optional label — equivalent to `<SidebarGroup>` + `<SidebarGroupLabel>`.
class AppSidebarGroup extends StatelessWidget {
  final String? label;
  final List<Widget> children;

  const AppSidebarGroup({
    super.key,
    this.label,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final sidebarState = AppSidebarState.maybeOf(context);
    final isCollapsed = sidebarState != null && !sidebarState.isExpanded;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null && !isCollapsed)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                label!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.grey[500]
                      : Colors.grey.withAlpha(179),
                ),
              ),
            ),
          ...children,
        ],
      ),
    );
  }
}

/// Menu button item — equivalent to `<SidebarMenuButton>`.
class AppSidebarMenuButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  final String? badge;
  final String? tooltip;

  const AppSidebarMenuButton({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
    this.badge,
    this.tooltip,
  });

  @override
  State<AppSidebarMenuButton> createState() => _AppSidebarMenuButtonState();
}

class _AppSidebarMenuButtonState extends State<AppSidebarMenuButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sidebarState = AppSidebarState.maybeOf(context);
    final isCollapsed =
        sidebarState != null && !sidebarState.isExpanded && !sidebarState.isMobile;

    final accentBg = isDark
        ? Colors.white.withAlpha(13)
        : Colors.grey.withAlpha(26);

    final bgColor = widget.isActive
        ? accentBg
        : (_hovered ? accentBg : Colors.transparent);

    final textColor = widget.isActive
        ? theme.textTheme.bodyLarge?.color
        : (isDark ? Colors.grey[400] : Colors.grey[600]);

    Widget button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 32,
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 0 : 8,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: isCollapsed
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              IconTheme(
                data: IconThemeData(
                  size: 16,
                  color: textColor,
                ),
                child: widget.icon,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: widget.isActive
                          ? FontWeight.w500
                          : FontWeight.w400,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (widget.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: isDark
                          ? Colors.white.withAlpha(13)
                          : Colors.grey.withAlpha(26),
                    ),
                    child: Text(
                      widget.badge!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );

    // Tooltip when collapsed
    if (isCollapsed && widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip ?? widget.label,
        preferBelow: false,
        verticalOffset: 0,
        child: button,
      );
    }

    return button;
  }
}

/// Separator inside the sidebar — equivalent to `<SidebarSeparator>`.
class AppSidebarSeparator extends StatelessWidget {
  const AppSidebarSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        height: 1,
        color: isDark ? Colors.white.withAlpha(18) : Colors.grey.withAlpha(38),
      ),
    );
  }
}

/// Toggle trigger button — equivalent to `<SidebarTrigger>`.
class AppSidebarTrigger extends StatelessWidget {
  const AppSidebarTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    final sidebarState = AppSidebarState.of(context);

    return IconButton(
      icon: const Icon(Icons.menu_rounded, size: 18),
      onPressed: sidebarState.toggleSidebar,
      splashRadius: 16,
      tooltip: 'Toggle Sidebar',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
    );
  }
}

/// Sub-menu with left border — equivalent to `<SidebarMenuSub>`.
class AppSidebarMenuSub extends StatelessWidget {
  final List<Widget> children;

  const AppSidebarMenuSub({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51);

    return Padding(
      padding: const EdgeInsets.only(left: 24),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: borderColor)),
        ),
        padding: const EdgeInsets.only(left: 10, top: 2, bottom: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

/// Sub-menu button — equivalent to `<SidebarMenuSubButton>`.
class AppSidebarMenuSubButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const AppSidebarMenuSubButton({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  State<AppSidebarMenuSubButton> createState() =>
      _AppSidebarMenuSubButtonState();
}

class _AppSidebarMenuSubButtonState extends State<AppSidebarMenuSubButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final accentBg = isDark
        ? Colors.white.withAlpha(13)
        : Colors.grey.withAlpha(26);

    final bgColor = widget.isActive
        ? accentBg
        : (_hovered ? accentBg : Colors.transparent);

    final textColor = widget.isActive
        ? theme.textTheme.bodyLarge?.color
        : (isDark ? Colors.grey[400] : Colors.grey[600]);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

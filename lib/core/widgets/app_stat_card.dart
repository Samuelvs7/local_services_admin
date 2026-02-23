import 'package:flutter/material.dart';

/// Accent color variants for the stat card.
enum StatCardAccent { primary, success, warning, destructive, info }

/// Trend data for a stat card.
class StatCardTrend {
  final double value;
  final bool positive;

  const StatCardTrend({required this.value, required this.positive});
}

/// A glassmorphic stat card equivalent to the custom StatCard component.
///
/// Displays a KPI/metric with title, large value, optional subtext,
/// optional trend percentage, and an accent-colored icon.
///
/// ```dart
/// AppStatCard(
///   title: 'Total Revenue',
///   value: '\$12,450',
///   subtext: 'Last 30 days',
///   icon: Icons.attach_money_rounded,
///   trend: StatCardTrend(value: 12.5, positive: true),
///   accent: StatCardAccent.success,
/// )
/// ```
class AppStatCard extends StatefulWidget {
  final String title;
  final String value;
  final String? subtext;
  final IconData icon;
  final StatCardTrend? trend;
  final StatCardAccent accent;
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtext,
    required this.icon,
    this.trend,
    this.accent = StatCardAccent.primary,
    this.onTap,
  });

  @override
  State<AppStatCard> createState() => _AppStatCardState();
}

class _AppStatCardState extends State<AppStatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = _accentColors(theme, widget.accent);

    final cardBg = isDark
        ? Colors.white.withAlpha(8)
        : Colors.white.withAlpha(204);

    final borderColor = _hovered
        ? colors.borderHover
        : (isDark ? Colors.white.withAlpha(18) : Colors.grey.withAlpha(38));

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: colors.iconBg.withAlpha(31),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      widget.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                        color: isDark
                            ? Colors.grey[500]
                            : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Value
                    Text(
                      widget.value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: theme.textTheme.bodyLarge?.color,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),

                    // Subtext
                    if (widget.subtext != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.subtext!,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey[600]
                              : Colors.grey[400],
                        ),
                      ),
                    ],

                    // Trend
                    if (widget.trend != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${widget.trend!.positive ? '↑' : '↓'} '
                            '${widget.trend!.value.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: widget.trend!.positive
                                  ? _successColor(isDark)
                                  : _destructiveColor(isDark),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'vs last week',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? Colors.grey[600]
                                  : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 20,
                    color: colors.iconFg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _successColor(bool isDark) =>
      isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);

  Color _destructiveColor(bool isDark) =>
      isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);

  _AccentColors _accentColors(ThemeData theme, StatCardAccent accent) {
    final isDark = theme.brightness == Brightness.dark;

    switch (accent) {
      case StatCardAccent.primary:
        final c = theme.colorScheme.primary;
        return _AccentColors(
          iconBg: c.withAlpha(38),
          iconFg: c,
          borderHover: c.withAlpha(77),
        );
      case StatCardAccent.success:
        final c = isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);
        return _AccentColors(
          iconBg: c.withAlpha(38),
          iconFg: c,
          borderHover: c.withAlpha(77),
        );
      case StatCardAccent.warning:
        final c = isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
        return _AccentColors(
          iconBg: c.withAlpha(38),
          iconFg: c,
          borderHover: c.withAlpha(77),
        );
      case StatCardAccent.destructive:
        final c = isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444);
        return _AccentColors(
          iconBg: c.withAlpha(38),
          iconFg: c,
          borderHover: c.withAlpha(77),
        );
      case StatCardAccent.info:
        final c = isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6);
        return _AccentColors(
          iconBg: c.withAlpha(38),
          iconFg: c,
          borderHover: c.withAlpha(77),
        );
    }
  }
}

class _AccentColors {
  final Color iconBg;
  final Color iconFg;
  final Color borderHover;

  const _AccentColors({
    required this.iconBg,
    required this.iconFg,
    required this.borderHover,
  });
}

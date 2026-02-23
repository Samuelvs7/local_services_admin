import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// ─── Chart Config ──────────────────────────────────────────────────────────────
/// Equivalent to the React ChartConfig type.
/// Maps a data key to a label, color, and optional icon.
class ChartSeriesConfig {
  final String label;
  final Color color;
  final IconData? icon;

  const ChartSeriesConfig({
    required this.label,
    required this.color,
    this.icon,
  });
}

typedef ChartConfig = Map<String, ChartSeriesConfig>;

// ─── Chart Container ───────────────────────────────────────────────────────────
/// A themed wrapper for fl_chart widgets, similar to ChartContainer in chart.tsx.
/// Provides consistent padding, aspect ratio, and theme-aware styling.
class AppChartContainer extends StatelessWidget {
  final Widget child;
  final ChartConfig config;
  final double? aspectRatio;
  final EdgeInsets? padding;

  const AppChartContainer({
    super.key,
    required this.child,
    required this.config,
    this.aspectRatio,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );

    if (aspectRatio != null) {
      content = AspectRatio(
        aspectRatio: aspectRatio!,
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(26) : Colors.grey.withAlpha(51),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 51 : 13),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: content,
      ),
    );
  }
}

// ─── Chart Tooltip ─────────────────────────────────────────────────────────────
/// A custom tooltip widget for fl_chart, matching the shadcn ChartTooltipContent.
class AppChartTooltip extends StatelessWidget {
  final String? title;
  final List<AppChartTooltipItem> items;
  final AppChartTooltipIndicator indicator;

  const AppChartTooltip({
    super.key,
    this.title,
    required this.items,
    this.indicator = AppChartTooltipIndicator.dot,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(15) : Colors.grey.withAlpha(38),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 6),
          ],
          ...items.map((item) => _buildItem(item, theme, isDark)),
        ],
      ),
    );
  }

  Widget _buildItem(AppChartTooltipItem item, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicator
          _buildIndicator(item.color),
          const SizedBox(width: 8),
          // Label
          Text(
            item.label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
          // Value
          Text(
            item.value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(Color color) {
    switch (indicator) {
      case AppChartTooltipIndicator.dot:
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case AppChartTooltipIndicator.line:
        return Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case AppChartTooltipIndicator.dashed:
        return Container(
          width: 0,
          height: 14,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: 1.5, style: BorderStyle.solid),
            ),
          ),
        );
    }
  }
}

enum AppChartTooltipIndicator { dot, line, dashed }

class AppChartTooltipItem {
  final String label;
  final String value;
  final Color color;

  const AppChartTooltipItem({
    required this.label,
    required this.value,
    required this.color,
  });
}

// ─── Chart Legend ──────────────────────────────────────────────────────────────
/// A legend widget matching shadcn ChartLegendContent.
class AppChartLegend extends StatelessWidget {
  final ChartConfig config;
  final List<String>? visibleKeys;
  final Alignment alignment;

  const AppChartLegend({
    super.key,
    required this.config,
    this.visibleKeys,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final entries = visibleKeys != null
        ? config.entries.where((e) => visibleKeys!.contains(e.key))
        : config.entries;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: entries.map((entry) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry.value.icon != null)
                Icon(entry.value.icon, size: 12, color: entry.value.color)
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: entry.value.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              const SizedBox(width: 6),
              Text(
                entry.value.label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Convenience Builders ──────────────────────────────────────────────────────

/// Helper to build a themed BarChart from ChartConfig.
class AppBarChart extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final ChartConfig config;
  final FlTitlesData? titlesData;
  final FlGridData? gridData;
  final FlBorderData? borderData;
  final double? maxY;

  const AppBarChart({
    super.key,
    required this.barGroups,
    required this.config,
    this.titlesData,
    this.gridData,
    this.borderData,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        maxY: maxY,
        titlesData: titlesData ?? _defaultTitles(isDark),
        gridData: gridData ?? _defaultGrid(isDark),
        borderData: borderData ?? FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => isDark ? const Color(0xFF1E1E2E) : Colors.white,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toStringAsFixed(0),
                TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  FlTitlesData _defaultTitles(bool isDark) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            child: Text(
              value.toInt().toString(),
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            child: Text(
              value.toInt().toString(),
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  FlGridData _defaultGrid(bool isDark) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 1,
      getDrawingHorizontalLine: (value) => FlLine(
        color: isDark ? Colors.white.withAlpha(15) : Colors.grey.withAlpha(30),
        strokeWidth: 1,
      ),
    );
  }
}

/// Helper to build a themed LineChart from ChartConfig.
class AppLineChart extends StatelessWidget {
  final List<LineChartBarData> lineBarsData;
  final ChartConfig config;
  final FlTitlesData? titlesData;
  final FlGridData? gridData;
  final FlBorderData? borderData;
  final double? minY;
  final double? maxY;

  const AppLineChart({
    super.key,
    required this.lineBarsData,
    required this.config,
    this.titlesData,
    this.gridData,
    this.borderData,
    this.minY,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return LineChart(
      LineChartData(
        lineBarsData: lineBarsData,
        minY: minY,
        maxY: maxY,
        titlesData: titlesData ?? _defaultTitles(isDark),
        gridData: gridData ?? _defaultGrid(isDark),
        borderData: borderData ?? FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => isDark ? const Color(0xFF1E1E2E) : Colors.white,
          ),
        ),
      ),
    );
  }

  FlTitlesData _defaultTitles(bool isDark) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            child: Text(
              value.toInt().toString(),
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            child: Text(
              value.toInt().toString(),
              style: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[400],
                fontSize: 10,
              ),
            ),
          ),
        ),
      ),
    );
  }

  FlGridData _defaultGrid(bool isDark) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 1,
      getDrawingHorizontalLine: (value) => FlLine(
        color: isDark ? Colors.white.withAlpha(15) : Colors.grey.withAlpha(30),
        strokeWidth: 1,
      ),
    );
  }
}

/// Helper to build a themed PieChart from ChartConfig.
class AppPieChart extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final ChartConfig config;
  final double? centerSpaceRadius;
  final bool showLegend;

  const AppPieChart({
    super.key,
    required this.sections,
    required this.config,
    this.centerSpaceRadius,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: centerSpaceRadius ?? 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
            ),
          ),
        ),
        if (showLegend) AppChartLegend(config: config),
      ],
    );
  }
}

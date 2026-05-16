import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Horizontal labeled bar chart — used for category breakdowns where
/// label widths vary (post types, audience segments, traffic sources,
/// demographic buckets). Fits narrow viewports better than a vertical
/// bar chart and renders labels without rotation.
class HorizontalBarList extends StatelessWidget {
  const HorizontalBarList({
    super.key,
    required this.entries,
    this.valueFormatter,
    this.maxBars = 6,
  });

  final List<HorizontalBarEntry> entries;
  final String Function(double value)? valueFormatter;
  final int maxBars;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          'No data yet.',
          style: AppTextStyles.bodySmall.copyWith(color: colors.textTertiary),
        ),
      );
    }
    final visible = entries.take(maxBars).toList(growable: false);
    final maxValue = visible
        .map((e) => e.value)
        .fold<double>(0, (a, b) => math.max(a, b));
    final denom = maxValue == 0 ? 1.0 : maxValue;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < visible.length; i++) ...[
          _Row(
            entry: visible[i],
            denom: denom,
            valueFormatter: valueFormatter,
          ),
          if (i != visible.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class HorizontalBarEntry {
  const HorizontalBarEntry({
    required this.label,
    required this.value,
    this.color,
  });
  final String label;
  final double value;
  final Color? color;
}

class _Row extends StatelessWidget {
  const _Row({
    required this.entry,
    required this.denom,
    required this.valueFormatter,
  });
  final HorizontalBarEntry entry;
  final double denom;
  final String Function(double value)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fraction = (entry.value / denom).clamp(0.0, 1.0);
    final formattedValue = valueFormatter?.call(entry.value) ??
        (entry.value >= 1000
            ? '${(entry.value / 1000).toStringAsFixed(1)}k'
            : entry.value % 1 == 0
                ? entry.value.toStringAsFixed(0)
                : entry.value.toStringAsFixed(1));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                entry.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.nano.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              formattedValue,
              style: AppTextStyles.nano.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: colors.bgSurfaceHover,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            FractionallySizedBox(
              widthFactor: fraction == 0 ? 0.01 : fraction,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: entry.color ?? colors.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Line / area chart for a single metric over time. Pass [values] and
/// optional [labels] — labels are not drawn (avoids axis clutter on
/// mobile) but power the tooltip.
class MiniLineChart extends StatelessWidget {
  const MiniLineChart({
    super.key,
    required this.values,
    this.labels = const [],
    this.height = 140,
    this.color,
    this.area = true,
    this.curved = true,
  });

  final List<num> values;
  final List<String> labels;
  final double height;
  final Color? color;
  final bool area;
  final bool curved;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No data yet.',
            style:
                AppTextStyles.bodySmall.copyWith(color: colors.textTertiary),
          ),
        ),
      );
    }
    final c = color ?? colors.accent;
    final maxY =
        values.fold<double>(0, (a, b) => math.max(a, b.toDouble()));
    final yMax = maxY == 0 ? 1.0 : maxY * 1.15;
    final spots = [
      for (int i = 0; i < values.length; i++)
        FlSpot(i.toDouble(), values[i].toDouble()),
    ];
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: yMax,
          minX: 0,
          maxX: (values.length - 1).toDouble().clamp(1, double.infinity),
          gridData: FlGridData(
            show: true,
            horizontalInterval: yMax / 3,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colors.borderDefault.withValues(alpha: 0.35),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  colors.bgSurfaceElevated.withValues(alpha: 0.95),
              getTooltipItems: (spots) => spots.map((spot) {
                final idx = spot.x.toInt();
                final label = idx >= 0 && idx < labels.length
                    ? '${labels[idx]}\n'
                    : '';
                return LineTooltipItem(
                  '$label${_fmt(spot.y)}',
                  AppTextStyles.nano.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: curved,
              color: c,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: area,
                color: c.withValues(alpha: 0.10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _fmt(double v) {
  if (v.abs() >= 1000) return '${(v / 1000).toStringAsFixed(1)}k';
  if (v % 1 == 0) return v.toStringAsFixed(0);
  return v.toStringAsFixed(1);
}

/// Multi-series line chart for the media trend (views, likes, comments,
/// saves). Each entry gets its own colored line + dot in the legend
/// underneath.
class MultiLineChart extends StatelessWidget {
  const MultiLineChart({
    super.key,
    required this.series,
    this.height = 160,
  });

  final List<LineSeries> series;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (series.isEmpty || series.every((s) => s.values.isEmpty)) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No data yet.',
            style:
                AppTextStyles.bodySmall.copyWith(color: colors.textTertiary),
          ),
        ),
      );
    }
    final maxLen =
        series.fold<int>(0, (a, s) => math.max(a, s.values.length));
    final maxY = series.fold<double>(
      0,
      (a, s) => s.values.fold<double>(
        a,
        (acc, v) => math.max(acc, v.toDouble()),
      ),
    );
    final yMax = maxY == 0 ? 1.0 : maxY * 1.15;
    return Column(
      children: [
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: yMax,
              minX: 0,
              maxX: (maxLen - 1).toDouble().clamp(1, double.infinity),
              gridData: FlGridData(
                show: true,
                horizontalInterval: yMax / 3,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: colors.borderDefault.withValues(alpha: 0.35),
                  strokeWidth: 1,
                ),
              ),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                for (final s in series)
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < s.values.length; i++)
                        FlSpot(i.toDouble(), s.values[i].toDouble()),
                    ],
                    isCurved: true,
                    color: s.color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final s in series) _LegendDot(color: s.color, label: s.label),
          ],
        ),
      ],
    );
  }
}

class LineSeries {
  const LineSeries({required this.label, required this.color, required this.values});
  final String label;
  final Color color;
  final List<num> values;
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.nano.copyWith(color: colors.textSecondary),
        ),
      ],
    );
  }
}

/// Donut chart with inline legend. Used for reaction distribution and
/// any "category share of total" breakdowns. Caller supplies entries
/// pre-sorted (largest first reads best on mobile).
class MiniDonutChart extends StatelessWidget {
  const MiniDonutChart({
    super.key,
    required this.entries,
    this.size = 140,
  });

  final List<DonutEntry> entries;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (entries.isEmpty || entries.every((e) => e.value == 0)) {
      return SizedBox(
        height: size,
        child: Center(
          child: Text(
            'No data yet.',
            style:
                AppTextStyles.bodySmall.copyWith(color: colors.textTertiary),
          ),
        ),
      );
    }
    final total = entries.fold<double>(0, (a, e) => a + e.value);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: size * 0.32,
                  startDegreeOffset: -90,
                  sections: [
                    for (final e in entries)
                      PieChartSectionData(
                        value: e.value,
                        color: e.color,
                        radius: size * 0.18,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _fmt(total),
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: colors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Total',
                    style: AppTextStyles.nano.copyWith(
                      color: colors.textTertiary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final e in entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: e.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          e.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.nano.copyWith(
                            color: colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _fmt(e.value),
                        style: AppTextStyles.nano.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class DonutEntry {
  const DonutEntry({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final double value;
  final Color color;
}

/// Single-row heatmap. Used for both the 24-hour engagement heatmap
/// (24 cells, hour label below every 4 cells) and the 7-day weekday
/// heatmap (7 cells, day initial below each). Cell intensity = value
/// normalized against the max value in the list.
class IntensityHeatmap extends StatelessWidget {
  const IntensityHeatmap({
    super.key,
    required this.values,
    required this.labels,
    this.height = 36,
  });

  /// One value per cell. All cells will be rendered (no truncation).
  final List<double> values;

  /// Per-cell labels. Pass null entries for cells you don't want a label
  /// under (e.g. hours 1, 2, 3 between 4-step markers).
  final List<String?> labels;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (values.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(
          'No data yet.',
          style: AppTextStyles.bodySmall.copyWith(color: colors.textTertiary),
        ),
      );
    }
    final maxValue =
        values.fold<double>(0, (a, b) => math.max(a, b));
    final denom = maxValue == 0 ? 1.0 : maxValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: Row(
            children: [
              for (final v in values) ...[
                Expanded(
                  child: _Cell(intensity: (v / denom).clamp(0.0, 1.0)),
                ),
                const SizedBox(width: 2),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            for (final l in labels) ...[
              Expanded(
                child: l == null
                    ? const SizedBox.shrink()
                    : Text(
                        l,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.nano.copyWith(
                          color: colors.textTertiary,
                          fontSize: 9,
                        ),
                      ),
              ),
              const SizedBox(width: 2),
            ],
          ],
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.intensity});
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Stepped intensity so the heatmap reads at a glance — 5 buckets.
    final bucket = (intensity * 4).round();
    final alpha = switch (bucket) {
      0 => 0.04,
      1 => 0.18,
      2 => 0.36,
      3 => 0.58,
      _ => 0.85,
    };
    return Container(
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

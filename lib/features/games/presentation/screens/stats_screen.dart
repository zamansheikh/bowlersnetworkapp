import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/stats_detail.dart';
import '../../domain/entities/user_game_stats.dart';
import '../bloc/stats_bloc.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatsBloc>(
      create: (_) => getIt<StatsBloc>()..add(const StatsLoadRequested()),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Game analytics'),
        leading: const AppBackButton(),
      ),
      body: BlocBuilder<StatsBloc, StatsState>(
        builder: (context, state) {
          if (state.loading && state.stats == null) {
            return const _StatsSkeleton();
          }
          if (state.stats == null) {
            return EmptyState(
              icon: LucideIcons.target,
              title: 'No game data yet',
              hint: state.errors.isNotEmpty
                  ? state.errors.join('\n')
                  : 'Bowl some games to unlock analytics.',
            );
          }
          return RefreshIndicator(
            color: colors.accent,
            onRefresh: () async {
              context.read<StatsBloc>().add(const StatsRefreshRequested());
              await context
                  .read<StatsBloc>()
                  .stream
                  .firstWhere((s) => !s.refreshing);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.xl,
              ),
              children: [
                _HeroStats(stats: state.stats!),
                const SizedBox(height: AppSpacing.md),
                if (state.trends.isNotEmpty) ...[
                  _TrendsCard(
                    trends: state.trends,
                    rangeDays: state.trendRangeDays,
                    onRangeChanged: (d) => context
                        .read<StatsBloc>()
                        .add(StatsTrendRangeChanged(d)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (state.spares.isNotEmpty) ...[
                  _SectionHeading(label: 'SPARE CONVERSION'),
                  const SizedBox(height: AppSpacing.sm),
                  _SpareCard(spares: state.spares),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (state.pinLeaves.isNotEmpty) ...[
                  _SectionHeading(label: 'TOP PIN LEAVES'),
                  const SizedBox(height: AppSpacing.sm),
                  _PinLeavesCard(leaves: state.pinLeaves),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (state.byContext.isNotEmpty) ...[
                  _SectionHeading(label: 'BY CONTEXT'),
                  const SizedBox(height: AppSpacing.sm),
                  _PerformanceListCard(
                    rows: [
                      for (final c in state.byContext)
                        _PerfRow(
                          label: GameContext.fromString(c.gameContext).label,
                          avg: c.avgScore,
                          count: c.gamesCount,
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (state.byCenter.isNotEmpty) ...[
                  _SectionHeading(label: 'BY CENTER'),
                  const SizedBox(height: AppSpacing.sm),
                  _PerformanceListCard(
                    rows: [
                      for (final c in state.byCenter)
                        _PerfRow(
                          label: c.centerName,
                          avg: c.avgScore,
                          count: c.gamesCount,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Hero — 4 metric cards.
// ═══════════════════════════════════════════════════════════════════════════
class _HeroStats extends StatelessWidget {
  const _HeroStats({required this.stats});
  final UserGameStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      children: [
        _HeroTile(
          label: 'Average',
          value: stats.currentAverage.toStringAsFixed(1),
          icon: LucideIcons.trendingUp,
          tint: colors.accent,
        ),
        _HeroTile(
          label: 'High game',
          value: '${stats.highGame}',
          icon: LucideIcons.zap,
          tint: const Color(0xFFEAB308),
        ),
        _HeroTile(
          label: 'High series',
          value: '${stats.highSeries}',
          icon: LucideIcons.trophy,
          tint: const Color(0xFFF97316),
        ),
        _HeroTile(
          label: 'Strikes',
          value: '${stats.strikePercentage.toStringAsFixed(0)}%',
          icon: LucideIcons.target,
          tint: const Color(0xFF22C55E),
        ),
      ],
    );
  }
}

class _HeroTile extends StatelessWidget {
  const _HeroTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.xlAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tint),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.numberLarge.copyWith(
              color: colors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.nano.copyWith(
              color: colors.textTertiary,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Trends — line chart with rolling average + range toggle.
// ═══════════════════════════════════════════════════════════════════════════
class _TrendsCard extends StatelessWidget {
  const _TrendsCard({
    required this.trends,
    required this.rangeDays,
    required this.onRangeChanged,
  });

  final List<TrendPoint> trends;
  final int rangeDays;
  final ValueChanged<int> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spots = <FlSpot>[
      for (var i = 0; i < trends.length; i++)
        FlSpot(i.toDouble(), trends[i].score.toDouble()),
    ];
    final avgSpots = <FlSpot>[
      for (var i = 0; i < trends.length; i++)
        FlSpot(i.toDouble(), trends[i].rollingAverage),
    ];
    final maxY = trends.map((t) => t.score).fold<int>(0, (a, b) => b > a ? b : a);
    final yMax = ((maxY / 30).ceil() * 30).clamp(60, 300).toDouble();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(LucideIcons.trendingUp, size: 16, color: colors.accent),
              const SizedBox(width: 8),
              Text(
                'Score trends',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              _RangePill(days: 7, active: rangeDays == 7, onTap: onRangeChanged),
              const SizedBox(width: 4),
              _RangePill(days: 30, active: rangeDays == 30, onTap: onRangeChanged),
              const SizedBox(width: 4),
              _RangePill(days: 90, active: rangeDays == 90, onTap: onRangeChanged),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: yMax,
                minX: 0,
                maxX: (trends.length - 1).toDouble().clamp(1, double.infinity),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: yMax / 4,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: colors.borderDefault.withValues(alpha: 0.4),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: yMax / 4,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: AppTextStyles.nano.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: colors.accent.withValues(alpha: 0.5),
                    barWidth: 1.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                        radius: 2.5,
                        color: colors.accent,
                        strokeWidth: 0,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: avgSpots,
                    isCurved: true,
                    color: colors.accent,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: colors.accent.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                color: colors.accent.withValues(alpha: 0.5),
                label: 'Per game',
              ),
              const SizedBox(width: AppSpacing.md),
              _LegendDot(color: colors.accent, label: 'Rolling average'),
            ],
          ),
        ],
      ),
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({
    required this.days,
    required this.active,
    required this.onTap,
  });
  final int days;
  final bool active;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: active ? colors.accent.withValues(alpha: 0.15) : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => onTap(days),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Text(
            '${days}d',
            style: AppTextStyles.nano.copyWith(
              color: active ? colors.accent : colors.textTertiary,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
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
          width: 10,
          height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Spare conversion.
// ═══════════════════════════════════════════════════════════════════════════
class _SpareCard extends StatelessWidget {
  const _SpareCard({required this.spares});
  final List<SpareCategoryStat> spares;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < spares.length; i++) ...[
            _SpareRow(stat: spares[i]),
            if (i < spares.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Divider(
                  height: 1,
                  color: colors.borderDefault.withValues(alpha: 0.4),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SpareRow extends StatelessWidget {
  const _SpareRow({required this.stat});
  final SpareCategoryStat stat;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final rate = stat.conversionRate.clamp(0, 1).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                stat.label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${stat.converted}/${stat.total}',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textTertiary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${(rate * 100).toStringAsFixed(0)}%',
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.accent,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: rate,
            backgroundColor: colors.bgSurfaceHover,
            valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Pin leaves — top occurrences list.
// ═══════════════════════════════════════════════════════════════════════════
class _PinLeavesCard extends StatelessWidget {
  const _PinLeavesCard({required this.leaves});
  final List<PinLeaveStat> leaves;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final display = leaves.take(10).toList(growable: false);
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < display.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm + 2,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Text(
                      '#${i + 1}',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          display[i].name.isEmpty
                              ? display[i].leavePattern
                              : display[i].name,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${display[i].occurrenceCount} seen · '
                          '${display[i].conversionCount} converted',
                          style: AppTextStyles.nano.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(display[i].conversionRate * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (i < display.length - 1)
              Divider(
                height: 1,
                color: colors.borderDefault.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Generic "label / avg / count" performance card (by-center, by-context).
// ═══════════════════════════════════════════════════════════════════════════
class _PerfRow {
  const _PerfRow({
    required this.label,
    required this.avg,
    required this.count,
  });
  final String label;
  final double avg;
  final int count;
}

class _PerformanceListCard extends StatelessWidget {
  const _PerformanceListCard({required this.rows});
  final List<_PerfRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm + 2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rows[i].label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${rows[i].count} games',
                    style: AppTextStyles.nano.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    rows[i].avg.toStringAsFixed(1),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(
                height: 1,
                color: colors.borderDefault.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: context.colors.textTertiary,
        ),
      ),
    );
  }
}

class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: [
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.8,
          children: const [
            SkeletonBox(height: 80),
            SkeletonBox(height: 80),
            SkeletonBox(height: 80),
            SkeletonBox(height: 80),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        const SkeletonCard(height: 240),
        const SizedBox(height: AppSpacing.md),
        const SkeletonCard(height: 180),
      ],
    );
  }
}

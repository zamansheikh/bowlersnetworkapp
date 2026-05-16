import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/skeleton_box.dart';
import '../../../domain/entities/games_insights.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../widgets/dashboard_charts.dart';
import '../../widgets/dashboard_metrics.dart';
import '../../widgets/dashboard_section.dart';

/// Games tab — monthly performance report + multi-series trends.
/// Sections:
///   1. Month-at-a-glance card (avg, high game, strike %, spare %)
///   2. Coaching context — strengths, improvements, practice priorities
///   3. Milestones list
///   4. Trends — overlay of averages + strike % over time
class GamesTab extends StatelessWidget {
  const GamesTab({super.key, required this.slot});
  final DashboardGamesSlot slot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (slot.loading && !slot.loaded) {
      return const _Skeleton();
    }
    final report = slot.report;
    final trends = slot.trends;
    final hasNothing =
        (report == null || report.isEmpty) && (trends == null || trends.isEmpty);
    return RefreshIndicator(
      color: colors.accent,
      onRefresh: () async {
        context
            .read<DashboardBloc>()
            .add(const DashboardRefreshRequested());
        await context
            .read<DashboardBloc>()
            .stream
            .firstWhere((s) => !s.games.refreshing);
      },
      child: hasNothing
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 64),
                EmptyState(
                  icon: LucideIcons.target,
                  title: 'No game data yet',
                  hint:
                      'Bowl a few sessions and we\'ll start building your report.',
                ),
              ],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.sm,
                AppSpacing.base,
                AppSpacing.xl,
              ),
              children: [
                if (report != null && !report.isEmpty) ...[
                  _MonthReportCard(report: report),
                  const SizedBox(height: AppSpacing.md),
                  if (report.strengths.isNotEmpty ||
                      report.improvements.isNotEmpty ||
                      report.practicePriorities.isNotEmpty)
                    _CoachingCard(report: report),
                  if (report.milestones.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _MilestonesCard(items: report.milestones),
                  ],
                ],
                if (trends != null && !trends.isEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _TrendsCard(trends: trends),
                ],
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Month report
// ─────────────────────────────────────────────────────────────────────────────

class _MonthReportCard extends StatelessWidget {
  const _MonthReportCard({required this.report});
  final GamesReport report;

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final monthLabel = report.month == null
        ? 'This month'
        : '${_monthNames[report.month!.month - 1]} ${report.month!.year}';
    // Calculate avg delta vs previous month (manually since we have raw values)
    final prev = report.previousMonthAverage;
    double? avgDeltaPct;
    if (prev != null && prev > 0 && report.average > 0) {
      avgDeltaPct = ((report.average - prev) / prev) * 100;
    }
    return DashboardSection(
      title: 'Monthly report',
      subtitle: monthLabel,
      icon: LucideIcons.target,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.5,
        children: [
          StatTile(
            label: 'Games bowled',
            value: '${report.gamesBowled}',
            icon: LucideIcons.target,
          ),
          StatTile(
            label: 'Average',
            value: report.average.toStringAsFixed(1),
            icon: LucideIcons.activity,
            deltaPct: avgDeltaPct,
          ),
          StatTile(
            label: 'High game',
            value: '${report.highGame}',
            icon: LucideIcons.trophy,
          ),
          StatTile(
            label: 'High series',
            value: '${report.highSeries}',
            icon: LucideIcons.medal,
          ),
          StatTile(
            label: 'Strikes',
            value: report.strikePercentage.toStringAsFixed(1),
            suffix: '%',
            icon: LucideIcons.zap,
          ),
          StatTile(
            label: 'Spare conv.',
            value: report.spareConversionRate.toStringAsFixed(1),
            suffix: '%',
            icon: LucideIcons.refreshCw,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coaching context
// ─────────────────────────────────────────────────────────────────────────────

class _CoachingCard extends StatelessWidget {
  const _CoachingCard({required this.report});
  final GamesReport report;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DashboardSection(
      title: 'Coaching insights',
      icon: LucideIcons.lightbulb,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (report.strengths.isNotEmpty)
            _CoachingGroup(
              label: 'Strengths',
              icon: LucideIcons.thumbsUp,
              iconColor: colors.success,
              items: report.strengths,
            ),
          if (report.improvements.isNotEmpty) ...[
            if (report.strengths.isNotEmpty)
              const SizedBox(height: AppSpacing.md),
            _CoachingGroup(
              label: 'Areas to improve',
              icon: LucideIcons.target,
              iconColor: colors.warning,
              items: report.improvements,
            ),
          ],
          if (report.practicePriorities.isNotEmpty) ...[
            if (report.strengths.isNotEmpty || report.improvements.isNotEmpty)
              const SizedBox(height: AppSpacing.md),
            _CoachingGroup(
              label: 'Practice priorities',
              icon: LucideIcons.flag,
              iconColor: colors.accent,
              items: report.practicePriorities,
            ),
          ],
        ],
      ),
    );
  }
}

class _CoachingGroup extends StatelessWidget {
  const _CoachingGroup({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.items,
  });
  final String label;
  final IconData icon;
  final Color iconColor;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.nano.copyWith(
                color: iconColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•  ',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Milestones
// ─────────────────────────────────────────────────────────────────────────────

class _MilestonesCard extends StatelessWidget {
  const _MilestonesCard({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DashboardSection(
      title: 'Milestones',
      icon: LucideIcons.medal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final m in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(LucideIcons.award, size: 14, color: colors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trends (averages + strike % overlay)
// ─────────────────────────────────────────────────────────────────────────────

class _TrendsCard extends StatelessWidget {
  const _TrendsCard({required this.trends});
  final GamesTrends trends;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DashboardSection(
      title: 'Trends',
      subtitle: 'Performance over the selected range',
      icon: LucideIcons.chartLine,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (trends.averages.isNotEmpty) ...[
            Text(
              'Average',
              style: AppTextStyles.nano.copyWith(
                color: colors.textTertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            MiniLineChart(
              values: trends.averages,
              labels: trends.labels,
              height: 140,
            ),
          ],
          if (trends.strikePcts.isNotEmpty || trends.spareRates.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Strike % & spare conv. %',
              style: AppTextStyles.nano.copyWith(
                color: colors.textTertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 4),
            MultiLineChart(
              height: 140,
              series: [
                if (trends.strikePcts.isNotEmpty)
                  LineSeries(
                    label: 'Strike %',
                    color: colors.accent,
                    values: trends.strikePcts,
                  ),
                if (trends.spareRates.isNotEmpty)
                  LineSeries(
                    label: 'Spare %',
                    color: const Color(0xFF4DABF7),
                    values: trends.spareRates,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton
// ─────────────────────────────────────────────────────────────────────────────

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xl,
      ),
      children: const [
        SkeletonBox(height: 220),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 200),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 180),
      ],
    );
  }
}

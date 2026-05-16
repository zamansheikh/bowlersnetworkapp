import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/skeleton_box.dart';
import '../../../domain/entities/xp_insights.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../widgets/dashboard_charts.dart';
import '../../widgets/dashboard_metrics.dart';
import '../../widgets/dashboard_section.dart';

/// XP tab — viewer's experience snapshot. Renders, in order:
///   1. Level + rank hero card with progress bar
///   2. Velocity stats (7d/30d earned, active days, net)
///   3. XP totals trend line chart
///   4. Category breakdown donut + per-category bar
///   5. Top XP-earning actions list
///   6. Activity patterns heatmaps (weekday + hour)
///   7. Streak card + next milestone
///   8. Global rank card
///   9. Recommendations
class XpTab extends StatelessWidget {
  const XpTab({super.key, required this.slot});
  final DashboardXpSlot slot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (slot.loading && !slot.loaded) {
      return const _Skeleton();
    }
    final xp = slot.insights;
    if (xp == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text('No XP data available.'),
        ),
      );
    }
    return RefreshIndicator(
      color: colors.accent,
      onRefresh: () async {
        context
            .read<DashboardBloc>()
            .add(const DashboardRefreshRequested());
        await context
            .read<DashboardBloc>()
            .stream
            .firstWhere((s) => !s.xp.refreshing);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.sm,
          AppSpacing.base,
          AppSpacing.xl,
        ),
        children: [
          _LevelCard(overview: xp.overview, streak: xp.streak),
          const SizedBox(height: AppSpacing.md),
          _VelocityCard(velocity: xp.velocity),
          if (xp.history.xpTotals.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _HistoryCard(history: xp.history),
          ],
          if (xp.categoryBreakdown.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _CategoryCard(entries: xp.categoryBreakdown),
          ],
          if (xp.topActions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _TopActionsCard(actions: xp.topActions),
          ],
          if (xp.patterns.hourlyXp.isNotEmpty ||
              xp.patterns.dailyXp.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _PatternsCard(patterns: xp.patterns),
          ],
          if (xp.streak.currentStreak > 0 ||
              xp.streak.nextMilestone != null) ...[
            const SizedBox(height: AppSpacing.md),
            _StreakDetailCard(streak: xp.streak),
          ],
          if (xp.rank.globalTotalRanked > 0) ...[
            const SizedBox(height: AppSpacing.md),
            _RankCard(rank: xp.rank, projection: xp.projection),
          ],
          if (xp.recommendations.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _RecommendationsCard(items: xp.recommendations),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Level + rank hero card
// ─────────────────────────────────────────────────────────────────────────────

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.overview, required this.streak});
  final XpOverview overview;
  final XpStreak streak;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = (overview.progressPercentage / 100.0).clamp(0.0, 1.0);
    return AppCard(
      showCornerOrb: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LVL',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${overview.level}',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: colors.accent,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
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
                    Text(
                      overview.rankDisplay.isEmpty
                          ? 'Bowler'
                          : overview.rankDisplay,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_compact(overview.totalXp)} total XP',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (streak.currentStreak > 0)
                _StreakBadge(days: streak.currentStreak),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colors.bgSurfaceHover,
              valueColor: AlwaysStoppedAnimation(colors.accent),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${overview.progressPercentage.toStringAsFixed(0)}% to level ${overview.nextLevel ?? overview.level + 1}',
                style: AppTextStyles.nano.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (overview.xpToNextLevel != null)
                Text(
                  '${_compact(overview.xpToNextLevel!)} XP to go',
                  style: AppTextStyles.nano.copyWith(
                    color: colors.textTertiary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.days});
  final int days;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.flame, size: 12, color: colors.warning),
          const SizedBox(width: 4),
          Text(
            '$days',
            style: AppTextStyles.nano.copyWith(
              color: colors.warning,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

String _compact(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
}

// ─────────────────────────────────────────────────────────────────────────────
// Velocity grid
// ─────────────────────────────────────────────────────────────────────────────

class _VelocityCard extends StatelessWidget {
  const _VelocityCard({required this.velocity});
  final XpVelocity velocity;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Velocity',
      subtitle: 'Last 7 and 30 days',
      icon: LucideIcons.zap,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.7,
        children: [
          StatTile(
            label: '7d earned',
            value: _compact(velocity.earned7d),
            icon: LucideIcons.trendingUp,
          ),
          StatTile(
            label: '30d earned',
            value: _compact(velocity.earned30d),
            icon: LucideIcons.calendar,
          ),
          StatTile(
            label: '7d net',
            value:
                '${velocity.net7d >= 0 ? '+' : ''}${_compact(velocity.net7d)}',
            icon: LucideIcons.activity,
          ),
          StatTile(
            label: 'Active days',
            value: '${velocity.activeDays30d}',
            suffix: '/30',
            icon: LucideIcons.flame,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// History line chart
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.history});
  final XpHistory history;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'XP over time',
      subtitle: 'Cumulative total',
      icon: LucideIcons.chartLine,
      child: MiniLineChart(
        values: history.xpTotals,
        labels: history.labels,
        height: 160,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category breakdown
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.entries});
  final List<XpCategoryEntry> entries;

  static const _palette = [
    Color(0xFF8BC342),
    Color(0xFFFFA94D),
    Color(0xFF4DABF7),
    Color(0xFFB197FC),
    Color(0xFFFF6B6B),
    Color(0xFFFFD43B),
    Color(0xFF63E6BE),
    Color(0xFF74C0FC),
  ];

  @override
  Widget build(BuildContext context) {
    final sorted = entries.where((e) => e.earned > 0).toList(growable: false)
      ..sort((a, b) => b.earned.compareTo(a.earned));
    final donutEntries = [
      for (int i = 0; i < sorted.length; i++)
        DonutEntry(
          label: _titleCase(sorted[i].category),
          value: sorted[i].earned.toDouble(),
          color: _palette[i % _palette.length],
        ),
    ];
    return DashboardSection(
      title: 'Where your XP came from',
      icon: LucideIcons.chartPie,
      child: MiniDonutChart(entries: donutEntries),
    );
  }
}

String _titleCase(String input) {
  if (input.isEmpty) return input;
  return input
      .split(RegExp(r'[_\s]+'))
      .map((w) =>
          w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ');
}

// ─────────────────────────────────────────────────────────────────────────────
// Top actions list
// ─────────────────────────────────────────────────────────────────────────────

class _TopActionsCard extends StatelessWidget {
  const _TopActionsCard({required this.actions});
  final List<XpActionEntry> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DashboardSection(
      title: 'Top earning actions',
      icon: LucideIcons.trophy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final a in actions.take(5))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _titleCase(a.action),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${a.count} action${a.count == 1 ? '' : 's'}',
                          style: AppTextStyles.nano.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '+${_compact(a.earned)} XP',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.accent,
                        fontWeight: FontWeight.w800,
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
// Activity patterns
// ─────────────────────────────────────────────────────────────────────────────

class _PatternsCard extends StatelessWidget {
  const _PatternsCard({required this.patterns});
  final XpPatterns patterns;
  static const _dayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hourLabels = <String?>[];
    for (int i = 0; i < patterns.hourlyXp.length; i++) {
      hourLabels.add(i % 4 == 0 ? '${i}h' : null);
    }
    final hint = (patterns.bestDayName.isNotEmpty ||
            patterns.bestHourLabel.isNotEmpty)
        ? '${patterns.bestDayName.isNotEmpty ? patterns.bestDayName : ""}'
            '${patterns.bestDayName.isNotEmpty && patterns.bestHourLabel.isNotEmpty ? " · " : ""}'
            '${patterns.bestHourLabel}'
        : null;
    return DashboardSection(
      title: 'Activity patterns',
      subtitle: hint,
      icon: LucideIcons.clock,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (patterns.dailyXp.isNotEmpty) ...[
            Text(
              'By weekday',
              style: AppTextStyles.nano.copyWith(
                color: colors.textTertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            IntensityHeatmap(
              values: patterns.dailyXp,
              labels: List<String?>.from(_dayInitials)
                  .take(patterns.dailyXp.length)
                  .toList(growable: false),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (patterns.hourlyXp.isNotEmpty) ...[
            Text(
              'By hour',
              style: AppTextStyles.nano.copyWith(
                color: colors.textTertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            IntensityHeatmap(values: patterns.hourlyXp, labels: hourLabels),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Streak detail
// ─────────────────────────────────────────────────────────────────────────────

class _StreakDetailCard extends StatelessWidget {
  const _StreakDetailCard({required this.streak});
  final XpStreak streak;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final next = streak.nextMilestone;
    return DashboardSection(
      title: 'Streak',
      subtitle: streak.multiplier > 1
          ? '${streak.multiplier.toStringAsFixed(1)}x XP multiplier active'
          : null,
      icon: LucideIcons.flame,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Current',
                  value: '${streak.currentStreak}',
                  suffix: 'd',
                  icon: LucideIcons.flame,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: StatTile(
                  label: 'Longest',
                  value: '${streak.longestStreak}',
                  suffix: 'd',
                  icon: LucideIcons.trophy,
                ),
              ),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.bgSurfaceHover,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(LucideIcons.target,
                      size: 14, color: colors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Next milestone: ${next.target}-day streak in ${next.daysAway} day${next.daysAway == 1 ? '' : 's'}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rank
// ─────────────────────────────────────────────────────────────────────────────

class _RankCard extends StatelessWidget {
  const _RankCard({required this.rank, required this.projection});
  final XpRank rank;
  final XpProjection projection;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Global standing',
      icon: LucideIcons.medal,
      child: Row(
        children: [
          Expanded(
            child: StatTile(
              label: 'Rank',
              value: '#${rank.globalPosition}',
              icon: LucideIcons.trophy,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: StatTile(
              label: 'Percentile',
              value: rank.globalPercentile.toStringAsFixed(1),
              suffix: '%',
              icon: LucideIcons.chartLine,
            ),
          ),
          if (projection.daysToNextLevel != null) ...[
            const SizedBox(width: 6),
            Expanded(
              child: StatTile(
                label: 'To next lvl',
                value: '${projection.daysToNextLevel}',
                suffix: 'd',
                icon: LucideIcons.clock,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recommendations
// ─────────────────────────────────────────────────────────────────────────────

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard({required this.items});
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DashboardSection(
      title: 'Recommendations',
      icon: LucideIcons.lightbulb,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final tip in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: colors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
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
        SkeletonBox(height: 140),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 160),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 220),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 200),
      ],
    );
  }
}

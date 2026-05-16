import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/skeleton_box.dart';
import '../../../domain/entities/alpha_score.dart';
import '../../../domain/entities/engagement_insights.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../widgets/dashboard_charts.dart';
import '../../widgets/dashboard_metrics.dart';
import '../../widgets/dashboard_section.dart';

/// The Engagement tab — the most data-rich free tab. Renders, in order:
///   1. Impact-score (alpha) card with actionable tips
///   2. Overview tile grid (rate, total, posts, followers)
///   3. Period comparison (weekly / monthly toggle)
///   4. Content performance bars (post types)
///   5. Reactions donut
///   6. Audience reach bars (per-audience-segment)
///   7. Best time to post — daily + hourly heatmaps
///   8. Media analytics — multi-line trend + summary tiles
///   9. Follower growth — area chart + deltas
///  10. Recommendations list
class EngagementTab extends StatelessWidget {
  const EngagementTab({super.key, required this.slot});
  final DashboardEngagementSlot slot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (slot.loading && !slot.loaded) {
      return const _Skeleton();
    }
    final insights = slot.insights;
    return RefreshIndicator(
      color: colors.accent,
      onRefresh: () async {
        context
            .read<DashboardBloc>()
            .add(const DashboardRefreshRequested());
        await context
            .read<DashboardBloc>()
            .stream
            .firstWhere((s) => !s.engagement.refreshing);
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
          if (slot.alpha != null) ...[
            _ImpactCard(alpha: slot.alpha!),
            const SizedBox(height: AppSpacing.md),
          ],
          if (insights != null) ...[
            _OverviewGrid(summary: insights.engagement),
            const SizedBox(height: AppSpacing.md),
            _PeriodComparisonCard(comparison: insights.comparison),
            const SizedBox(height: AppSpacing.md),
            _ContentPerformanceCard(content: insights.content),
            const SizedBox(height: AppSpacing.md),
            _ReactionsCard(reactions: insights.reactions),
            const SizedBox(height: AppSpacing.md),
            _AudienceReachCard(audience: insights.audience),
            const SizedBox(height: AppSpacing.md),
            _BestTimeCard(audience: insights.audience),
            const SizedBox(height: AppSpacing.md),
            _MediaAnalyticsCard(media: insights.media),
            const SizedBox(height: AppSpacing.md),
            _FollowerGrowthCard(growth: insights.followers),
            if (insights.recommendations.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _RecommendationsCard(items: insights.recommendations),
            ],
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Impact (alpha) score
// ─────────────────────────────────────────────────────────────────────────────

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({required this.alpha});
  final AlphaScore alpha;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = _impactColor(colors, alpha.impactLevel);
    return AppCard(
      showCornerOrb: true,
      cornerOrbColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.sparkles, size: 14, color: accent),
              const SizedBox(width: 6),
              Text(
                'Impact score',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (alpha.impactLevel.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    alpha.impactLevel.toUpperCase(),
                    style: AppTextStyles.nano.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${alpha.score}',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/ 100',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (alpha.tips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            for (final tip in alpha.tips.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(LucideIcons.lightbulb,
                        size: 12, color: accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip.text,
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

  Color _impactColor(dynamic colors, String level) {
    final lower = level.toLowerCase();
    if (lower.contains('high') || lower.contains('excellent')) {
      return colors.success;
    }
    if (lower.contains('low') || lower.contains('poor')) {
      return colors.error;
    }
    return colors.accent;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Overview grid (2x2)
// ─────────────────────────────────────────────────────────────────────────────

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.summary});
  final EngagementSummary summary;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Overview',
      icon: LucideIcons.activity,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.7,
        children: [
          StatTile(
            label: 'Engagement rate',
            value: summary.engagementRate.toStringAsFixed(1),
            suffix: '%',
            icon: LucideIcons.heart,
          ),
          StatTile(
            label: 'Total engagement',
            value: _compact(summary.totalEngagement),
            icon: LucideIcons.zap,
          ),
          StatTile(
            label: 'Posts',
            value: '${summary.totalPosts}',
            icon: LucideIcons.fileText,
          ),
          StatTile(
            label: 'Followers',
            value: _compact(summary.followerCount),
            icon: LucideIcons.users,
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
// Period comparison (weekly / monthly toggle)
// ─────────────────────────────────────────────────────────────────────────────

class _PeriodComparisonCard extends StatefulWidget {
  const _PeriodComparisonCard({required this.comparison});
  final PeriodComparison comparison;

  @override
  State<_PeriodComparisonCard> createState() => _PeriodComparisonCardState();
}

class _PeriodComparisonCardState extends State<_PeriodComparisonCard> {
  bool _monthly = false;

  @override
  Widget build(BuildContext context) {
    final snapshot =
        _monthly ? widget.comparison.monthly : widget.comparison.weekly;
    return DashboardSection(
      title: 'Period comparison',
      subtitle: _monthly ? 'vs previous 30 days' : 'vs previous 7 days',
      icon: LucideIcons.chartNoAxesColumn,
      trailing: _Toggle(
        leftLabel: 'Weekly',
        rightLabel: 'Monthly',
        rightActive: _monthly,
        onChanged: (v) => setState(() => _monthly = v),
      ),
      child: snapshot == null
          ? const DashboardEmptyHint()
          : GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.5,
              children: [
                StatTile(
                  label: 'Posts',
                  value: '${snapshot.current.posts}',
                  deltaPct: snapshot.deltas.postsPct,
                ),
                StatTile(
                  label: 'Engagement',
                  value: _compact(snapshot.current.engagement),
                  deltaPct: snapshot.deltas.engagementPct,
                ),
                StatTile(
                  label: 'New followers',
                  value: '${snapshot.current.followersGained}',
                  deltaPct: snapshot.deltas.followersPct,
                ),
                StatTile(
                  label: 'Media views',
                  value: _compact(snapshot.current.mediaViews),
                  deltaPct: snapshot.deltas.mediaViewsPct,
                ),
              ],
            ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({
    required this.leftLabel,
    required this.rightLabel,
    required this.rightActive,
    required this.onChanged,
  });

  final String leftLabel;
  final String rightLabel;
  final bool rightActive;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleSide(
            label: leftLabel,
            active: !rightActive,
            onTap: () => onChanged(false),
          ),
          _ToggleSide(
            label: rightLabel,
            active: rightActive,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleSide extends StatelessWidget {
  const _ToggleSide({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? colors.bgSurfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.nano.copyWith(
            color: active ? colors.textPrimary : colors.textTertiary,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content performance
// ─────────────────────────────────────────────────────────────────────────────

class _ContentPerformanceCard extends StatelessWidget {
  const _ContentPerformanceCard({required this.content});
  final ContentBreakdown content;

  @override
  Widget build(BuildContext context) {
    final entries = content.postTypes
        .where((p) => p.engagementRate > 0 || p.count > 0)
        .map(
          (p) => HorizontalBarEntry(
            label: '${p.type.isEmpty ? "Other" : _titleCase(p.type)} · ${p.count}',
            value: p.engagementRate,
          ),
        )
        .toList(growable: false);
    return DashboardSection(
      title: 'Content performance',
      subtitle: 'Engagement rate by post type',
      icon: LucideIcons.fileText,
      child: HorizontalBarList(
        entries: entries,
        valueFormatter: (v) => '${v.toStringAsFixed(1)}%',
      ),
    );
  }
}

String _titleCase(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

// ─────────────────────────────────────────────────────────────────────────────
// Reactions donut
// ─────────────────────────────────────────────────────────────────────────────

class _ReactionsCard extends StatelessWidget {
  const _ReactionsCard({required this.reactions});
  final ReactionsBreakdown reactions;

  static const _palette = [
    Color(0xFF8BC342),
    Color(0xFFFFA94D),
    Color(0xFFFF6B6B),
    Color(0xFF4DABF7),
    Color(0xFFB197FC),
    Color(0xFFFFD43B),
    Color(0xFF63E6BE),
  ];

  @override
  Widget build(BuildContext context) {
    final sorted = reactions.distribution.entries
        .where((e) => e.value > 0)
        .toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    final entries = [
      for (int i = 0; i < sorted.length; i++)
        DonutEntry(
          label: _titleCase(sorted[i].key),
          value: sorted[i].value.toDouble(),
          color: _palette[i % _palette.length],
        ),
    ];
    return DashboardSection(
      title: 'Reactions',
      subtitle: 'Distribution across your posts',
      icon: LucideIcons.heart,
      child: MiniDonutChart(entries: entries),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Audience reach (per-segment bars)
// ─────────────────────────────────────────────────────────────────────────────

class _AudienceReachCard extends StatelessWidget {
  const _AudienceReachCard({required this.audience});
  final AudienceBreakdown audience;

  @override
  Widget build(BuildContext context) {
    final entries = audience.segments
        .where((s) => s.count > 0 || s.engagementRate > 0)
        .map((s) => HorizontalBarEntry(
              label: '${s.audience} · ${_compact(s.count)}',
              value: s.engagementRate,
            ))
        .toList(growable: false);
    return DashboardSection(
      title: 'Audience reach',
      subtitle: audience.bestAudience.isEmpty
          ? null
          : 'Strongest: ${audience.bestAudience}',
      icon: LucideIcons.users,
      child: HorizontalBarList(
        entries: entries,
        valueFormatter: (v) => '${v.toStringAsFixed(1)}%',
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Best time to post (weekday + hourly heatmaps)
// ─────────────────────────────────────────────────────────────────────────────

class _BestTimeCard extends StatelessWidget {
  const _BestTimeCard({required this.audience});
  final AudienceBreakdown audience;

  static const _dayInitials = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hours = audience.hourlyEngagement;
    // Label every 4th hour (0, 4, 8, …, 20). All others get null so the
    // labels row has the same number of cells as the heatmap row.
    final hourLabels = <String?>[];
    for (int i = 0; i < hours.length; i++) {
      hourLabels.add(i % 4 == 0 ? '${i}h' : null);
    }
    final hint = (audience.bestDayName.isNotEmpty ||
            audience.bestHourLabel.isNotEmpty)
        ? '${audience.bestDayName.isNotEmpty ? audience.bestDayName : ""}'
            '${audience.bestDayName.isNotEmpty && audience.bestHourLabel.isNotEmpty ? " · " : ""}'
            '${audience.bestHourLabel}'
        : null;
    return DashboardSection(
      title: 'Best time to post',
      subtitle: hint,
      icon: LucideIcons.clock,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
            values: audience.dailyEngagement,
            labels: List<String?>.from(_dayInitials)
                .take(audience.dailyEngagement.length)
                .toList(growable: false),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'By hour',
            style: AppTextStyles.nano.copyWith(
              color: colors.textTertiary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          IntensityHeatmap(values: hours, labels: hourLabels),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Media analytics (multi-line trend + summary tiles)
// ─────────────────────────────────────────────────────────────────────────────

class _MediaAnalyticsCard extends StatelessWidget {
  const _MediaAnalyticsCard({required this.media});
  final MediaAnalyticsSummary media;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final series = <LineSeries>[];
    if (media.trend.views.isNotEmpty) {
      series.add(LineSeries(
        label: 'Views',
        color: colors.accent,
        values: media.trend.views,
      ));
    }
    if (media.trend.likes.isNotEmpty) {
      series.add(LineSeries(
        label: 'Likes',
        color: const Color(0xFFFF6B6B),
        values: media.trend.likes,
      ));
    }
    if (media.trend.comments.isNotEmpty) {
      series.add(LineSeries(
        label: 'Comments',
        color: const Color(0xFF4DABF7),
        values: media.trend.comments,
      ));
    }
    if (media.trend.saves.isNotEmpty) {
      series.add(LineSeries(
        label: 'Saves',
        color: const Color(0xFFB197FC),
        values: media.trend.saves,
      ));
    }
    return DashboardSection(
      title: 'Media analytics',
      subtitle: 'Views, likes, comments, saves',
      icon: LucideIcons.video,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 0.95,
            children: [
              _CompactStat(
                label: 'Views',
                value: _compact(media.totalViews),
              ),
              _CompactStat(
                label: 'Likes',
                value: _compact(media.totalLikes),
              ),
              _CompactStat(
                label: 'Comments',
                value: _compact(media.totalComments),
              ),
              _CompactStat(
                label: 'Saves',
                value: _compact(media.totalSaves),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          MultiLineChart(series: series),
        ],
      ),
    );
  }
}

class _CompactStat extends StatelessWidget {
  const _CompactStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label,
            style: AppTextStyles.nano.copyWith(
              color: colors.textTertiary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Follower growth
// ─────────────────────────────────────────────────────────────────────────────

class _FollowerGrowthCard extends StatelessWidget {
  const _FollowerGrowthCard({required this.growth});
  final FollowersGrowth growth;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Follower growth',
      subtitle: 'Net change over period',
      icon: LucideIcons.trendingUp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Followers',
                  value: _compact(growth.currentCount),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: StatTile(
                  label: 'Net change',
                  value:
                      '${growth.netChange >= 0 ? '+' : ''}${growth.netChange}',
                  deltaPct: growth.growthRatePct,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: StatTile(
                  label: 'Gained',
                  value: '${growth.gained}',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: StatTile(
                  label: 'Lost',
                  value: '${growth.lost}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          MiniLineChart(
            values: growth.trend.followerCounts,
            labels: growth.trend.labels,
          ),
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
        SkeletonBox(height: 120),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 140),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 180),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 180),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 220),
      ],
    );
  }
}

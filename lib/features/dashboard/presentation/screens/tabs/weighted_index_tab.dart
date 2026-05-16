import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/skeleton_box.dart';
import '../../../domain/entities/pro_contribution.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../widgets/dashboard_metrics.dart';
import '../../widgets/dashboard_section.dart';

/// Pro Weighted Index tab — viewer's rank in the Pro pool. Renders:
///   1. Personal score hero card with rank + pool % + period deltas
///   2. Per-bucket score breakdown (content / social / growth)
///   3. Cold-start hint if the backend hasn't computed a snapshot yet
class WeightedIndexTab extends StatelessWidget {
  const WeightedIndexTab({super.key, required this.slot});
  final DashboardProContributionSlot slot;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (slot.loading && !slot.loaded) {
      return const _Skeleton();
    }
    final data = slot.data;
    if (data == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Text('No contribution data yet.'),
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
            .firstWhere((s) => !s.weightedIndex.refreshing);
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
          if (!data.hasData)
            EmptyState(
              icon: LucideIcons.hourglass,
              title: 'Calculating your contribution',
              hint:
                  'Your weighted score will appear here after the first daily snapshot is generated.',
            )
          else ...[
            _HeroCard(data: data),
            const SizedBox(height: AppSpacing.md),
            _BucketsCard(data: data),
          ],
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.data});
  final ProContribution data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      showCornerOrb: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.crown, size: 14, color: colors.accent),
              const SizedBox(width: 6),
              Text(
                'Contribution index',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (data.deltas.rankChange != null &&
                  data.deltas.rankChange != 0)
                DeltaPill(percent: data.deltas.rankChange!.toDouble()),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                data.personalScore.toStringAsFixed(1),
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'personal score',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.7,
            children: [
              StatTile(
                label: 'Rank',
                value: '#${data.rank}',
                icon: LucideIcons.trophy,
              ),
              StatTile(
                label: 'Pool size',
                value: '${data.poolSize}',
                icon: LucideIcons.users,
              ),
              StatTile(
                label: 'Pool %',
                value: data.poolPercentage.toStringAsFixed(2),
                suffix: '%',
                icon: LucideIcons.percent,
                deltaPct: data.deltas.poolPercentageChange,
              ),
              StatTile(
                label: 'Window',
                value: data.window.toUpperCase(),
                icon: LucideIcons.calendar,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BucketsCard extends StatelessWidget {
  const _BucketsCard({required this.data});
  final ProContribution data;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Signal breakdown',
      subtitle: 'Where your score comes from',
      icon: LucideIcons.chartColumn,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BucketBar(
            label: 'Content',
            value: data.contentScore,
            icon: LucideIcons.fileText,
          ),
          const SizedBox(height: 10),
          _BucketBar(
            label: 'Social',
            value: data.socialScore,
            icon: LucideIcons.users,
          ),
          const SizedBox(height: 10),
          _BucketBar(
            label: 'Growth',
            value: data.growthScore,
            icon: LucideIcons.trendingUp,
          ),
        ],
      ),
    );
  }
}

class _BucketBar extends StatelessWidget {
  const _BucketBar({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final double value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Backend bucket scores are roughly 0-100. Clamp for the bar fill.
    final fraction = (value / 100.0).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: colors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: AppTextStyles.bodySmall.copyWith(
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
              height: 8,
              decoration: BoxDecoration(
                color: colors.bgSurfaceHover,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            FractionallySizedBox(
              widthFactor: fraction == 0 ? 0.01 : fraction,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: colors.accent,
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
        SkeletonBox(height: 200),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 200),
      ],
    );
  }
}

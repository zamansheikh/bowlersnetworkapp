import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/skeleton_box.dart';
import '../../../domain/entities/pro_audience.dart';
import '../../../domain/entities/pro_referrals.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../widgets/dashboard_charts.dart';
import '../../widgets/dashboard_metrics.dart';
import '../../widgets/dashboard_section.dart';

/// Pro Referrals tab — how the viewer's invite link is performing.
/// Sections:
///   1. Click funnel tiles (total, window, converted, conversion %)
///   2. Daily click trend
///   3. Top countries / device mix bar lists
///   4. Pro attribution card (weighted score + per-bucket counts)
class ProReferralsTab extends StatelessWidget {
  const ProReferralsTab({super.key, required this.slot});
  final DashboardProReferralsSlot slot;

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
          child: Text('No referral data yet.'),
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
            .firstWhere((s) => !s.referrals.refreshing);
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
          _FunnelCard(clicks: data.clicks, referrals: data.referrals),
          if (data.clicks.dailyClicks.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _ClickTrendCard(daily: data.clicks.dailyClicks),
          ],
          if (data.clicks.topCountries.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _BucketCard(
              title: 'Top countries',
              icon: LucideIcons.globe,
              entries: data.clicks.topCountries,
            ),
          ],
          if (data.clicks.deviceMix.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _BucketCard(
              title: 'Device mix',
              icon: LucideIcons.smartphone,
              entries: data.clicks.deviceMix,
            ),
          ],
          if (data.proAttribution != null) ...[
            const SizedBox(height: AppSpacing.md),
            _AttributionCard(attribution: data.proAttribution!),
          ],
        ],
      ),
    );
  }
}

class _FunnelCard extends StatelessWidget {
  const _FunnelCard({required this.clicks, required this.referrals});
  final ReferralClicks clicks;
  final ReferralTotals referrals;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Funnel',
      subtitle: 'Clicks → signups → pro',
      icon: LucideIcons.activity,
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
        children: [
          StatTile(
            label: 'Clicks (window)',
            value: _compact(clicks.windowClicks),
            icon: LucideIcons.mousePointer,
          ),
          StatTile(
            label: 'Total clicks',
            value: _compact(clicks.totalClicks),
            icon: LucideIcons.zap,
          ),
          StatTile(
            label: 'Conversions',
            value: '${clicks.convertedWindow}',
            icon: LucideIcons.userPlus,
          ),
          StatTile(
            label: 'Conv. rate',
            value: clicks.conversionRate.toStringAsFixed(1),
            suffix: '%',
            icon: LucideIcons.percent,
          ),
          StatTile(
            label: 'Referrals (all)',
            value: '${referrals.total}',
            icon: LucideIcons.users,
          ),
          StatTile(
            label: 'Referrals (window)',
            value: '${referrals.inWindow}',
            icon: LucideIcons.calendar,
          ),
        ],
      ),
    );
  }
}

class _ClickTrendCard extends StatelessWidget {
  const _ClickTrendCard({required this.daily});
  final List<DailyCount> daily;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Click trend',
      icon: LucideIcons.chartLine,
      child: MiniLineChart(
        values: daily.map((d) => d.count).toList(growable: false),
        labels: daily.map((d) => d.date).toList(growable: false),
        height: 140,
      ),
    );
  }
}

class _BucketCard extends StatelessWidget {
  const _BucketCard({
    required this.title,
    required this.icon,
    required this.entries,
  });
  final String title;
  final IconData icon;
  final List<KeyLabelCount> entries;

  @override
  Widget build(BuildContext context) {
    final bars = entries
        .where((e) => e.count > 0)
        .map((e) => HorizontalBarEntry(
              label: e.label.isEmpty ? e.key : e.label,
              value: e.count.toDouble(),
            ))
        .toList(growable: false);
    return DashboardSection(
      title: title,
      icon: icon,
      child: HorizontalBarList(
        entries: bars,
        valueFormatter: (v) => v.toStringAsFixed(0),
      ),
    );
  }
}

class _AttributionCard extends StatelessWidget {
  const _AttributionCard({required this.attribution});
  final ProAttribution attribution;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DashboardSection(
      title: 'Pro attribution',
      subtitle:
          'Weighted score reflects the quality of referrals you brought to Pro',
      icon: LucideIcons.crown,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Weighted score',
                  style: AppTextStyles.nano.copyWith(
                    color: colors.accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  attribution.weightedScore.toStringAsFixed(2),
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: colors.accent,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.6,
            children: [
              StatTile(
                label: 'True',
                value: '${attribution.trueCount}',
                icon: LucideIcons.crown,
              ),
              StatTile(
                label: 'Secondary',
                value: '${attribution.secondaryCount}',
                icon: LucideIcons.userPlus,
              ),
              StatTile(
                label: 'Shadow',
                value: '${attribution.shadowCount}',
                icon: LucideIcons.users,
              ),
              StatTile(
                label: 'In window',
                value: '${attribution.windowCount}',
                icon: LucideIcons.calendar,
              ),
            ],
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
        SkeletonBox(height: 180),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 200),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 220),
      ],
    );
  }
}

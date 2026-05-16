import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/skeleton_box.dart';
import '../../../domain/entities/pro_audience.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../widgets/dashboard_charts.dart';
import '../../widgets/dashboard_metrics.dart';
import '../../widgets/dashboard_section.dart';

/// Pro Audience tab — who's following + where they bowl. Renders:
///   1. Follower totals (count + new this window)
///   2. Daily acquisition line chart
///   3. Age / gender / skill distribution bar lists
///   4. Top centers list
class ProAudienceTab extends StatelessWidget {
  const ProAudienceTab({super.key, required this.slot});
  final DashboardProAudienceSlot slot;

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
          child: Text('No audience data yet.'),
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
            .firstWhere((s) => !s.audience.refreshing);
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
          _TotalsCard(data: data),
          if (data.dailyAcquisition.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _AcquisitionCard(daily: data.dailyAcquisition),
          ],
          if (data.ageDistribution.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _BucketCard(
              title: 'Age',
              icon: LucideIcons.calendar,
              entries: data.ageDistribution,
            ),
          ],
          if (data.genderDistribution.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _BucketCard(
              title: 'Gender',
              icon: LucideIcons.user,
              entries: data.genderDistribution,
            ),
          ],
          if (data.skillDistribution.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _BucketCard(
              title: 'Skill level',
              icon: LucideIcons.trophy,
              entries: data.skillDistribution,
            ),
          ],
          if (data.topCenters.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _CentersCard(centers: data.topCenters),
          ],
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.data});
  final ProAudience data;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Audience snapshot',
      icon: LucideIcons.users,
      child: Row(
        children: [
          Expanded(
            child: StatTile(
              label: 'Total followers',
              value: _compact(data.totalFollowers),
              icon: LucideIcons.users,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: StatTile(
              label: 'New this window',
              value:
                  '${data.newFollowersWindow >= 0 ? '+' : ''}${data.newFollowersWindow}',
              icon: LucideIcons.userPlus,
            ),
          ),
        ],
      ),
    );
  }
}

class _AcquisitionCard extends StatelessWidget {
  const _AcquisitionCard({required this.daily});
  final List<DailyCount> daily;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Acquisition over time',
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

class _CentersCard extends StatelessWidget {
  const _CentersCard({required this.centers});
  final List<ProCenterCount> centers;

  @override
  Widget build(BuildContext context) {
    final bars = centers
        .map((c) => HorizontalBarEntry(
              label: c.name.isEmpty ? 'Center #${c.centerId}' : c.name,
              value: c.count.toDouble(),
            ))
        .toList(growable: false);
    return DashboardSection(
      title: 'Top centers',
      subtitle: 'Where your followers bowl',
      icon: LucideIcons.mapPin,
      child: HorizontalBarList(
        entries: bars,
        valueFormatter: (v) => v.toStringAsFixed(0),
        maxBars: 5,
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
        SkeletonBox(height: 120),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 200),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 200),
      ],
    );
  }
}

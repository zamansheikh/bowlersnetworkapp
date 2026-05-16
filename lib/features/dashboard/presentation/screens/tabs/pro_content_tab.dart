import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/skeleton_box.dart';
import '../../../domain/entities/pro_content.dart';
import '../../bloc/dashboard_bloc.dart';
import '../../widgets/dashboard_metrics.dart';
import '../../widgets/dashboard_section.dart';

/// Pro Content tab — what's working in the viewer's post catalog. Renders:
///   1. Summary tiles (posts / videos / splits / discussions / total)
///   2. Posting heatmap — 7×24 cell grid (horizontally scrollable)
///   3. Four "Top by engagement" lists per content type
class ProContentTab extends StatelessWidget {
  const ProContentTab({super.key, required this.slot});
  final DashboardProContentSlot slot;

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
          child: Text('No content data yet.'),
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
            .firstWhere((s) => !s.content.refreshing);
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
          _SummaryCard(summary: data.summary),
          if (data.heatmap.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _HeatmapCard(matrix: data.heatmap),
          ],
          if (data.topPosts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _TopRowsCard(
              title: 'Top posts',
              icon: LucideIcons.fileText,
              rows: data.topPosts,
            ),
          ],
          if (data.topVideos.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _TopRowsCard(
              title: 'Top videos',
              icon: LucideIcons.video,
              rows: data.topVideos,
            ),
          ],
          if (data.topSplits.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _TopRowsCard(
              title: 'Top splits',
              icon: LucideIcons.film,
              rows: data.topSplits,
            ),
          ],
          if (data.topDiscussions.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _TopRowsCard(
              title: 'Top discussions',
              icon: LucideIcons.messageSquare,
              rows: data.topDiscussions,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});
  final ProContentSummary summary;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: 'Content shipped',
      subtitle: 'In the selected window',
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
            label: 'Posts',
            value: '${summary.posts}',
            icon: LucideIcons.fileText,
          ),
          StatTile(
            label: 'Videos',
            value: '${summary.videos}',
            icon: LucideIcons.video,
          ),
          StatTile(
            label: 'Splits',
            value: '${summary.splits}',
            icon: LucideIcons.film,
          ),
          StatTile(
            label: 'Discussions',
            value: '${summary.discussions}',
            icon: LucideIcons.messageSquare,
          ),
        ],
      ),
    );
  }
}

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.matrix});
  final List<List<int>> matrix;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxValue = matrix
        .expand((row) => row)
        .fold<int>(0, (a, b) => b > a ? b : a);
    final denom = maxValue == 0 ? 1 : maxValue;
    return DashboardSection(
      title: 'Posting heatmap',
      subtitle: '7 days × 24 hours — scroll to see all hours',
      icon: LucideIcons.calendar,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hour labels row (0, 4, 8, …)
            Row(
              children: [
                const SizedBox(width: 22),
                for (int h = 0; h < 24; h++)
                  Container(
                    width: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    alignment: Alignment.center,
                    child: Text(
                      h % 4 == 0 ? '$h' : '',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                        fontSize: 8,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (int d = 0; d < matrix.length && d < _dayLabels.length; d++)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        _dayLabels[d],
                        style: AppTextStyles.nano.copyWith(
                          color: colors.textTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    for (int h = 0; h < matrix[d].length; h++)
                      Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(
                            alpha: _alphaFor(matrix[d][h] / denom),
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _alphaFor(double intensity) {
    final clamped = intensity.clamp(0.0, 1.0);
    final bucket = (clamped * 4).round();
    return switch (bucket) {
      0 => 0.04,
      1 => 0.18,
      2 => 0.36,
      3 => 0.58,
      _ => 0.85,
    };
  }
}

class _TopRowsCard extends StatelessWidget {
  const _TopRowsCard({
    required this.title,
    required this.icon,
    required this.rows,
  });
  final String title;
  final IconData icon;
  final List<ProContentRow> rows;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: title,
      subtitle: 'Ranked by engagement',
      icon: icon,
      child: Column(
        children: [
          for (final r in rows.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TopRow(row: r),
            ),
        ],
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  const _TopRow({required this.row});
  final ProContentRow row;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Preview(url: row.previewUrl, kind: row.previewKind),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                row.label.isEmpty ? '(untitled)' : row.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Wrap(
                spacing: 8,
                runSpacing: 2,
                children: [
                  _MiniStat(
                    icon: LucideIcons.eye,
                    value: _compact(row.impressions),
                  ),
                  _MiniStat(
                    icon: LucideIcons.users,
                    value: _compact(row.reach),
                  ),
                  _MiniStat(
                    icon: LucideIcons.heart,
                    value: _compact(row.engagement),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${row.engagementRate.toStringAsFixed(1)}%',
            style: AppTextStyles.nano.copyWith(
              color: colors.accent,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.url, required this.kind});
  final String url;
  final String kind;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final placeholder = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Icon(
        kind == 'video'
            ? LucideIcons.video
            : kind == 'image'
                ? LucideIcons.image
                : LucideIcons.fileText,
        size: 16,
        color: colors.textTertiary,
      ),
    );
    if (url.isEmpty) return placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        height: 48,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => placeholder,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10, color: colors.textTertiary),
        const SizedBox(width: 3),
        Text(
          value,
          style: AppTextStyles.nano.copyWith(
            color: colors.textSecondary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
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
        SkeletonBox(height: 160),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 220),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 240),
      ],
    );
  }
}

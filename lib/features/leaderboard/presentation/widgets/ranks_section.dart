import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/leaderboard.dart';

/// Levels & Ranks tab body — full progression ladder grouped by rank.
/// Each tier shows badge / "Level N" / rank name / XP threshold.
class RanksSection extends StatelessWidget {
  const RanksSection({
    super.key,
    required this.ranks,
    this.myLevel,
  });

  final List<RankGroup> ranks;
  final int? myLevel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: ranks.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, i) {
        final group = ranks[i];
        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                group.rank.name,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              if (group.rank.phase.isNotEmpty)
                Text(
                  group.rank.phase,
                  style: AppTextStyles.secondary
                      .copyWith(color: colors.textTertiary),
                ),
              const SizedBox(height: AppSpacing.md),
              for (final tier in group.tiers) ...[
                _TierRow(
                  tier: tier,
                  isMine: myLevel != null && myLevel == tier.level,
                ),
                if (tier != group.tiers.last)
                  Divider(
                    height: AppSpacing.md,
                    color: colors.borderDefault.withValues(alpha: 0.4),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TierRow extends StatelessWidget {
  const _TierRow({required this.tier, required this.isMine});

  final RankTier tier;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: isMine ? const EdgeInsets.all(8) : EdgeInsets.zero,
      decoration: isMine
          ? BoxDecoration(
              color: colors.accent.withValues(alpha: 0.08),
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: colors.accent.withValues(alpha: 0.4),
              ),
            )
          : null,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              'Lv ${tier.level}',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textTertiary,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Badge(url: tier.badgeIconUrl),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        tier.tier?.name ?? 'Tier',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isMine) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'YOU',
                          style: AppTextStyles.nano.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatNumber(tier.pointsRequired)} XP to unlock',
                  style: AppTextStyles.nano.copyWith(
                    color: colors.textTertiary,
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

class _Badge extends StatelessWidget {
  const _Badge({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (url.isEmpty) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.accentSubtle,
        ),
      );
    }
    return SizedBox(
      width: 36,
      height: 36,
      child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain),
    );
  }
}

String _formatNumber(int n) {
  if (n < 1000) return '$n';
  if (n < 1000000) {
    return '${(n / 1000).toStringAsFixed(n % 1000 >= 100 ? 1 : 0)}K';
  }
  return '${(n / 1000000).toStringAsFixed(1)}M';
}

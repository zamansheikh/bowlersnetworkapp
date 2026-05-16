import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/leaderboard.dart';

/// One row in the rankings list (positions 4+). Mirrors the web:
/// position number → avatar → name + rank_display → XP badge. Self-row
/// gets a tinted bg and a "You" chip; top-10 rows get an accent left bar.
class RankingRow extends StatelessWidget {
  const RankingRow({
    super.key,
    required this.entry,
    required this.isSelf,
    required this.isTopTen,
    this.onTap,
  });

  final LeaderboardEntry entry;
  final bool isSelf;
  final bool isTopTen;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final u = entry.user;
    return Material(
      color: isSelf ? colors.bgSurfaceElevated : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: isTopTen
              ? BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: colors.accent.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                )
              : null,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  '#${entry.position}',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _Avatar(url: u.profilePictureUrl, fallback: u.displayName),
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
                            u.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isSelf) ...[
                          const SizedBox(width: 6),
                          _YouChip(color: colors.accent),
                        ],
                      ],
                    ),
                    if (entry.rankDisplay.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.rankDisplay,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.secondary
                            .copyWith(color: colors.textTertiary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatXpNumber(entry.xpEarned),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    'XP',
                    style: AppTextStyles.nano.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YouChip extends StatelessWidget {
  const _YouChip({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'You',
        style: AppTextStyles.nano.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.fallback});
  final String? url;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial =
        fallback.isEmpty ? '?' : fallback.substring(0, 1).toUpperCase();
    final placeholder = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
        border: Border.all(color: colors.borderStrong),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.bodySmall.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.borderStrong),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: url!,
        fit: BoxFit.cover,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}

String _formatXpNumber(int n) {
  if (n < 1000) return '$n';
  if (n < 1000000) {
    return '${(n / 1000).toStringAsFixed(n % 1000 >= 100 ? 1 : 0)}K';
  }
  return '${(n / 1000000).toStringAsFixed(1)}M';
}

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/network_badge.dart';
import '../../../profile/domain/entities/xp_level_info.dart';

/// Web's `XPHeroCard` — badge + rank/level + progress bar + weekly delta
/// + "X points to reach Level N · Next Rank" footer.
class HomeXpCard extends StatelessWidget {
  const HomeXpCard({super.key, required this.xp, this.onTap});

  final XpLevelInfo xp;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress =
        (xp.progressPercentage.toDouble() / 100).clamp(0.0, 1.0);
    final weekly = xp.weeklyXpChange ?? 0;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.xlAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Badge(url: xp.badgeIconUrl, accent: colors.accent),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  xp.rankDisplay ?? 'Unranked',
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      AppTextStyles.cardTitle.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Icon(
                                LucideIcons.arrowUpRight,
                                size: 14,
                                color: colors.textTertiary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Lv ${xp.level} · ${_formatXp(xp.totalXp)} XP',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: colors.bgSurfaceHover,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.accent),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '${xp.progressPercentage.toStringAsFixed(0)}% completed',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    if (weekly > 0)
                      Text(
                        '+$weekly this week',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      )
                    else if (weekly < 0)
                      Text(
                        '$weekly this week',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.error,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                  ],
                ),
                if (xp.xpToNextLevel != null &&
                    xp.nextRankDisplay != null) ...[
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${xp.xpToNextLevel} points to reach Level '
                      '${xp.nextLevel ?? xp.level + 1} · '
                      '${xp.nextRankDisplay}',
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatXp(int xp) {
    if (xp < 1000) return '$xp';
    if (xp < 1000000) {
      return '${(xp / 1000).toStringAsFixed(xp % 1000 >= 100 ? 1 : 0)}K';
    }
    return '${(xp / 1000000).toStringAsFixed(1)}M';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.url, required this.accent});
  final String? url;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    const size = 48.0;
    if (url == null || url!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Icon(LucideIcons.shield, color: accent, size: 22),
      );
    }
    return NetworkBadge(url: url, size: size, fit: BoxFit.contain);
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/xp_level_info.dart';

/// Rank + level + progress card, mirroring the web's sidebar XP card.
/// Safe to render even when the user has a brand-new account — the parent
/// should check [XpLevelInfo.hasRecord] and skip this widget otherwise.
class XpRankCard extends StatelessWidget {
  const XpRankCard({super.key, required this.xp});

  final XpLevelInfo xp;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = (xp.progressPercentage / 100).clamp(0.0, 1.0).toDouble();
    final rankDisplay =
        xp.rankDisplay ?? (xp.rank != null ? xp.rank! : 'Level ${xp.level}');

    return AppCard(
      highlightBorder: true,
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _BadgeIcon(url: xp.badgeIconUrl),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rankDisplay,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          'Lv ${xp.level}',
                          style: AppTextStyles.number.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '  ·  ',
                          style: AppTextStyles.secondary.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '${_formatXp(xp.totalXp)} XP',
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.number.copyWith(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: colors.accentSubtle,
                  borderRadius: AppRadius.smAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.sparkles, size: 12, color: colors.accent),
                    const SizedBox(width: 4),
                    Text(
                      '${xp.progressPercentage.toStringAsFixed(0)}%',
                      style: AppTextStyles.number.copyWith(
                        color: colors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.fullAll,
            child: Stack(
              children: [
                Container(
                  height: 6,
                  color: colors.bgSurfaceHover,
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.accent,
                          colors.accent.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Progress toward next level',
            style: AppTextStyles.secondary.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatXp(int n) {
    if (n < 1000) return '$n';
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const size = 44.0;
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.accentSubtle,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.accent.withValues(alpha: 0.22)),
      ),
      alignment: Alignment.center,
      child: Icon(LucideIcons.sparkles, size: 20, color: colors.accent),
    );
    if (url == null || url!.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: AppRadius.mdAll,
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../leaderboard/domain/entities/leaderboard.dart';
import 'home_section_card.dart';

/// Top 5 weekly leaderboard preview — small rows showing position medal,
/// name, rank_display, and XP earned this week.
class HomeLeaderboardPreview extends StatelessWidget {
  const HomeLeaderboardPreview({
    super.key,
    required this.entries,
    required this.onViewAll,
  });

  final List<LeaderboardEntry> entries;
  final VoidCallback onViewAll;

  static const _gold = Color(0xFFEAB308);
  static const _silver = Color(0xFF9CA3AF);
  static const _bronze = Color(0xFFFB923C);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return HomeSectionCard(
      icon: LucideIcons.trophy,
      title: 'Weekly Leaderboard',
      iconTint: _gold,
      onViewAll: onViewAll,
      child: entries.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Leaderboard updates weekly.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall
                    .copyWith(color: colors.textTertiary),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < entries.length; i++)
                  _Row(entry: entries[i], index: i),
              ],
            ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.entry, required this.index});
  final LeaderboardEntry entry;
  final int index;

  Color _medalColor() {
    return switch (index) {
      0 => HomeLeaderboardPreview._gold,
      1 => HomeLeaderboardPreview._silver,
      2 => HomeLeaderboardPreview._bronze,
      _ => const Color(0xFF6B7280),
    };
  }

  String _medalEmoji() {
    return switch (index) {
      0 => '🥇',
      1 => '🥈',
      2 => '🥉',
      _ => '${entry.position}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final medal = _medalColor();
    final isPodium = index < 3;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isPodium
                  ? medal.withValues(alpha: 0.15)
                  : colors.bgSurfaceHover,
              borderRadius: AppRadius.smAll,
              border: isPodium
                  ? Border.all(color: medal.withValues(alpha: 0.3))
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              _medalEmoji(),
              style: TextStyle(
                fontSize: isPodium ? 16 : 12,
                fontWeight: FontWeight.w700,
                color: isPodium ? null : colors.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Avatar(
            url: entry.user.profilePictureUrl,
            fallback: entry.user.displayName,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.user.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if ((entry.user.rankDisplay ?? '').isNotEmpty)
                  Text(
                    entry.user.rankDisplay!,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.nano
                        .copyWith(color: colors.textTertiary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${entry.xpEarned}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                'XP',
                style: AppTextStyles.nano
                    .copyWith(color: colors.textTertiary),
              ),
            ],
          ),
        ],
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
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.nano.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => placeholder,
        ),
      ),
    );
  }
}

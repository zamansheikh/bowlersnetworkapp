import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/leaderboard.dart';

/// One pedestal in the 1/2/3 podium. Web layout: avatar with medal-colored
/// ring, name + XP, then a gradient pedestal with the medal emoji. #1 is
/// taller and centered (slot order is 2 / 1 / 3).
class PodiumSlot extends StatelessWidget {
  const PodiumSlot({
    super.key,
    required this.entry,
    required this.place,
    required this.isSelf,
  });

  final LeaderboardEntry entry;
  final int place; // 1 | 2 | 3
  final bool isSelf;

  static const _gold = Color(0xFFEAB308);
  static const _silver = Color(0xFF9CA3AF);
  static const _bronze = Color(0xFFFB923C);

  Color get _medalColor => switch (place) {
        1 => _gold,
        2 => _silver,
        _ => _bronze,
      };

  String get _emoji => switch (place) {
        1 => '🥇',
        2 => '🥈',
        _ => '🥉',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isFirst = place == 1;
    final avatarSize = isFirst ? 56.0 : 44.0;
    final pedestalHeight = isFirst ? 96.0 : (place == 2 ? 72.0 : 56.0);
    final emojiSize = isFirst ? 44.0 : 34.0;
    final medal = _medalColor;

    return SizedBox(
      width: 110,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isFirst) ...[
            Icon(LucideIcons.crown, size: 18, color: medal),
            const SizedBox(height: 4),
          ] else
            const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  medal.withValues(alpha: 0.25),
                  medal.withValues(alpha: 0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: medal.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _Avatar(
              url: entry.user.profilePictureUrl,
              fallback: entry.user.displayName,
              size: avatarSize,
              borderColor: colors.bgPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            entry.user.podiumName,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatXp(entry.xpEarned),
            style: AppTextStyles.bodyMedium.copyWith(
              color: medal,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: pedestalHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(
                top: BorderSide(color: medal.withValues(alpha: 0.3)),
                left: BorderSide(color: medal.withValues(alpha: 0.3)),
                right: BorderSide(color: medal.withValues(alpha: 0.3)),
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  medal.withValues(alpha: 0.2),
                  medal.withValues(alpha: 0.1),
                ],
              ),
            ),
            child: Text(_emoji, style: TextStyle(fontSize: emojiSize, height: 1)),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.fallback,
    required this.size,
    required this.borderColor,
  });

  final String? url;
  final String fallback;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial =
        fallback.isEmpty ? '?' : fallback.substring(0, 1).toUpperCase();
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
        border: Border.all(color: borderColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.accent,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
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

String _formatXp(int xp) {
  if (xp < 1000) return '$xp XP';
  if (xp < 1000000) {
    return '${(xp / 1000).toStringAsFixed(xp % 1000 >= 100 ? 1 : 0)}K XP';
  }
  return '${(xp / 1000000).toStringAsFixed(1)}M XP';
}

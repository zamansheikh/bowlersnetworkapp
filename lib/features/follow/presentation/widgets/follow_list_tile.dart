import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/follow_user.dart';

/// List row used inside both the followers and followings screens. Mirrors
/// the web's people row: avatar, name + @handle + rank, trailing
/// follow/unfollow icon button. The button is hidden for self-rows since
/// `isFollowing` defaults to false for the viewer's own entry.
class FollowListTile extends StatelessWidget {
  const FollowListTile({
    super.key,
    required this.user,
    required this.onToggleFollow,
    required this.isSelf,
    this.onTap,
  });

  final FollowUser user;
  final bool isSelf;
  final VoidCallback onToggleFollow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              _Avatar(url: user.profilePictureUrl, fallback: user.displayName),
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
                            user.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (user.isPro) ...[
                          const SizedBox(width: 6),
                          const _ProBadge(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.rankDisplay == null
                          ? '@${user.username}'
                          : '@${user.username} · ${user.rankDisplay}',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.secondary
                          .copyWith(color: colors.textTertiary),
                    ),
                  ],
                ),
              ),
              if (!isSelf)
                _FollowIconButton(
                  following: user.isFollowing,
                  onPressed: onToggleFollow,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 32×32 icon — matches the post-card follow button design system.
class _FollowIconButton extends StatelessWidget {
  const _FollowIconButton({required this.following, required this.onPressed});
  final bool following;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Icon(
            following ? LucideIcons.userCheck : LucideIcons.userPlus,
            size: 17,
            color: following ? colors.accent : colors.textTertiary,
          ),
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
        fallback.isEmpty ? '?' : fallback.characters.first.toUpperCase();
    final placeholder = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
        border: Border.all(color: colors.borderStrong, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.borderStrong, width: 2),
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

class _ProBadge extends StatelessWidget {
  const _ProBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          colors: [Color(0x33EAB308), Color(0x33F97316)],
        ),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Color(0xFFEAB308),
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          height: 1.2,
        ),
      ),
    );
  }
}

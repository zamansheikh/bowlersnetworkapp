import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'xp_badge.dart';

enum UserChipSize { compact, standard, large }

/// Standard user-display widget. Used anywhere a user appears in a list, card
/// header, or comment row.
class UserChip extends StatelessWidget {
  const UserChip({
    super.key,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.level,
    this.rank,
    this.size = UserChipSize.standard,
    this.isFollowing,
    this.onTap,
    this.onFollowToggle,
    this.subtitle,
  });

  final String username;
  final String? displayName;
  final String? avatarUrl;
  final int? level;
  final String? rank;
  final UserChipSize size;
  final bool? isFollowing;
  final VoidCallback? onTap;
  final VoidCallback? onFollowToggle;
  final String? subtitle;

  double get _avatarSize => switch (size) {
        UserChipSize.compact => 28,
        UserChipSize.standard => 36,
        UserChipSize.large => 48,
      };

  double get _nameFontSize => switch (size) {
        UserChipSize.compact => 12,
        UserChipSize.standard => 14,
        UserChipSize.large => 15,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final name = displayName ?? username;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              _Avatar(url: avatarUrl, size: _avatarSize, fallbackInitial: name),
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
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textPrimary,
                              fontSize: _nameFontSize,
                            ),
                          ),
                        ),
                        if (level != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          XpBadge(level: level!, rank: rank, compact: true),
                        ],
                      ],
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.secondary.copyWith(
                          color: colors.textSecondary,
                        ),
                      )
                    else
                      Text(
                        '@$username',
                        style: AppTextStyles.secondary.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
              if (isFollowing != null)
                IconButton(
                  onPressed: onFollowToggle,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    isFollowing!
                        ? Icons.person_remove_alt_1_outlined
                        : Icons.person_add_alt_1_outlined,
                    size: 18,
                    color: isFollowing! ? colors.textTertiary : colors.accent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.size,
    required this.fallbackInitial,
  });

  final String? url;
  final double size;
  final String fallbackInitial;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = fallbackInitial.isEmpty
        ? '?'
        : fallbackInitial.characters.first.toUpperCase();

    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.accent,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    if (url == null || url!.isEmpty) return placeholder;

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}

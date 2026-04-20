import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

/// Top-of-feed card: avatar + "What's on your mind?" input + action row
/// (Photo / Video / Score / Poll). Tapping opens the full composer sheet
/// (wired in a later step).
class CreatePostComposer extends StatelessWidget {
  const CreatePostComposer({
    super.key,
    required this.currentAvatarUrl,
    required this.currentInitial,
    required this.onOpenText,
    required this.onOpenPhoto,
    required this.onOpenVideo,
    required this.onOpenScore,
    required this.onOpenPoll,
  });

  final String? currentAvatarUrl;
  final String currentInitial;
  final VoidCallback onOpenText;
  final VoidCallback onOpenPhoto;
  final VoidCallback onOpenVideo;
  final VoidCallback onOpenScore;
  final VoidCallback onOpenPoll;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _SmallAvatar(
                url: currentAvatarUrl,
                fallback: currentInitial,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: AppRadius.mdAll,
                    onTap: onOpenText,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: colors.bgSurfaceHover,
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: Text(
                        "What's on your mind?",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            decoration: BoxDecoration(
              border:
                  Border(top: BorderSide(color: colors.borderDefault)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ActionChip(
                    icon: LucideIcons.image,
                    label: 'Photo',
                    color: const Color(0xFF3B82F6),
                    onTap: onOpenPhoto,
                  ),
                ),
                Expanded(
                  child: _ActionChip(
                    icon: LucideIcons.video,
                    label: 'Video',
                    color: const Color(0xFFEF4444),
                    onTap: onOpenVideo,
                  ),
                ),
                Expanded(
                  child: _ActionChip(
                    icon: LucideIcons.target,
                    label: 'Score',
                    color: colors.accent,
                    onTap: onOpenScore,
                  ),
                ),
                Expanded(
                  child: _ActionChip(
                    icon: LucideIcons.chartColumn,
                    label: 'Poll',
                    color: const Color(0xFFA855F7),
                    onTap: onOpenPoll,
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

class _SmallAvatar extends StatelessWidget {
  const _SmallAvatar({required this.url, required this.fallback});

  final String? url;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const size = 36.0;
    final initial =
        fallback.isEmpty ? '?' : fallback.characters.first.toUpperCase();

    final placeholder = Container(
      width: size,
      height: size,
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
          fontSize: 14,
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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.smAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.micro.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

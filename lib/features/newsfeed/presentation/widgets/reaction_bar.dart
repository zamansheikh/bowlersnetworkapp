import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/post.dart';

/// Engagement row beneath a post — mirrors the web frontend's 4-column
/// pattern: [Reactions] [Comments] [Shares] [Save].
///
/// Tap the like button to toggle `Like`. Long-press opens a horizontal
/// picker of all 6 reactions (matches web's hover-to-open picker).
class ReactionBar extends StatelessWidget {
  const ReactionBar({
    super.key,
    required this.post,
    required this.onReact,
    required this.onComment,
    required this.onSave,
    required this.onShare,
  });

  final Post post;
  final ValueChanged<ReactionType> onReact;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.borderDefault)),
      ),
      child: Row(
        children: [
          // ── Reactions column ──
          Expanded(
            child: Row(
              children: [
                _LikeButton(
                  post: post,
                  onReact: onReact,
                  onPickReaction: () => _pickReaction(context),
                ),
                if (post.likesCount > 0) ...[
                  const SizedBox(width: 6),
                  _StackedReactions(post: post),
                  const SizedBox(width: 6),
                  Text(
                    _compactNumber(post.likesCount),
                    style: AppTextStyles.secondary.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ── Comments ──
          _IconCountButton(
            icon: post.commentsCount > 0
                ? Icons.mode_comment_rounded
                : Icons.mode_comment_outlined,
            active: false,
            activeColor: colors.accent,
            count: post.commentsCount,
            onTap: onComment,
          ),
          const SizedBox(width: AppSpacing.sm),
          // ── Share ──
          _IconCountButton(
            icon: Icons.ios_share_rounded,
            active: false,
            activeColor: colors.accent,
            count: post.sharesCount,
            onTap: onShare,
          ),
          const SizedBox(width: AppSpacing.sm),
          // ── Save ──
          _IconCountButton(
            icon: post.hasSaved
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            active: post.hasSaved,
            activeColor: colors.accent,
            count: post.savesCount,
            onTap: onSave,
          ),
        ],
      ),
    );
  }

  Future<void> _pickReaction(BuildContext context) async {
    await HapticFeedback.mediumImpact();
    if (!context.mounted) return;
    final picked = await showModalBottomSheet<ReactionType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ReactionPicker(),
    );
    if (picked != null) onReact(picked);
  }
}

// =============================================================================
class _LikeButton extends StatelessWidget {
  const _LikeButton({
    required this.post,
    required this.onReact,
    required this.onPickReaction,
  });

  final Post post;
  final ValueChanged<ReactionType> onReact;
  final VoidCallback onPickReaction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final r = post.reaction;
    final active = r != null;
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.smAll,
          onTap: () => onReact(r ?? ReactionType.like),
          onLongPress: onPickReaction,
          child: Center(
            child: active
                ? Text(r.emoji, style: const TextStyle(fontSize: 20))
                : Icon(
                    Icons.favorite_border_rounded,
                    size: 20,
                    color: colors.textSecondary,
                  ),
          ),
        ),
      ),
    );
  }
}

class _StackedReactions extends StatelessWidget {
  const _StackedReactions({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    // Always show the user's reaction first (if any). We don't get per-post
    // reaction breakdown from the list endpoint yet, so we fall back to
    // showing Like as the "top" reaction when the viewer hasn't reacted.
    final primary = post.reaction ?? ReactionType.like;
    return Text(
      primary.emoji,
      style: const TextStyle(fontSize: 14, height: 1),
    );
  }
}

class _IconCountButton extends StatelessWidget {
  const _IconCountButton({
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final Color activeColor;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = active ? activeColor : colors.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.smAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Text(
                  _compactNumber(count),
                  style: AppTextStyles.secondary.copyWith(color: color),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
class _ReactionPicker extends StatelessWidget {
  const _ReactionPicker();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.base),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: colors.bgSurfaceElevated,
          borderRadius: AppRadius.xlAll,
          border: Border.all(color: colors.borderDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final r in ReactionType.values)
              _ReactionOption(
                type: r,
                onTap: () => Navigator.of(context).pop(r),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReactionOption extends StatelessWidget {
  const _ReactionOption({required this.type, required this.onTap});

  final ReactionType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(type.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 4),
              Text(
                type.label,
                style: AppTextStyles.micro.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _compactNumber(int n) {
  if (n < 1000) return '$n';
  if (n < 1000000) {
    return '${(n / 1000).toStringAsFixed(n % 1000 >= 100 ? 1 : 0)}K';
  }
  return '${(n / 1000000).toStringAsFixed(1)}M';
}

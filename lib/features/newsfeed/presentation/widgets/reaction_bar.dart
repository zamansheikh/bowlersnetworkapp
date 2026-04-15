import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/post.dart';

/// Row of action buttons beneath a post: react (primary), comment, save,
/// share. Designed to be ~44dp tall to meet touch targets.
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
    final reaction = post.reaction;

    // For now tap cycles through like as the default reaction. Long-press
    // opens the reaction picker (see [_ReactionPicker]).
    return Row(
      children: [
        _ActionButton(
          icon: reaction == null
              ? Icons.favorite_border_rounded
              : Icons.favorite_rounded,
          label: _compactNumber(post.likesCount),
          active: post.hasReacted,
          activeColor: _colorForReaction(reaction, colors.accent),
          onTap: () => onReact(reaction ?? ReactionType.like),
          onLongPress: () => _pickReaction(context),
        ),
        _ActionButton(
          icon: Icons.mode_comment_outlined,
          label: _compactNumber(post.commentsCount),
          active: false,
          activeColor: colors.accent,
          onTap: onComment,
        ),
        _ActionButton(
          icon: post.hasSaved
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          label: _compactNumber(post.savesCount),
          active: post.hasSaved,
          activeColor: colors.accent,
          onTap: onSave,
        ),
        const Spacer(),
        _ActionButton(
          icon: Icons.ios_share_rounded,
          label: _compactNumber(post.sharesCount),
          active: false,
          activeColor: colors.accent,
          onTap: onShare,
        ),
      ],
    );
  }

  Future<void> _pickReaction(BuildContext context) async {
    final picked = await showModalBottomSheet<ReactionType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ReactionPicker(),
    );
    if (picked != null) onReact(picked);
  }

  Color _colorForReaction(ReactionType? r, Color accent) {
    switch (r) {
      case ReactionType.like:
        return Colors.redAccent;
      case ReactionType.fire:
        return Colors.orangeAccent;
      case ReactionType.strike:
        return accent;
      case ReactionType.clap:
        return Colors.amberAccent;
      case ReactionType.wow:
        return Colors.purpleAccent;
      case null:
        return accent;
    }
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
    this.onLongPress,
  });

  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = active ? activeColor : colors.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: AppRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReactionPicker extends StatelessWidget {
  const _ReactionPicker();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const reactions = [
      (ReactionType.like, Icons.favorite_rounded, 'Like', Colors.redAccent),
      (ReactionType.fire, Icons.local_fire_department_rounded, 'Fire',
          Colors.orangeAccent),
      (ReactionType.strike, Icons.bolt_rounded, 'Strike', Color(0xFF8BC342)),
      (ReactionType.clap, Icons.emoji_events_rounded, 'Clap',
          Colors.amberAccent),
      (ReactionType.wow, Icons.auto_awesome_rounded, 'Wow',
          Colors.purpleAccent),
    ];
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.bgSurfaceElevated,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final r in reactions)
              _ReactionOption(
                type: r.$1,
                icon: r.$2,
                label: r.$3,
                color: r.$4,
                onTap: () => Navigator.of(context).pop(r.$1),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReactionOption extends StatelessWidget {
  const _ReactionOption({
    required this.type,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final ReactionType type;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                label,
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
  if (n < 1000000) return '${(n / 1000).toStringAsFixed(n % 1000 >= 100 ? 1 : 0)}K';
  return '${(n / 1000000).toStringAsFixed(1)}M';
}

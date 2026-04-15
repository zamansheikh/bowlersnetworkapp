import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/user_chip.dart';
import '../../domain/entities/post.dart';
import 'reaction_bar.dart';

/// Feed-list post card. Renders author header, caption (3-line clamp + read
/// more), post-type-specific media, and the reaction bar.
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onReact,
    required this.onComment,
    required this.onSave,
    required this.onShare,
    required this.onMore,
    this.onOpenDetail,
  });

  final Post post;
  final ValueChanged<ReactionType> onReact;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onMore;
  final VoidCallback? onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      onTap: onOpenDetail,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: UserChip(
                  username: post.author.username,
                  displayName: post.author.displayName,
                  avatarUrl: post.author.profilePictureUrl,
                  size: UserChipSize.standard,
                  subtitle: timeago.format(post.createdAt, locale: 'en_short'),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: colors.textTertiary,
                ),
                onPressed: onMore,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (post.caption.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              post.caption,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: colors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
          _MediaBlock(post: post),
          const SizedBox(height: AppSpacing.sm),
          ReactionBar(
            post: post,
            onReact: onReact,
            onComment: onComment,
            onSave: onSave,
            onShare: onShare,
          ),
        ],
      ),
    );
  }
}

class _MediaBlock extends StatelessWidget {
  const _MediaBlock({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    switch (post.type) {
      case PostType.photo:
        return _PhotoGallery(urls: post.mediaUrls);
      case PostType.video:
        return _VideoPreview(
          thumbnailUrl: post.videoThumbnailUrl,
        );
      case PostType.score:
        return _ScoreBlock(data: post.typeData ?? const {});
      case PostType.poll:
        return _PollBlock(data: post.typeData ?? const {});
      case PostType.text:
      case PostType.share:
      case PostType.unknown:
        return const SizedBox.shrink();
    }
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({required this.urls});
  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: CachedNetworkImage(
            imageUrl: urls.first,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: colors.bgSurfaceHover),
            errorWidget: (_, _, _) => Container(
              color: colors.bgSurfaceHover,
              alignment: Alignment.center,
              child: Icon(
                Icons.broken_image_outlined,
                color: colors.textTertiary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  const _VideoPreview({required this.thumbnailUrl});
  final String? thumbnailUrl;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: ClipRRect(
        borderRadius: AppRadius.lgAll,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (thumbnailUrl != null)
                CachedNetworkImage(
                  imageUrl: thumbnailUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(color: colors.bgSurfaceHover),
                  errorWidget: (_, _, _) =>
                      Container(color: colors.bgSurfaceHover),
                )
              else
                Container(color: colors.bgSurfaceHover),
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreBlock extends StatelessWidget {
  const _ScoreBlock({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = data['total_score'];
    final gameType = data['game_type'] as String? ?? '';
    final strikePct = data['strike_percentage'];
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgAll,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.accent.withValues(alpha: 0.16),
              colors.accent.withValues(alpha: 0.04),
            ],
          ),
          border: Border.all(
            color: colors.accent.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gameType.toUpperCase(),
                  style: AppTextStyles.label.copyWith(color: colors.accent),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total',
                  style: AppTextStyles.numberLarge.copyWith(
                    color: colors.textPrimary,
                    fontSize: 40,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (strikePct != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'STRIKE %',
                    style: AppTextStyles.label
                        .copyWith(color: colors.textTertiary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${((strikePct as num) * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.numberLarge.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PollBlock extends StatelessWidget {
  const _PollBlock({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final question = data['question'] as String? ?? '';
    final options = (data['options'] as List?) ?? const [];
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (question.isNotEmpty)
            Text(
              question,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          for (final o in options)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.mdAll,
                border: Border.all(color: colors.borderDefault),
              ),
              child: Text(
                (o is Map ? o['text'] : o).toString(),
                style: AppTextStyles.body.copyWith(color: colors.textPrimary),
              ),
            ),
        ],
      ),
    );
  }
}

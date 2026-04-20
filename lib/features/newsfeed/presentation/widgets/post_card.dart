import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/post.dart';
import 'link_preview.dart';
import 'post_media.dart';
import 'post_share_blocks.dart';
import 'reaction_bar.dart';

/// Production-grade feed card that mirrors the web's `_PostCard.tsx`.
class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.onReact,
    required this.onComment,
    required this.onSave,
    required this.onShare,
    required this.onMore,
    this.onOpenDetail,
    this.onAuthorTap,
  });

  final Post post;
  final ValueChanged<ReactionType> onReact;
  final VoidCallback onComment;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onMore;
  final VoidCallback? onOpenDetail;
  final VoidCallback? onAuthorTap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  static const _captionLineClamp = 4;
  static const _captionExpandThreshold = 240;

  bool _captionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final p = widget.post;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              AppSpacing.base,
              AppSpacing.sm,
              0,
            ),
            child: _AuthorRow(
              post: p,
              onTap: widget.onAuthorTap,
              onMore: widget.onMore,
            ),
          ),
          if (p.caption.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: _Caption(
                text: p.caption,
                expanded: _captionExpanded,
                onToggle: () =>
                    setState(() => _captionExpanded = !_captionExpanded),
                expandThreshold: _captionExpandThreshold,
                maxLines: _captionLineClamp,
              ),
            ),
          ],
          // Link/YouTube previews — text posts only, matching web
          // `_PostCard.tsx` line 363.
          if (p.type == PostType.text && p.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: PostLinkPreviews(text: p.caption),
            ),
          _MediaBlock(post: p),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.base,
              0,
              AppSpacing.base,
              AppSpacing.md,
            ),
            child: ReactionBar(
              post: p,
              onReact: widget.onReact,
              onComment: widget.onComment,
              onSave: widget.onSave,
              onShare: widget.onShare,
            ),
          ),
          if (!p.isCommentsEnabled)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                border:
                    Border(top: BorderSide(color: colors.borderDefault)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.messageCircleOff,
                    size: 14,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Author disabled comments',
                    style: AppTextStyles.secondary.copyWith(
                      color: colors.textTertiary,
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

// ─────────────────────────────────────────────────────────────────────────────
class _AuthorRow extends StatelessWidget {
  const _AuthorRow({
    required this.post,
    required this.onTap,
    required this.onMore,
  });

  final Post post;
  final VoidCallback? onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final author = post.author;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Avatar(
          url: author.profilePictureUrl,
          fallback: author.displayName,
          size: 40,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        author.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (author.isPro) ...[
                      const SizedBox(width: 6),
                      const _ProBadge(),
                    ],
                    if (post.isPinned) ...[
                      const SizedBox(width: 6),
                      Icon(
                        LucideIcons.pin,
                        size: 12,
                        color: colors.accent,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '@${author.username}',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.secondary
                            .copyWith(color: colors.textTertiary),
                      ),
                    ),
                    Text(
                      '  ·  ',
                      style: AppTextStyles.secondary
                          .copyWith(color: colors.textTertiary),
                    ),
                    Text(
                      timeago.format(post.createdAt, locale: 'en_short'),
                      style: AppTextStyles.secondary
                          .copyWith(color: colors.textTertiary),
                    ),
                    if (post.isEdited) ...[
                      Text(
                        '  ·  ',
                        style: AppTextStyles.secondary
                            .copyWith(color: colors.textTertiary),
                      ),
                      Text(
                        'edited',
                        style: AppTextStyles.micro
                            .copyWith(color: colors.textTertiary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            LucideIcons.ellipsis,
            color: colors.textTertiary,
            size: 18,
          ),
          onPressed: onMore,
          visualDensity: VisualDensity.compact,
          splashRadius: 20,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _Caption extends StatelessWidget {
  const _Caption({
    required this.text,
    required this.expanded,
    required this.onToggle,
    required this.expandThreshold,
    required this.maxLines,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;
  final int expandThreshold;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final needsExpand = text.length > expandThreshold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: expanded ? null : maxLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: AppTextStyles.body.copyWith(
            color: colors.textPrimary,
            height: 1.55,
          ),
        ),
        if (needsExpand) ...[
          const SizedBox(height: 2),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                expanded ? 'Show less' : 'Read more',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _MediaBlock extends StatelessWidget {
  const _MediaBlock({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final typeData = post.typeData ?? const <String, dynamic>{};
    final child = switch (post.type) {
      PostType.photo => PostPhotoGallery(urls: post.mediaUrls),
      PostType.video => PostVideoPreview(
          thumbnailUrl: post.videoThumbnailUrl,
          videoUrl: post.videoUrl,
        ),
      PostType.score => PostScoreCard(data: typeData),
      PostType.poll => PostPollCard(data: typeData),
      PostType.shared => SharedPostBlock(typeData: typeData),
      PostType.gameShare => GameShareBlock(typeData: typeData),
      PostType.mediaShare => MediaShareBlock(typeData: typeData),
      PostType.cardShare => CardShareBlock(typeData: typeData),
      PostType.text => const SizedBox.shrink(),
      PostType.unknown => const SizedBox.shrink(),
    };

    if (child is SizedBox) return child;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.md,
        AppSpacing.base,
        0,
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.fallback,
    required this.size,
  });

  final String? url;
  final String fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
          fontSize: size * 0.38,
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

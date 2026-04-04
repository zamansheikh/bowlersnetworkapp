import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_avatar.dart';
import '../../data/models/post_models.dart';
import 'feed_video_player.dart';

class PostCard extends StatelessWidget {
  final PostModel post;
  final void Function(String reactionType)? onReact;
  final VoidCallback? onComment;
  final VoidCallback? onSave;
  final VoidCallback? onShare;
  final VoidCallback? onMore;

  const PostCard({
    super.key,
    required this.post,
    this.onReact,
    this.onComment,
    this.onSave,
    this.onShare,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(post: post, onMore: onMore),
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Text(post.caption, style: AppTextStyles.bodyMedium),
            ),
          _TypeContent(post: post),
          _ActionsBar(post: post, onReact: onReact, onComment: onComment, onSave: onSave, onShare: onShare),
        ],
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────

class _Header extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onMore;

  const _Header({required this.post, this.onMore});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(post.createdAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
      child: Row(
        children: [
          BnAvatar(
            imageUrl: post.author.profilePictureUrl.isNotEmpty ? post.author.profilePictureUrl : null,
            name: post.author.fullName,
            size: 42,
            isPro: post.author.isPro,
            showBorder: post.author.isPro,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        post.author.fullName,
                        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (post.author.isPro) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 14, color: AppColors.navActive),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Row(
                  children: [
                    Text(
                      createdAt?.timeAgo ?? '',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                    if (post.audience != 'public') ...[
                      const SizedBox(width: 4),
                      Icon(
                        post.audience == 'followers' ? Icons.people_outline : Icons.lock_outline,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                    ],
                    if (post.isEdited) ...[
                      const SizedBox(width: 4),
                      Text(' · Edited', style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (onMore != null)
            IconButton(
              onPressed: onMore,
              icon: const Icon(Icons.more_horiz, color: AppColors.textMuted, size: 22),
              splashRadius: 20,
            ),
        ],
      ),
    );
  }
}

// ── Type-specific content ───────────────────────────────

class _TypeContent extends StatelessWidget {
  final PostModel post;
  const _TypeContent({required this.post});

  @override
  Widget build(BuildContext context) {
    return switch (post.postType) {
      'photo' => _PhotoContent(urls: post.mediaUrls),
      'video' => Padding(
        padding: const EdgeInsets.only(top: 10),
        child: FeedVideoPlayer(videoUrl: post.videoUrl ?? '', thumbnailUrl: post.thumbnailUrl),
      ),
      'score' => _ScoreContent(post: post),
      'poll' => _PollContent(post: post),
      'shared' => _SharedContent(post: post),
      _ => const SizedBox(height: 6),
    };
  }
}

class _PhotoContent extends StatelessWidget {
  final List<String> urls;
  const _PhotoContent({required this.urls});

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: urls.length == 1
          ? AspectRatio(
              aspectRatio: 4 / 3,
              child: CachedNetworkImage(imageUrl: urls[0], fit: BoxFit.cover),
            )
          : AspectRatio(
              aspectRatio: 16 / 9,
              child: PageView.builder(
                itemCount: urls.length,
                itemBuilder: (_, i) => CachedNetworkImage(imageUrl: urls[i], fit: BoxFit.cover),
              ),
            ),
    );
  }
}

class _ScoreContent extends StatelessWidget {
  final PostModel post;
  const _ScoreContent({required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8BC342), Color(0xFF5B9A26)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${post.totalScore ?? 0}',
            style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: Colors.white, height: 1),
          ),
          const SizedBox(height: 8),
          if (post.gameType != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                post.gameType!.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1.2),
              ),
            ),
          if (post.strikePercentage != null) ...[
            const SizedBox(height: 10),
            Text(
              '${post.strikePercentage!.toStringAsFixed(1)}% Strikes',
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    );
  }
}

class _PollContent extends StatelessWidget {
  final PostModel post;
  const _PollContent({required this.post});

  @override
  Widget build(BuildContext context) {
    final options = post.pollOptions;
    final total = post.totalVotes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (post.pollQuestion != null)
            Text(post.pollQuestion!, style: AppTextStyles.labelLarge),
          const SizedBox(height: 10),
          ...options.map((opt) {
            final text = opt['text'] as String? ?? '';
            final count = opt['vote_count'] as int? ?? 0;
            final pct = total > 0 ? count / total : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
                          Text('${(pct * 100).toStringAsFixed(0)}%', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: pct,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Text(
            '$total votes${post.isPollClosed ? ' · Closed' : ''}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _SharedContent extends StatelessWidget {
  final PostModel post;
  const _SharedContent({required this.post});

  @override
  Widget build(BuildContext context) {
    final original = post.sharedOriginal;
    if (original == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: PostCard(post: original),
    );
  }
}

// ── Actions bar ─────────────────────────────────────────

class _ActionsBar extends StatelessWidget {
  final PostModel post;
  final void Function(String)? onReact;
  final VoidCallback? onComment;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const _ActionsBar({
    required this.post,
    this.onReact,
    this.onComment,
    this.onSave,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          // React
          _ActionBtn(
            icon: post.hasReacted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: post.likesCount > 0 ? '${post.likesCount}' : '',
            color: post.hasReacted ? AppColors.error : null,
            onTap: () => onReact?.call(post.hasReacted ? post.reactionType ?? 'like' : 'like'),
          ),
          // Comment
          _ActionBtn(
            icon: Icons.chat_bubble_outline_rounded,
            label: post.commentsCount > 0 ? '${post.commentsCount}' : '',
            onTap: onComment,
          ),
          // Share
          _ActionBtn(
            icon: Icons.share_outlined,
            label: post.sharesCount > 0 ? '${post.sharesCount}' : '',
            onTap: onShare,
          ),
          const Spacer(),
          // Bookmark
          IconButton(
            onPressed: onSave,
            icon: Icon(
              post.hasSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: post.hasSaved ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const _ActionBtn({required this.icon, this.label = '', this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.textMuted),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(label, style: AppTextStyles.caption.copyWith(color: color ?? AppColors.textMuted, fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}

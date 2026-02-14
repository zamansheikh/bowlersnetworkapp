import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/feed_v3_post.dart';

/// A modern, polished post card for FeedV3
class FeedV3PostCard extends StatelessWidget {
  final FeedV3Post post;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final Function(int)? onPollVote;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onAuthorTap;

  const FeedV3PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onLike,
    this.onPollVote,
    this.onComment,
    this.onShare,
    this.onAuthorTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildContent(context),
            _buildActionBar(context),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Row(
          children: [
            GestureDetector(
              onTap: onAuthorTap,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.gray200,
                backgroundImage: post.author.profilePictureUrl.isNotEmpty
                    ? CachedNetworkImageProvider(post.author.profilePictureUrl)
                    : null,
                child: post.author.profilePictureUrl.isEmpty
                    ? Text(
                        post.author.name.isNotEmpty
                            ? post.author.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: onAuthorTap,
                    child: Text(
                      post.author.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.gray900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    post.created,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            _buildPostTypeIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostTypeIndicator() {
    IconData icon;
    Color color;
    switch (post.postType) {
      case FeedV3PostType.poll:
        icon = Icons.poll_rounded;
        color = AppColors.info;
        break;
      case FeedV3PostType.shared:
        icon = Icons.repeat_rounded;
        color = AppColors.primaryLimeGreen;
        break;
      default:
        return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: color),
    );
  }

  // ─── Content ─────────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context) {
    switch (post.postType) {
      case FeedV3PostType.poll:
        return _buildPollContent(context);
      case FeedV3PostType.shared:
        return _buildSharedContent(context);
      default:
        return _buildDefaultContent(context);
    }
  }

  Widget _buildDefaultContent(BuildContext context) {
    final content = post.defaultContent;
    if (content == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text
        if (content.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              content.text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.gray800,
                height: 1.5,
              ),
            ),
          ),
        // Media
        if (content.mediaUrls.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildMediaGrid(content.mediaUrls),
        ],
      ],
    );
  }

  Widget _buildMediaGrid(List<String> mediaUrls) {
    if (mediaUrls.isEmpty) return const SizedBox.shrink();

    if (mediaUrls.length == 1) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: CachedNetworkImage(
          imageUrl: mediaUrls[0],
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.gray100),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.gray100,
            child: const Icon(Icons.broken_image, color: AppColors.gray400),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mediaUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: mediaUrls[index],
              width: 200,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(width: 200, color: AppColors.gray100),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPollContent(BuildContext context) {
    final content = post.pollContent;
    if (content == null) return const SizedBox.shrink();

    final hasVoted = content.options.any((o) => o.hasVoted);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poll title
          Text(
            content.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gray900,
            ),
          ),
          if (content.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              content.description,
              style: const TextStyle(fontSize: 13, color: AppColors.gray600),
            ),
          ],
          const SizedBox(height: 12),

          // Poll options
          ...content.options.map(
            (option) => _buildPollOption(
              option,
              hasVoted: hasVoted,
              isExpired: content.hasExpired,
            ),
          ),

          // Poll meta
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${content.totalVotes} vote${content.totalVotes != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12, color: AppColors.gray500),
              ),
              const SizedBox(width: 12),
              if (!content.hasExpired)
                Text(
                  _formatTimeLeft(content.timeLeftSeconds),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                )
              else
                const Text(
                  'Ended',
                  style: TextStyle(fontSize: 12, color: AppColors.error),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollOption(
    FeedV3PollOption option, {
    required bool hasVoted,
    required bool isExpired,
  }) {
    final showResults = hasVoted || isExpired;

    return GestureDetector(
      onTap: (!hasVoted && !isExpired && onPollVote != null)
          ? () => onPollVote!(option.id)
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: option.hasVoted ? AppColors.primarySurface : AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: option.hasVoted
                ? AppColors.primaryLimeGreen
                : AppColors.border,
            width: option.hasVoted ? 1.5 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Progress bar
            if (showResults)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: option.voteShare / 100,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation(
                      option.hasVoted
                          ? AppColors.primaryLimeGreen.withValues(alpha: 0.15)
                          : AppColors.gray200,
                    ),
                  ),
                ),
              ),
            // Option content
            Row(
              children: [
                if (option.hasVoted)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: AppColors.primaryLimeGreen,
                    ),
                  ),
                Expanded(
                  child: Text(
                    option.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: option.hasVoted
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: AppColors.gray800,
                    ),
                  ),
                ),
                if (showResults)
                  Text(
                    '${option.voteShare.round()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: option.hasVoted
                          ? AppColors.primaryLimeGreen
                          : AppColors.gray600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedContent(BuildContext context) {
    final content = post.sharedContent;
    if (content == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (content.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                content.description,
                style: const TextStyle(fontSize: 14, color: AppColors.gray800),
              ),
            ),
          // Original post preview
          if (content.original != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.gray200,
                        backgroundImage:
                            content
                                .original!
                                .author
                                .profilePictureUrl
                                .isNotEmpty
                            ? CachedNetworkImageProvider(
                                content.original!.author.profilePictureUrl,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          content.original!.author.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (content.original!.defaultContent?.text.isNotEmpty ==
                      true) ...[
                    const SizedBox(height: 8),
                    Text(
                      content.original!.defaultContent!.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─── Action Bar ──────────────────────────────────────────────────────────

  Widget _buildActionBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          _buildActionButton(
            icon: post.hasLiked ? Icons.favorite : Icons.favorite_border,
            label: post.likesCount > 0 ? '${post.likesCount}' : 'Like',
            color: post.hasLiked ? AppColors.error : AppColors.gray600,
            onTap: onLike,
          ),
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: post.commentsCount > 0 ? '${post.commentsCount}' : 'Comment',
            color: AppColors.gray600,
            onTap: onComment,
          ),
          _buildActionButton(
            icon: Icons.share_outlined,
            label: post.sharesCount > 0 ? '${post.sharesCount}' : 'Share',
            color: AppColors.gray600,
            onTap: onShare,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _formatTimeLeft(double seconds) {
    if (seconds <= 0) return 'Ended';
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    if (hours > 24) return '${(hours / 24).floor()}d left';
    if (hours > 0) return '${hours}h ${minutes}m left';
    return '${minutes}m left';
  }
}

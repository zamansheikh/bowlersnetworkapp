import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_avatar.dart';
import '../../data/models/post_models.dart';

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
        children: [
          _buildHeader(),
          if (post.caption.isNotEmpty) _buildCaption(),
          _buildTypeContent(),
          _buildActions(),
          _buildStats(),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final createdAt = DateTime.tryParse(post.createdAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
      child: Row(
        children: [
          BnAvatar(
            imageUrl: post.author.profilePictureUrl.isNotEmpty ? post.author.profilePictureUrl : null,
            name: post.author.fullName,
            size: 40,
            isPro: post.author.isPro,
            showBorder: post.author.isPro,
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(post.author.fullName, style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary)),
                    if (post.author.isPro) ...[
                      AppSpacing.horizontalXs,
                      const Icon(Icons.verified, size: 16, color: AppColors.navActive),
                    ],
                  ],
                ),
                Text(
                  '${createdAt?.timeAgo ?? ''}${post.isEdited ? ' · Edited' : ''}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          if (onMore != null)
            IconButton(
              onPressed: onMore,
              icon: const Icon(Icons.more_horiz, color: AppColors.textMuted),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(post.caption, style: AppTextStyles.bodyMedium),
    );
  }

  Widget _buildTypeContent() {
    return switch (post.postType) {
      'photo' => _buildPhotoContent(),
      'video' => _buildVideoContent(),
      'score' => _buildScoreContent(),
      'poll' => _buildPollContent(),
      'shared' => _buildSharedContent(),
      _ => const SizedBox(height: 8),
    };
  }

  Widget _buildPhotoContent() {
    final urls = post.mediaUrls;
    if (urls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: urls.length == 1
          ? CachedNetworkImage(imageUrl: urls[0], fit: BoxFit.cover, width: double.infinity, height: 300)
          : SizedBox(
              height: 240,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, mainAxisSpacing: 4,
                ),
                itemCount: urls.length,
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(imageUrl: urls[i], fit: BoxFit.cover),
                ),
              ),
            ),
    );
  }

  Widget _buildVideoContent() {
    final thumb = post.thumbnailUrl;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (thumb != null && thumb.isNotEmpty)
            CachedNetworkImage(imageUrl: thumb, fit: BoxFit.cover, width: double.infinity, height: 240)
          else
            Container(height: 240, color: AppColors.bgSubtleGray),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.6)),
            child: const Icon(Icons.play_arrow_rounded, size: 36, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreContent() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Text('${post.totalScore ?? 0}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white)),
          if (post.gameType != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(post.gameType!.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1)),
            ),
          if (post.strikePercentage != null) ...[
            const SizedBox(height: 8),
            Text('${post.strikePercentage!.toStringAsFixed(1)}% Strikes', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
          ],
        ],
      ),
    );
  }

  Widget _buildPollContent() {
    final options = post.pollOptions;
    final total = post.totalVotes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.pollQuestion != null)
            Text(post.pollQuestion!, style: AppTextStyles.labelLarge),
          AppSpacing.verticalSm,
          ...options.map((opt) {
            final text = opt['text'] as String? ?? '';
            final count = opt['vote_count'] as int? ?? 0;
            final pct = total > 0 ? count / total : 0.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity, height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 44,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
                          Text('${(pct * 100).toStringAsFixed(0)}%', style: AppTextStyles.labelSmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Text('$total votes${post.isPollClosed ? ' · Closed' : ''}', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildSharedContent() {
    final original = post.sharedOriginal;
    if (original == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: PostCard(post: original),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          // React
          _ActionButton(
            icon: post.hasReacted ? Icons.favorite : Icons.favorite_border,
            color: post.hasReacted ? AppColors.error : AppColors.textMuted,
            label: '${post.likesCount > 0 ? post.likesCount : ''}',
            onTap: () => onReact?.call(post.hasReacted ? post.reactionType ?? 'like' : 'like'),
            onLongPress: () => _showReactionPicker(),
          ),
          // Comment
          _ActionButton(
            icon: Icons.chat_bubble_outline,
            label: '${post.commentsCount > 0 ? post.commentsCount : ''}',
            onTap: onComment,
          ),
          // Share
          _ActionButton(
            icon: Icons.share_outlined,
            label: '${post.sharesCount > 0 ? post.sharesCount : ''}',
            onTap: onShare,
          ),
          const Spacer(),
          // Save
          IconButton(
            icon: Icon(
              post.hasSaved ? Icons.bookmark : Icons.bookmark_border,
              color: post.hasSaved ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            onPressed: onSave,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return const SizedBox(height: 4);
  }

  void _showReactionPicker() {
    // Reactions: like, fire, strike, clap, wow — handled by long press
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _ActionButton({
    required this.icon,
    this.color,
    this.label = '',
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: color ?? AppColors.textMuted),
        label: Text(label, style: AppTextStyles.caption.copyWith(color: color ?? AppColors.textMuted)),
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }
}

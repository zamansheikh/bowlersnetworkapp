import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../newsfeed/domain/entities/post.dart';
import 'home_section_card.dart';

/// Web's "Your Feed" preview — 3-5 compact rows showing avatar / author /
/// timestamp / a one-line "shared a X" hint.
class HomeFeedPreview extends StatelessWidget {
  const HomeFeedPreview({
    super.key,
    required this.posts,
    required this.onViewAll,
    required this.onPostTap,
  });

  final List<Post> posts;
  final VoidCallback onViewAll;
  final ValueChanged<Post> onPostTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return HomeSectionCard(
      icon: LucideIcons.newspaper,
      title: 'Your Feed',
      onViewAll: onViewAll,
      child: posts.isEmpty
          ? _EmptyHint(text: 'No posts yet — follow people to see updates.')
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < posts.length; i++) ...[
                  _PostRow(post: posts[i], onTap: () => onPostTap(posts[i])),
                  if (i < posts.length - 1)
                    Divider(
                      height: 1,
                      color: colors.borderDefault.withValues(alpha: 0.4),
                    ),
                ],
              ],
            ),
    );
  }
}

class _PostRow extends StatelessWidget {
  const _PostRow({required this.post, required this.onTap});
  final Post post;
  final VoidCallback onTap;

  String _verbForType(PostType t) => switch (t) {
        PostType.score => 'shared a score',
        PostType.photo => 'shared a photo',
        PostType.video => 'shared a video',
        PostType.poll => 'started a poll',
        PostType.shared => 'reshared a post',
        PostType.gameShare => 'shared a game',
        PostType.mediaShare => 'shared media',
        PostType.cardShare => 'shared a card',
        PostType.text || PostType.unknown => 'shared a post',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hint = post.caption.trim().isNotEmpty
        ? post.caption.trim()
        : _verbForType(post.type);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 10,
          ),
          child: Row(
            children: [
              _Avatar(
                url: post.author.profilePictureUrl,
                fallback: post.author.displayName,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            post.author.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '  ·  ',
                          style: AppTextStyles.nano.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                        Text(
                          timeago.format(post.createdAt, locale: 'en_short'),
                          style: AppTextStyles.nano.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
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
  const _Avatar({required this.url, required this.fallback});
  final String? url;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial =
        fallback.isEmpty ? '?' : fallback.substring(0, 1).toUpperCase();
    final placeholder = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.bodySmall.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    if (url == null || url!.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CachedNetworkImage(
          imageUrl: url!,
          fit: BoxFit.cover,
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => placeholder,
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(color: colors.textTertiary),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/network_badge.dart';
import '../../domain/entities/home_previews.dart';
import 'home_section_card.dart';

/// Web's "Top Discussions" bento — author avatar + name + topic chip,
/// title, vote/opinion counts, resolved badge.
class HomeDiscussionsPreview extends StatelessWidget {
  const HomeDiscussionsPreview({
    super.key,
    required this.discussions,
    required this.onViewAll,
    required this.onTap,
  });

  final List<DiscussionPreview> discussions;
  final VoidCallback onViewAll;
  final ValueChanged<DiscussionPreview> onTap;

  static const _blue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return HomeSectionCard(
      icon: LucideIcons.messageCircle,
      title: 'Top Discussions',
      iconTint: _blue,
      onViewAll: onViewAll,
      child: discussions.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'No discussions yet.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall
                    .copyWith(color: colors.textTertiary),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < discussions.length; i++) ...[
                  _Row(
                    discussion: discussions[i],
                    onTap: () => onTap(discussions[i]),
                  ),
                  if (i < discussions.length - 1)
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

class _Row extends StatelessWidget {
  const _Row({required this.discussion, required this.onTap});
  final DiscussionPreview discussion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(author: discussion.author),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (discussion.author != null) ...[
                          Flexible(
                            child: Text(
                              discussion.author!.displayName,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.nano.copyWith(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (discussion.author!.badgeIconUrl != null) ...[
                            const SizedBox(width: 4),
                            NetworkBadge(
                              url: discussion.author!.badgeIconUrl,
                              size: 12,
                            ),
                          ],
                        ],
                        if (discussion.topic.isNotEmpty) ...[
                          const Spacer(),
                          Text(
                            discussion.topic.toUpperCase(),
                            style: AppTextStyles.nano.copyWith(
                              color: colors.textTertiary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      discussion.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (discussion.upvoteCount > 0 ||
                        discussion.opinionCount > 0 ||
                        discussion.isResolved) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (discussion.upvoteCount > 0) ...[
                            Icon(
                              LucideIcons.chevronUp,
                              size: 10,
                              color: colors.accent,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${discussion.upvoteCount}',
                              style: AppTextStyles.nano.copyWith(
                                color: colors.textTertiary,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          if (discussion.opinionCount > 0) ...[
                            Icon(
                              LucideIcons.messageCircle,
                              size: 10,
                              color: colors.textTertiary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${discussion.opinionCount} opinions',
                              style: AppTextStyles.nano.copyWith(
                                color: colors.textTertiary,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          if (discussion.isResolved)
                            Text(
                              'Resolved',
                              style: AppTextStyles.nano.copyWith(
                                color: colors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                    ],
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
  const _Avatar({required this.author});
  final PreviewAuthor? author;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = (author?.firstName.isNotEmpty ?? false)
        ? author!.firstName.substring(0, 1).toUpperCase()
        : '?';
    final placeholder = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
        border: Border.all(color: colors.borderStrong),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.nano.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final url = author?.profilePictureUrl;
    if (url == null || url.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => placeholder,
        ),
      ),
    );
  }
}

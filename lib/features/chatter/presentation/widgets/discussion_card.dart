import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/network_badge.dart';
import '../../domain/entities/chatter.dart';

/// Tappable card representing one [Discussion] in the /chatter list.
/// Mirrors the visual hierarchy of the home preview row but rendered as
/// a full card with body excerpt + tag row + footer metrics.
class DiscussionCard extends StatelessWidget {
  const DiscussionCard({
    super.key,
    required this.discussion,
    required this.onTap,
  });

  final Discussion discussion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final author = discussion.author;
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _Avatar(author: author),
                  const SizedBox(width: AppSpacing.sm),
                  if (author != null)
                    Flexible(
                      child: Text(
                        author.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (author?.badgeIconUrl != null) ...[
                    const SizedBox(width: 4),
                    NetworkBadge(url: author!.badgeIconUrl, size: 14),
                  ],
                  if (discussion.topic != null) ...[
                    const Spacer(),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.accentSubtle,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Text(
                        discussion.topic!.name,
                        style: AppTextStyles.nano.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                discussion.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              if (discussion.body.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  discussion.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
              if (discussion.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final tag in discussion.tags) _TagChip(tag: tag),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _Metric(
                    icon: LucideIcons.chevronUp,
                    label: '${discussion.upvoteCount}',
                    tint: colors.accent,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _Metric(
                    icon: LucideIcons.messageCircle,
                    label: '${discussion.opinionCount}',
                    tint: colors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _Metric(
                    icon: LucideIcons.eye,
                    label: '${discussion.viewCount}',
                    tint: colors.textTertiary,
                  ),
                  const Spacer(),
                  if (discussion.isResolved)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.success.withValues(alpha: 0.12),
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.circleCheck,
                              size: 11, color: colors.success),
                          const SizedBox(width: 3),
                          Text(
                            'Resolved',
                            style: AppTextStyles.nano.copyWith(
                              color: colors.success,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
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
  final ChatterAuthor? author;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = (author?.firstName.isNotEmpty ?? false)
        ? author!.firstName.substring(0, 1).toUpperCase()
        : (author?.username.isNotEmpty ?? false)
            ? author!.username.substring(0, 1).toUpperCase()
            : '?';
    final placeholder = Container(
      width: 28,
      height: 28,
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
        width: 28,
        height: 28,
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

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});
  final String tag;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        '#$tag',
        style: AppTextStyles.nano.copyWith(color: colors.textSecondary),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.tint});
  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: tint),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.nano.copyWith(
            color: colors.textTertiary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

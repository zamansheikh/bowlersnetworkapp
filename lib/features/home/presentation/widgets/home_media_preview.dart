import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/home_previews.dart';
import 'home_section_card.dart';

/// Web's "Trending Media" bento — a 2x2 grid of video / split thumbnails
/// with title overlay and view count.
class HomeMediaPreview extends StatelessWidget {
  const HomeMediaPreview({
    super.key,
    required this.items,
    required this.onViewAll,
    required this.onTap,
  });

  final List<MediaPreview> items;
  final VoidCallback onViewAll;
  final ValueChanged<MediaPreview> onTap;

  static const _purple = Color(0xFFA855F7);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return HomeSectionCard(
      icon: LucideIcons.play,
      title: 'Trending Media',
      iconTint: _purple,
      onViewAll: onViewAll,
      child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'Videos and splits will appear here.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall
                    .copyWith(color: colors.textTertiary),
              ),
            )
          : GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 16 / 11,
              children: [
                for (final m in items.take(4))
                  _MediaTile(item: m, onTap: () => onTap(m)),
              ],
            ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.item, required this.onTap});
  final MediaPreview item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.bgSurfaceHover,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: item.thumbnailUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => const SizedBox(),
                errorWidget: (_, _, _) => Icon(
                  LucideIcons.image,
                  color: colors.textTertiary,
                ),
              )
            else
              Center(
                child: Icon(LucideIcons.play, color: colors.textTertiary),
              ),
            // Bottom darken gradient
            const Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x33000000),
                        Color(0xB3000000),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.nano.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (item.author != null)
                        Flexible(
                          child: Text(
                            item.author!.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.nano.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      if (item.viewsCount > 0) ...[
                        const Spacer(),
                        Icon(
                          LucideIcons.eye,
                          size: 10,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatCount(item.viewsCount),
                          style: AppTextStyles.nano.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCount(int n) {
  if (n < 1000) return '$n';
  if (n < 1000000) {
    return '${(n / 1000).toStringAsFixed(n % 1000 >= 100 ? 1 : 0)}K';
  }
  return '${(n / 1000000).toStringAsFixed(1)}M';
}

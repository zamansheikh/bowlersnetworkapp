import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/brand.dart';

/// Horizontal strip of the user's favorite brand logos, with a trailing
/// "Browse Brands" link. Matches the web's sidebar brands section.
class FavoriteBrandsCard extends StatelessWidget {
  const FavoriteBrandsCard({
    super.key,
    required this.brands,
    this.onBrowse,
  });

  final List<Brand> brands;
  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shown = brands.take(6).toList(growable: false);
    final extra = brands.length - shown.length;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'FAVORITE BRANDS',
                style: AppTextStyles.label.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              const Spacer(),
              if (onBrowse != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onBrowse,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Browse',
                        style: AppTextStyles.micro.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 12,
                        color: colors.accent,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (brands.isEmpty)
            _EmptyState(onBrowse: onBrowse)
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final b in shown) _BrandLogo(brand: b),
                if (extra > 0) _OverflowChip(count: extra),
              ],
            ),
        ],
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({required this.brand});
  final Brand brand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: brand.name,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: colors.borderDefault),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: CachedNetworkImage(
            imageUrl: brand.logoUrl,
            fit: BoxFit.contain,
            placeholder: (_, _) => const SizedBox.shrink(),
            errorWidget: (_, _, _) => Icon(
              LucideIcons.image,
              size: 16,
              color: colors.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _OverflowChip extends StatelessWidget {
  const _OverflowChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: AppTextStyles.bodyMedium.copyWith(
          color: colors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onBrowse});
  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Icon(
          LucideIcons.bookmark,
          size: 14,
          color: colors.textTertiary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Follow your favorite brands to see them here.',
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

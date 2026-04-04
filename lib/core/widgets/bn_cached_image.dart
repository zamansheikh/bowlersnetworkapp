import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_spacing.dart';

class BnCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const BnCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = AppSpacing.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (_, _) => Container(
          width: width,
          height: height,
          color: AppColors.bgSubtleGray,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (_, _, _) => Container(
          width: width,
          height: height,
          color: AppColors.bgSubtleGray,
          child: const Icon(
            Icons.broken_image_outlined,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

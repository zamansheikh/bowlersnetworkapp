import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';

/// Shimmer rectangle placeholder. Always prefer multiple skeletons matching
/// the shape of incoming content over a single spinner.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = AppRadius.smAll,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.bgSurface,
      highlightColor: colors.bgSurfaceHover,
      period: AppDurations.shimmer,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: colors.bgSurface,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.bgSurface,
      highlightColor: colors.bgSurfaceHover,
      period: AppDurations.shimmer,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.bgSurface,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Card-shaped skeleton for list item placeholders. Matches the web's
/// `rounded-[14px] border border-border-default bg-bg-surface p-5` pattern.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 96});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Shimmer.fromColors(
        baseColor: colors.bgSurface,
        highlightColor: colors.bgSurfaceHover,
        period: AppDurations.shimmer,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: colors.bgSurfaceHover,
                borderRadius: AppRadius.smAll,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                color: colors.bgSurfaceHover,
                borderRadius: AppRadius.smAll,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 180,
              height: 8,
              decoration: BoxDecoration(
                color: colors.bgSurfaceHover,
                borderRadius: AppRadius.smAll,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

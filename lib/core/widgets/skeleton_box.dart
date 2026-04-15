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

import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';

/// Standard surface card: background, subtle border, optional corner orb,
/// consistent press feedback. The default container for every content group.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.base),
    this.showCornerOrb = false,
    this.borderRadius = AppRadius.lgAll,
    this.elevated = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool showCornerOrb;
  final BorderRadius borderRadius;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget content = Padding(padding: padding, child: child);

    if (showCornerOrb) {
      content = ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned(
              top: -56,
              right: -56,
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.accent.withValues(alpha: 0.05),
                ),
              ),
            ),
            content,
          ],
        ),
      );
    }

    final container = DecoratedBox(
      decoration: BoxDecoration(
        color: elevated ? colors.bgSurfaceElevated : colors.bgSurface,
        borderRadius: borderRadius,
        border: Border.all(color: colors.borderDefault),
      ),
      child: content,
    );

    if (onTap == null) return container;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        splashColor: colors.accent.withValues(alpha: 0.06),
        highlightColor: colors.accent.withValues(alpha: 0.03),
        child: container,
      ),
    );
  }
}

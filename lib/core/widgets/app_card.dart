import 'dart:ui';

import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';

/// Standard surface card: background, subtle border, optional corner-orb
/// glow, optional backdrop blur. The default container for every content
/// group across the app.
///
/// Matches the web frontend's `rounded-2xl border border-border-default
/// bg-bg-surface` pattern, with the accent corner-orb on variants that need
/// decoration (hero, featured sections, invitations).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.base),
    this.showCornerOrb = false,
    this.borderRadius = AppRadius.xlAll,
    this.elevated = false,
    this.translucent = false,
    this.highlightBorder = false,
    this.cornerOrbColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool showCornerOrb;
  final BorderRadius borderRadius;
  final bool elevated;

  /// When true, wraps the background in a BackdropFilter so the card looks
  /// like the web's `bg-bg-surface/70 backdrop-blur-xl` treatment on login.
  final bool translucent;

  /// Use a subtle accent-tinted border (matches web's `border-accent/10`).
  final bool highlightBorder;

  /// Override the corner orb color (defaults to theme accent).
  final Color? cornerOrbColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bg = elevated ? colors.bgSurfaceElevated : colors.bgSurface;

    Widget content = Padding(padding: padding, child: child);

    if (showCornerOrb) {
      final orbColor = cornerOrbColor ?? colors.accent;
      content = ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        orbColor.withValues(alpha: 0.14),
                        orbColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            content,
          ],
        ),
      );
    }

    final borderColor = highlightBorder
        ? colors.accent.withValues(alpha: 0.12)
        : colors.borderDefault;

    Widget container = DecoratedBox(
      decoration: BoxDecoration(
        color: translucent ? bg.withValues(alpha: 0.72) : bg,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
      ),
      child: content,
    );

    if (translucent) {
      container = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: container,
        ),
      );
    }

    if (onTap == null) return container;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        splashColor: colors.accent.withValues(alpha: 0.08),
        highlightColor: colors.accent.withValues(alpha: 0.03),
        child: container,
      ),
    );
  }
}

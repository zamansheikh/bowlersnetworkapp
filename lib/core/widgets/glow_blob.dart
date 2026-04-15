import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../extensions/context_extensions.dart';

/// A soft, colored glow blob — the BowlersNetwork signature decoration.
/// Use inside a [Stack] with [Positioned] to place a blur blob behind
/// content (auth screens, onboarding, hero sections).
///
/// Mirrors the web frontend's `blur-[120px]/blur-[150px]` + low-opacity
/// accent circles.
class GlowBlob extends StatelessWidget {
  const GlowBlob({
    super.key,
    this.size = 320,
    this.color,
    this.opacity = 0.06,
    this.sigma = 80,
    this.animate = true,
  });

  final double size;
  final Color? color;
  final double opacity;
  final double sigma;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.colors.accent;

    final blob = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.withValues(alpha: opacity),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: opacity),
            blurRadius: sigma,
            spreadRadius: sigma * 0.3,
          ),
        ],
      ),
    );

    if (!animate || context.reducedMotion) return blob;

    return blob
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.08, 1.08),
          duration: 4800.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Icon container used in BentoCard headers. Gradient-tinted background
/// with accent border — matches the web's `bg-gradient-to-br
/// from-accent/20 to-accent/5 border border-accent/20`.
class GradientIconContainer extends StatelessWidget {
  const GradientIconContainer({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.iconSize = 18,
    this.radius = 12,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.22),
            color.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

/// Full-screen ambient decoration: a radial accent gradient at the top-left,
/// paired with 2-3 blur blobs. Place inside a [Stack] as the bottom layer for
/// auth / onboarding / hero screens.
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    this.primary,
    this.secondary,
  });

  final Color? primary;
  final Color? secondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final p = primary ?? colors.accent;
    final s = secondary ?? colors.accent;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Faint global gradient — the "atmosphere"
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  p.withValues(alpha: 0.08),
                  p.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -120,
            left: -80,
            child: GlowBlob(size: 360, color: p, opacity: 0.08),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: GlowBlob(
              size: 300,
              color: s,
              opacity: 0.05,
            ),
          ),
        ],
      ),
    );
  }
}

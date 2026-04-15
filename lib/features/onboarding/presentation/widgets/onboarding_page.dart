import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.index,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            Center(
              child: _IllustrationBubble(icon: icon, accent: accent)
                  .animate(key: ValueKey('illustration-$index'))
                  .fadeIn(duration: 500.ms, curve: BNCurves.spring)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: BNCurves.spring,
                  ),
            ),
            const Spacer(flex: 1),
            Text(
              title,
              style: AppTextStyles.displayHero.copyWith(
                color: colors.textPrimary,
                fontSize: 30,
              ),
            )
                .animate(key: ValueKey('title-$index'))
                .fadeIn(delay: 140.ms, duration: 420.ms, curve: BNCurves.spring)
                .moveY(
                  begin: 16,
                  end: 0,
                  delay: 140.ms,
                  duration: 420.ms,
                  curve: BNCurves.spring,
                ),
            const SizedBox(height: AppSpacing.md),
            Text(
              description,
              style: AppTextStyles.body.copyWith(
                color: colors.textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
            )
                .animate(key: ValueKey('desc-$index'))
                .fadeIn(delay: 240.ms, duration: 420.ms, curve: BNCurves.spring)
                .moveY(
                  begin: 12,
                  end: 0,
                  delay: 240.ms,
                  duration: 420.ms,
                  curve: BNCurves.spring,
                ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}

class _IllustrationBubble extends StatelessWidget {
  const _IllustrationBubble({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer soft glow
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.22),
                  accent.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.7],
              ),
            ),
          ),
          // Mid ring — very subtle
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.96, 0.96),
                end: const Offset(1.04, 1.04),
                duration: 3200.ms,
                curve: Curves.easeInOut,
              ),
          // Central icon disc
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.bgSurface,
              border: Border.all(color: colors.borderDefault),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.28),
                  blurRadius: 48,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(icon, size: 52, color: accent),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(
                begin: -4,
                end: 4,
                duration: 2800.ms,
                curve: Curves.easeInOut,
              ),
          // Floating dots
          Positioned(
            top: 32,
            left: 40,
            child: _floatingDot(accent, 12, 1.0, 2400.ms),
          ),
          Positioned(
            bottom: 48,
            right: 40,
            child: _floatingDot(accent, 9, 0.7, 2800.ms),
          ),
          Positioned(
            top: 80,
            right: 30,
            child: _floatingDot(accent, 6, 0.5, 3200.ms),
          ),
          Positioned(
            bottom: 30,
            left: 52,
            child: _floatingDot(accent, 7, 0.6, 2000.ms),
          ),
        ],
      ),
    );
  }

  Widget _floatingDot(Color color, double size, double opacity, Duration d) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity * 0.6),
            blurRadius: size * 1.2,
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: -6, end: 6, duration: d, curve: Curves.easeInOut);
  }
}

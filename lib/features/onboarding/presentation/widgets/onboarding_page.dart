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
            _IllustrationBubble(icon: icon, accent: accent)
                .animate(key: ValueKey('illustration-$index'))
                .fadeIn(duration: 450.ms)
                .moveY(begin: 24, end: 0, curve: Curves.easeOutCubic),
            const Spacer(flex: 1),
            Text(
              title,
              style: AppTextStyles.pageTitle.copyWith(
                color: colors.textPrimary,
                fontSize: 28,
                height: 1.2,
              ),
            )
                .animate(key: ValueKey('title-$index'))
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .moveY(begin: 16, end: 0, curve: Curves.easeOutCubic),
            const SizedBox(height: AppSpacing.md),
            Text(
              description,
              style: AppTextStyles.body.copyWith(
                color: colors.textSecondary,
                fontSize: 15,
                height: 1.55,
              ),
            )
                .animate(key: ValueKey('desc-$index'))
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .moveY(begin: 12, end: 0, curve: Curves.easeOutCubic),
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accent.withValues(alpha: 0.18),
                accent.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.bgSurface,
            border: Border.all(color: colors.borderDefault),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.12),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, size: 56, color: accent),
        ),
        Positioned(
          top: 24,
          left: 20,
          child: _floatingDot(accent.withValues(alpha: 0.6), 12),
        ),
        Positioned(
          bottom: 40,
          right: 24,
          child: _floatingDot(accent.withValues(alpha: 0.4), 8),
        ),
        Positioned(
          bottom: 16,
          left: 44,
          child: _floatingDot(accent.withValues(alpha: 0.3), 6),
        ),
      ],
    );
  }

  Widget _floatingDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(
          begin: -4,
          end: 4,
          duration: 1600.ms,
          curve: Curves.easeInOut,
        );
  }
}

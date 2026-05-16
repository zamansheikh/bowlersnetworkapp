import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Top-of-page greeting — mirrors web's hero. Time-of-day greeting,
/// big first name + waving hand, supportive subline. Uses an accent-tinted
/// gradient background with a couple of glow blobs for that "premium" feel.
class HomeHeroGreeting extends StatelessWidget {
  const HomeHeroGreeting({
    super.key,
    required this.firstName,
  });

  final String firstName;

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppRadius.xl2All,
        border: Border.all(color: colors.accent.withValues(alpha: 0.12)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.accent.withValues(alpha: 0.18),
            colors.accent.withValues(alpha: 0.04),
            Colors.transparent,
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative blob (matches web's pulse dots).
          Positioned(
            top: -32,
            right: -32,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.accent.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_greeting()},',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$firstName  👋',
                style: AppTextStyles.displayHero.copyWith(
                  color: colors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "Here's what's happening in your bowling world today.",
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

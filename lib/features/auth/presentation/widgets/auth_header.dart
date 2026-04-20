import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Shared title + subtitle block used across auth screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.pageTitle.copyWith(
            color: colors.textPrimary,
            fontSize: 28,
          ),
        ).animate().fadeIn(duration: 400.ms).moveY(begin: 8, end: 0),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle!,
            style: AppTextStyles.body.copyWith(color: colors.textSecondary),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 80.ms)
              .moveY(begin: 6, end: 0),
        ],
      ],
    );
  }
}

/// Simple error block shown above action buttons when backend returns
/// `{"errors": [...]}`. Iterates every message — never collapses.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return const SizedBox.shrink();
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final m in messages)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.circleAlert,
                    size: 14,
                    color: colors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      m,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

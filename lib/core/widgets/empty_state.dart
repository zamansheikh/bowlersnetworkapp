import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? hint;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.bgSurface,
              borderRadius: AppRadius.lgAll,
              border: Border.all(color: colors.borderDefault),
            ),
            child: Icon(icon, size: 24, color: colors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.base),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: AppTextStyles.secondary.copyWith(
                color: colors.textTertiary,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.base),
            action!,
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class BnEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  const BnEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_rounded,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: AppColors.textMuted.withValues(alpha: 0.5)),
            AppSpacing.verticalBase,
            Text(
              title,
              style: AppTextStyles.h4.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              AppSpacing.verticalSm,
              Text(
                subtitle!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              AppSpacing.verticalLg,
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

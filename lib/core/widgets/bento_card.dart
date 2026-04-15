import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

/// Overview-style card: icon container header, title, optional "View All"
/// trailing link, feature-specific body content.
class BentoCard extends StatelessWidget {
  const BentoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    this.onViewAll,
    this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final VoidCallback? onViewAll;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: AppRadius.smAll,
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (onViewAll != null)
                _ViewAllButton(onTap: onViewAll!)
              else
                const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          child,
        ],
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.smAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.actionViewAll,
                style: AppTextStyles.label.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_rounded,
                size: 12,
                color: colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

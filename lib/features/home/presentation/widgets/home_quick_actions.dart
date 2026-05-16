import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'home_section_card.dart';

class HomeQuickAction {
  const HomeQuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

/// Mirrors web's Quick Actions sidebar — a small list of icon + label
/// rows. On mobile this becomes a single full-width card.
class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key, required this.actions});

  final List<HomeQuickAction> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return HomeSectionCard(
      icon: LucideIcons.zap,
      title: 'Quick Actions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < actions.length; i++) ...[
            Material(
              color: Colors.transparent,
              borderRadius: AppRadius.mdAll,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: actions[i].onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        actions[i].icon,
                        size: 16,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          actions[i].label,
                          style: AppTextStyles.body.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        LucideIcons.chevronRight,
                        size: 14,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (i < actions.length - 1)
              Divider(
                height: 1,
                color: colors.borderDefault.withValues(alpha: 0.4),
              ),
          ],
        ],
      ),
    );
  }
}

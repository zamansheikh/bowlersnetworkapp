import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';
import 'glow_blob.dart';

/// Overview-style card: gradient icon container in the header, section title,
/// optional "View All" trailing link, feature-specific body content.
///
/// Matches the web's Bento card pattern — gradient-tinted icon box,
/// tight heading, subtitle-less by default, accent border hover state.
class BentoCard extends StatelessWidget {
  const BentoCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    this.subtitle,
    this.onViewAll,
    this.onTap,
    this.hero = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onViewAll;
  final VoidCallback? onTap;

  /// Larger padding + radius + corner orb. Use for the top hero card on the
  /// home screen.
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppCard(
      onTap: onTap,
      showCornerOrb: hero,
      cornerOrbColor: iconColor,
      highlightBorder: hero,
      padding: EdgeInsets.all(hero ? AppSpacing.xl : AppSpacing.base),
      borderRadius: hero ? AppRadius.xl2All : AppRadius.xlAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GradientIconContainer(
                icon: icon,
                color: iconColor,
                size: hero ? 48 : 36,
                iconSize: hero ? 22 : 17,
                radius: hero ? 14 : 10,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: colors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.secondary.copyWith(
                          color: colors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (onViewAll != null) _ViewAllButton(onTap: onViewAll!),
            ],
          ),
          SizedBox(height: hero ? AppSpacing.lg : AppSpacing.base),
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
                style: AppTextStyles.micro.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_rounded,
                size: 12,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

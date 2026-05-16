import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// One of the four profile tabs.
enum ProfileTab {
  info(LucideIcons.info, 'Info'),
  posts(LucideIcons.newspaper, 'Posts'),
  media(LucideIcons.image, 'Media'),
  cards(LucideIcons.sparkles, 'Cards');

  const ProfileTab(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// Shared pill-row tab bar used by both the self-profile and the
/// other-user profile screens. Renders four rounded chips that scroll
/// horizontally when the viewport is narrow, so labels never truncate.
///
/// Sits inside a [SliverPersistentHeader] via [ProfileStickyTabsDelegate].
class ProfileTabBar extends StatelessWidget {
  const ProfileTabBar({
    super.key,
    required this.active,
    required this.onChanged,
  });

  final ProfileTab active;
  final ValueChanged<ProfileTab> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.bgPrimary,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        child: Row(
          children: [
            for (var i = 0; i < ProfileTab.values.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _Pill(
                tab: ProfileTab.values[i],
                active: active == ProfileTab.values[i],
                onTap: () => onChanged(ProfileTab.values[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header-delegate wrapper so [ProfileTabBar] can pin under the hero in
/// a [CustomScrollView].
class ProfileStickyTabsDelegate extends SliverPersistentHeaderDelegate {
  ProfileStickyTabsDelegate({required this.active, required this.onChanged});

  final ProfileTab active;
  final ValueChanged<ProfileTab> onChanged;

  /// Pill height (36) + 2× vertical padding (16). Keep min == max so the
  /// header doesn't compress on scroll (the inner ListView jumps if it
  /// does).
  static const double _height = 36.0 + 16.0;

  @override
  double get minExtent => _height;
  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colors = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bgPrimary,
        border: Border(bottom: BorderSide(color: colors.borderDefault)),
      ),
      child: ProfileTabBar(active: active, onChanged: onChanged),
    );
  }

  @override
  bool shouldRebuild(covariant ProfileStickyTabsDelegate old) =>
      active != old.active;
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final ProfileTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = active ? Colors.white : colors.textSecondary;
    return Material(
      color: active ? colors.accent : colors.bgSurface,
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        borderRadius: AppRadius.fullAll,
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.micro,
          curve: BNCurves.standard,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: AppRadius.fullAll,
            border: Border.all(
              color: active ? colors.accent : colors.borderDefault,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: colors.accentGlow,
                      blurRadius: 0,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(
                tab.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: fg,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Top-level shell for the 5-tab main app. go_router's
/// [StatefulNavigationShell] preserves each tab's navigation stack so
/// switching between tabs doesn't lose scroll position or nested routes.
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.bgSurface,
          border: Border(
            top: BorderSide(color: colors.borderDefault, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppSpacing.bottomNavHeight,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: l10n.navHome,
                  active: shell.currentIndex == 0,
                  onTap: () => _goBranch(0),
                ),
                _NavItem(
                  icon: Icons.newspaper_rounded,
                  label: l10n.navNewsfeed,
                  active: shell.currentIndex == 1,
                  onTap: () => _goBranch(1),
                ),
                _NavItem(
                  icon: Icons.track_changes_rounded,
                  label: l10n.navGames,
                  active: shell.currentIndex == 2,
                  onTap: () => _goBranch(2),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: l10n.navMessages,
                  active: shell.currentIndex == 3,
                  onTap: () => _goBranch(3),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: l10n.navProfile,
                  active: shell.currentIndex == 4,
                  onTap: () => _goBranch(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goBranch(int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = active ? colors.accent : colors.textTertiary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: colors.accent.withValues(alpha: 0.08),
          highlightColor: colors.accent.withValues(alpha: 0.04),
          child: AnimatedContainer(
            duration: AppDurations.micro,
            curve: BNCurves.standard,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: active ? 1.05 : 1.0,
                  duration: AppDurations.short,
                  curve: BNCurves.spring,
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: AppDurations.micro,
                  style: AppTextStyles.micro.copyWith(
                    color: color,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

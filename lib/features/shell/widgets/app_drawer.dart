import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/bn_logo.dart';
import '../../../core/widgets/user_chip.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../profile/presentation/bloc/profile_bloc.dart';

/// Secondary navigation drawer — matches the web sidebar's 14-item set.
///
/// Items that don't have a route yet simply close the drawer; they'll get
/// wired up as their features land.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Drawer(
      backgroundColor: colors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.horizontal(right: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DrawerHeader(),
            Divider(height: 1, color: colors.borderDefault),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                  horizontal: AppSpacing.sm,
                ),
                children: const [
                  _DrawerSection(label: 'PRIMARY'),
                  _DrawerItem(
                    icon: LucideIcons.house,
                    label: 'Overview',
                    path: RouteNames.home,
                  ),
                  _DrawerItem(
                    icon: LucideIcons.chartLine,
                    label: 'Dashboard',
                    path: RouteNames.dashboard,
                  ),
                  _DrawerItem(
                    icon: LucideIcons.trophy,
                    label: 'Leaderboard',
                    path: RouteNames.leaderboard,
                  ),
                  _DrawerItem(
                    icon: LucideIcons.newspaper,
                    label: 'Newsfeed',
                    path: RouteNames.newsfeed,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  _DrawerSection(label: 'COMMUNITY'),
                  _DrawerItem(
                    icon: LucideIcons.messagesSquare,
                    label: 'Chatter',
                    path: RouteNames.chatter,
                  ),
                  _DrawerItem(
                    icon: LucideIcons.target,
                    label: 'Games',
                    path: RouteNames.games,
                  ),
                  _DrawerItem(
                    icon: LucideIcons.calendar,
                    label: 'Events',
                    path: RouteNames.events,
                  ),
                  _DrawerItem(
                    icon: LucideIcons.image,
                    label: 'Media',
                    path: RouteNames.media,
                  ),
                  _DrawerItem(
                    icon: LucideIcons.sparkles,
                    label: 'Cards',
                    path: RouteNames.cards,
                  ),
                  _DrawerItem(
                    icon: LucideIcons.users,
                    label: 'Teams',
                    path: RouteNames.teams,
                  ),
                  _DrawerItem(
                    icon: LucideIcons.bookmark,
                    label: 'Brands',
                  ),
                  _DrawerItem(
                    icon: LucideIcons.messageCircle,
                    label: 'Messages',
                    path: RouteNames.messages,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  _DrawerSection(label: 'OTHER'),
                  _DrawerItem(
                    icon: LucideIcons.flag,
                    label: 'Feedback',
                  ),
                  _DrawerItem(
                    icon: LucideIcons.settings,
                    label: 'Settings',
                    path: RouteNames.settings,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.borderDefault),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: _DrawerItem(
                icon: LucideIcons.logOut,
                label: 'Sign out',
                destructive: true,
                onTapOverride: () {
                  Navigator.of(context).maybePop();
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              BnLogoMark(size: 28, showGlow: false),
              SizedBox(width: AppSpacing.sm),
              BnWordmark(fontSize: 16),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final p = state.profile;
              if (p == null) {
                return Text(
                  'Welcome back 👋',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: colors.textSecondary),
                );
              }
              return UserChip(
                username: p.user.username,
                displayName: p.user.displayName,
                avatarUrl: p.profilePictureUrl,
                size: UserChipSize.standard,
                onTap: () {
                  Navigator.of(context).maybePop();
                  context.go(RouteNames.profile);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  const _DrawerSection({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: colors.textTertiary),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    this.path,
    this.destructive = false,
    this.onTapOverride,
  });

  final IconData icon;
  final String label;
  final String? path;
  final bool destructive;
  final VoidCallback? onTapOverride;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = path != null &&
        GoRouterState.of(context).matchedLocation == path;

    final fg = destructive
        ? colors.error
        : active
            ? colors.accent
            : colors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: active
            ? colors.accent.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: () {
            if (onTapOverride != null) {
              onTapOverride!();
              return;
            }
            if (path == null) {
              Navigator.of(context).maybePop();
              return;
            }
            Navigator.of(context).maybePop();
            context.go(path!);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: AppSpacing.md),
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: fg,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

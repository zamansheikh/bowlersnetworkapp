import 'package:bowlersnetworkapp/core/constants/colors.dart';
import 'package:bowlersnetworkapp/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/home/data/models/user_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.matches.last.matchedLocation;

    return Drawer(
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Modern header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  String name = 'Guest';
                  String email = '';
                  String? photoUrl;
                  if (state is Authenticated) {
                    name = state.user.name;
                    email = state.user.email;
                    if (state.user is UserModel) {
                      final m = state.user as UserModel;
                      if (m.profilePictureUrl.isNotEmpty) {
                        photoUrl = m.profilePictureUrl;
                      }
                    }
                  }

                  return Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          backgroundImage: photoUrl != null
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null
                              ? Text(
                                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (email.isNotEmpty)
                                Text(
                                  email,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.white.withValues(
                                      alpha: 0.9,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Nav list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  const SizedBox(height: 8),
                  _SectionHeader(title: 'Discover'),
                  _NavItem(
                    icon: Icons.star,
                    label: 'Pro Players',
                    selected: currentPath.startsWith('/pro-players'),
                    onTap: () => _go(context, '/pro-players'),
                  ),
                  _NavItem(
                    icon: Icons.analytics,
                    label: 'Overview',
                    selected: currentPath.startsWith('/overview'),
                    onTap: () => _go(context, '/overview'),
                  ),
                  _NavItem(
                    icon: Icons.emoji_events,
                    label: 'Tournaments',
                    selected: currentPath.startsWith('/tournaments'),
                    onTap: () => _go(context, '/tournaments'),
                  ),
                  _NavItem(
                    icon: Icons.group,
                    label: 'My Teams',
                    selected: currentPath.startsWith('/teams'),
                    onTap: () => _go(context, '/teams'),
                  ),
                  _NavItem(
                    icon: Icons.score,
                    label: 'Add Score',
                    selected: currentPath.startsWith('/add-score'),
                    onTap: () => _go(context, '/add-score'),
                  ),
                  _NavItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    selected: currentPath.startsWith('/settings'),
                    onTap: () => _go(context, '/settings'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Logout
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: BlocBuilder<AuthCubit, AuthState>(
                builder: (context, state) {
                  if (state is Authenticated) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.logout, color: AppColors.error),
                            const SizedBox(width: 12),
                            Text(
                              'Logout',
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read<AuthCubit>().logout();
                if (context.mounted) {
                  // Immediately redirect to splash, which will handle navigation
                  context.go('/splash');
                }
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.gray,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primaryLimeGreen : AppColors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryLimeGreen.withValues(alpha: 0.08)
                : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primaryLimeGreen.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(color: color),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.primaryLimeGreen,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

void _go(BuildContext context, String path) {
  final router = GoRouter.of(context);
  final current =
      router.routerDelegate.currentConfiguration.matches.last.matchedLocation;
  if (current == path) return;
  if (path == '/') {
    context.go(path); // Home stays as go() since it's the base
  } else {
    context.push(path); // All other pages use push() to create navigation stack
  }
}

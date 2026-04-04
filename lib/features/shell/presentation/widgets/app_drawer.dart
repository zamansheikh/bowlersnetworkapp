import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_avatar.dart';
import '../../../profile/data/models/profile_models.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  ProfileModel? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final repo = getIt<ProfileRepository>();
    final result = await repo.getMyProfile();
    result.fold(
      (_) => setState(() => _loading = false),
      (profile) => setState(() { _profile = profile; _loading = false; }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _profile?.user;
    final picUrl = _profile?.profileMedia?.profilePictureUrl;
    final hasAvatar = picUrl != null && !picUrl.contains('defaults/');

    return Drawer(
      backgroundColor: AppColors.bgWhite,
      child: Column(
        children: [
          // ── Header ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.paddingOf(context).top + 20, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8BC342), Color(0xFF5B9A26)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: _loading
                ? const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BnAvatar(
                        imageUrl: hasAvatar ? picUrl : null,
                        name: '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                        size: 64,
                        showBorder: true,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                        style: AppTextStyles.h4.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user?.username ?? ''}',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      if (_profile?.completionPercentage != null && _profile!.completionPercentage! < 100) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_profile!.completionPercentage ?? 0) / 100,
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Profile ${_profile!.completionPercentage}% complete',
                          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                    ],
                  ),
          ),

          // ── Menu items ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.person_outline_rounded,
                  label: 'My Profile',
                  onTap: () { Navigator.pop(context); context.go('/profile'); },
                ),
                _DrawerItem(
                  icon: Icons.analytics_outlined,
                  label: 'Dashboard',
                  onTap: () { Navigator.pop(context); },
                ),
                _DrawerItem(
                  icon: Icons.emoji_events_outlined,
                  label: 'XP & Leaderboard',
                  onTap: () { Navigator.pop(context); },
                ),
                _DrawerItem(
                  icon: Icons.style_outlined,
                  label: 'Trading Cards',
                  onTap: () { Navigator.pop(context); },
                ),
                _DrawerItem(
                  icon: Icons.groups_outlined,
                  label: 'Teams',
                  onTap: () { Navigator.pop(context); },
                ),
                _DrawerItem(
                  icon: Icons.event_outlined,
                  label: 'Events',
                  onTap: () { Navigator.pop(context); },
                ),
                _DrawerItem(
                  icon: Icons.bookmark_border_rounded,
                  label: 'Saved Posts',
                  onTap: () { Navigator.pop(context); },
                ),
                const Divider(height: 24, indent: 20, endIndent: 20),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () { Navigator.pop(context); },
                ),
                _DrawerItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Support',
                  onTap: () { Navigator.pop(context); },
                ),
              ],
            ),
          ),

          // ── Logout ──
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              color: AppColors.error,
              onTap: () => _handleLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Log Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final authRepo = getIt<AuthRepository>();
    await authRepo.logout();
    if (context.mounted) context.go('/auth/login');
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22, color: color ?? AppColors.textSecondary),
      title: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color ?? AppColors.textPrimary)),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}

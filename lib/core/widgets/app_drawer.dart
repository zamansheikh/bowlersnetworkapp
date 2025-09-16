import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/home/data/models/user_model.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                final user = state.user;
                // Check if user is UserModel to access profilePictureUrl
                Widget profileImage = CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                );

                // If user is UserModel and has profile picture, use it
                if (user is UserModel && user.profilePictureUrl.isNotEmpty) {
                  profileImage = CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(user.profilePictureUrl),
                    onBackgroundImageError: (_, __) {
                      // Fallback handled by providing a child
                    },
                    child: user.profilePictureUrl.isEmpty
                        ? Text(
                            user.name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          )
                        : null,
                  );
                }

                return UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blue.shade800],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  accountName: Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  accountEmail: Text(
                    user.email,
                    style: const TextStyle(fontSize: 14),
                  ),
                  currentAccountPicture: profileImage,
                );
              }
              return const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              // Use pushReplacement to replace the current route if not already on home
              if (GoRouter.of(context)
                      .routerDelegate
                      .currentConfiguration
                      .matches
                      .last
                      .matchedLocation !=
                  '/') {
                context.pushReplacement('/');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              context.push('/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Pro Players'),
            onTap: () {
              Navigator.pop(context);
              context.push('/pro-players');
            },
          ),
          ListTile(
            leading: const Icon(Icons.sports),
            title: const Text('Bowling Stats'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to bowling stats page when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bowling stats coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Friends'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to friends page when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Friends page coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Sponsors'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to sponsors page when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sponsors page coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings page when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings page coming soon!')),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to help page when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to about page when implemented
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('About page coming soon!')),
              );
            },
          ),
          const Divider(),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
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

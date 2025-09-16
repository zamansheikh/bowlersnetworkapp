import 'package:bowlersnetworkapp/core/constants/colors.dart';
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
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is Authenticated) {
                      final user = state.user;
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
                      if (user is UserModel &&
                          user.profilePictureUrl.isNotEmpty) {
                        profileImage = CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(user.profilePictureUrl),
                          onBackgroundImageError: (_, __) {},
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
                          gradient: AppColors.primaryGradient,
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
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: BlocBuilder<AuthCubit, AuthState>(
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
          ),
          const SizedBox(height: 24),
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

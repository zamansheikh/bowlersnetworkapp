import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/consent_pending_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_completion_wizard_page.dart';
import '../../features/shell/presentation/pages/main_shell_page.dart';
import '../di/injection.dart';
import '../storage/secure_storage_service.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  redirect: _globalRedirect,
  routes: [
    GoRoute(
      path: '/splash',
      name: RouteNames.splash,
      builder: (_, _) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (_, _) => const OnboardingPage(),
    ),

    // Auth routes
    GoRoute(
      path: '/auth/login',
      name: RouteNames.login,
      builder: (_, _) => const LoginPage(),
    ),
    GoRoute(
      path: '/auth/signup',
      name: RouteNames.signup,
      builder: (_, _) => const SignupPage(),
    ),
    GoRoute(
      path: '/auth/forgot-password',
      name: RouteNames.forgotPassword,
      builder: (_, _) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/auth/reset-password',
      name: RouteNames.resetPassword,
      builder: (_, state) => ResetPasswordPage(
        token: state.uri.queryParameters['token'] ?? '',
      ),
    ),
    GoRoute(
      path: '/auth/consent-pending',
      name: RouteNames.consentPending,
      builder: (_, _) => const ConsentPendingPage(),
    ),

    // Profile wizard
    GoRoute(
      path: '/profile-wizard',
      name: RouteNames.profileWizard,
      builder: (_, _) => const ProfileCompletionWizardPage(),
    ),

    // Main shell with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (_, _, navigationShell) => MainShellPage(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: RouteNames.home,
              builder: (_, _) => const _PlaceholderPage(title: 'Home'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/media',
              name: RouteNames.media,
              builder: (_, _) => const _PlaceholderPage(title: 'Media'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/score',
              name: RouteNames.score,
              builder: (_, _) => const _PlaceholderPage(title: 'Score'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/messages',
              name: RouteNames.messages,
              builder: (_, _) => const _PlaceholderPage(title: 'Messages'),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: RouteNames.profile,
              builder: (_, _) => const _PlaceholderPage(title: 'Profile'),
            ),
          ],
        ),
      ],
    ),
  ],
);

Future<String?> _globalRedirect(BuildContext context, GoRouterState state) async {
  final secureStorage = getIt<SecureStorageService>();
  final hasToken = await secureStorage.hasToken();
  final currentPath = state.uri.path;

  final isAuthRoute = currentPath.startsWith('/auth');
  final isSplash = currentPath == '/splash';
  final isOnboarding = currentPath == '/onboarding';

  if (isSplash || isOnboarding) return null;

  if (!hasToken && !isAuthRoute) {
    return '/auth/login';
  }

  if (hasToken && isAuthRoute) {
    return '/home';
  }

  return null;
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\nComing Soon',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

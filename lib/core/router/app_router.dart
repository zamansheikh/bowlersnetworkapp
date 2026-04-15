import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/consent_pending_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/password_recovery_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/games/presentation/screens/games_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/messages/presentation/screens/messages_screen.dart';
import '../../features/newsfeed/presentation/screens/feed_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/shell/main_shell_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'route_names.dart';

/// Builds the app's [GoRouter] with auth-aware redirect logic + a stateful
/// shell for the 5 primary tabs.
GoRouter buildAppRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    refreshListenable: _AuthBlocListenable(authBloc),
    redirect: (context, state) {
      final status = authBloc.state.status;
      final path = state.matchedLocation;

      // Always allow the splash screen — it decides the real initial route.
      if (path == RouteNames.splash) return null;

      final inAuthFlow = path == RouteNames.login ||
          path == RouteNames.signup ||
          path == RouteNames.passwordRecovery ||
          path == RouteNames.onboarding;

      switch (status) {
        case AuthStatus.unknown:
          return RouteNames.splash;

        case AuthStatus.unauthenticated:
          return inAuthFlow ? null : RouteNames.login;

        case AuthStatus.requiresConsent:
          return path == RouteNames.consentPending
              ? null
              : RouteNames.consentPending;

        case AuthStatus.authenticatedUnverified:
          // Token valid but ProfileBloc has confirmed the profile is
          // incomplete. Only /profile + /settings + recovery are reachable.
          const exempt = {
            RouteNames.profile,
            RouteNames.settings,
            RouteNames.passwordRecovery,
          };
          if (exempt.contains(path)) return null;
          return RouteNames.profile;

        case AuthStatus.authenticated:
          // Fully logged in — auth screens redirect back to home.
          if (inAuthFlow || path == RouteNames.consentPending) {
            return RouteNames.home;
          }
          return null;
      }
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (_, _) => const SignupScreen(),
      ),
      GoRoute(
        path: RouteNames.passwordRecovery,
        builder: (_, _) => const PasswordRecoveryScreen(),
      ),
      GoRoute(
        path: RouteNames.consentPending,
        builder: (_, _) => const ConsentPendingScreen(),
      ),

      // Main-app shell: 5 tabs, each with its own navigation stack.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => MainShellScreen(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.home,
              builder: (_, _) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.newsfeed,
              builder: (_, _) => const FeedScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.games,
              builder: (_, _) => const GamesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.messages,
              builder: (_, _) => const MessagesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.profile,
              builder: (_, _) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
}

/// Bridges [AuthBloc] into go_router's [Listenable] API so redirect logic
/// re-runs whenever auth state changes.
class _AuthBlocListenable extends ChangeNotifier {
  _AuthBlocListenable(AuthBloc bloc) {
    _sub = bloc.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

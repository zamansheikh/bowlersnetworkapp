import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import 'route_names.dart';

/// Top-level router. Auth guard / profile-completion guard are added in
/// Phase 1 once the AuthBloc exists — for now the Splash screen routes by
/// reading persistent state directly.
final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: false,
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
      path: RouteNames.home,
      builder: (_, _) => const HomeScreen(),
    ),
  ],
);

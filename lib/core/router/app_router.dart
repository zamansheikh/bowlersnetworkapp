import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/auth/presentation/pages/profile_completion_page.dart';
import '../../features/profile/presentation/pages/user_profile_page.dart';

class AppRouter {
  static GoRouter create(AuthCubit authCubit) {
    return GoRouter(
      redirect: (context, state) {
        final authState = authCubit.state;
        final isAuth = authState is Authenticated;
        final isIncompleteProfile = authState is AuthenticatedIncompleteProfile;
        final loggingIn = state.matchedLocation == '/login';
        final signingUp = state.matchedLocation.startsWith('/signup');
        final completingProfile = state.matchedLocation == '/complete-profile';

        // If user has incomplete profile and not on completion page, redirect there
        if (isIncompleteProfile && !completingProfile) {
          return '/complete-profile';
        }

        // If user is authenticated (complete profile) and on auth pages, go home
        if (isAuth && (loggingIn || signingUp || completingProfile)) {
          return '/';
        }

        // If user is not authenticated and not on auth pages, go to login
        if (!isAuth && !isIncompleteProfile && !loggingIn && !signingUp) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const SignInPage(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: '/signup/email-verification',
          name: 'email-verification',
          builder: (context, state) {
            final extra = state.extra as Map<String, String>?;
            if (extra == null) {
              return const SignupPage(); // Fallback if no data
            }
            return EmailVerificationPage(
              email: extra['email']!,
              signupData: {
                'firstName': extra['firstName']!,
                'lastName': extra['lastName']!,
                'username': extra['username']!,
                'password': extra['password']!,
              },
            );
          },
        ),
        GoRoute(
          path: '/complete-profile',
          name: 'complete-profile',
          builder: (context, state) => const ProfileCompletionPage(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const UserProfilePage(),
        ),
      ],
      errorBuilder: (context, state) => const ErrorPage(),
    );
  }
}

// Simple ChangeNotifier tie-in for stream changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('Page not found!')),
    );
  }
}

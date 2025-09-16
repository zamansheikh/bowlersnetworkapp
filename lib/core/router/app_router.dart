import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/post_detail_page.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/auth/presentation/pages/profile_completion_page.dart';
import '../../features/profile/presentation/pages/user_profile_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';

class AppRouter {
  static GoRouter create(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final authState = authCubit.state;
        final isAuth = authState is Authenticated;
        final isIncompleteProfile = authState is AuthenticatedIncompleteProfile;
        final isLoading = authState is AuthLoading;
        final isUnauthenticated = authState is Unauthenticated;

        final isSplash = state.matchedLocation == '/splash';
        final isSigningIn = state.matchedLocation == '/signin';
        final isSigningUp = state.matchedLocation.startsWith('/signup');
        final isCompletingProfile =
            state.matchedLocation == '/complete-profile';

        // During loading, only redirect to splash if we're on an auth page or have no location
        if (isLoading &&
            (isSigningIn || isSigningUp || state.matchedLocation == '/')) {
          return '/splash';
        }

        // If user has incomplete profile and not on completion page, redirect there
        if (isIncompleteProfile && !isCompletingProfile) {
          return '/complete-profile';
        }

        // If user is authenticated (complete profile) and on auth pages, go home
        if (isAuth &&
            (isSplash || isSigningIn || isSigningUp || isCompletingProfile)) {
          return '/';
        }

        // If user is not authenticated and not on auth pages, go to signin
        if (isUnauthenticated && !isSigningIn && !isSigningUp) {
          return '/signin';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/signin',
          name: 'signin',
          builder: (context, state) => const SignInPage(),
        ),
        // Keep old /login route for backward compatibility
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
                'birthDate': extra['birthDate'] ?? '',
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
        GoRoute(
          path: '/profile/edit',
          name: 'profile-edit',
          builder: (context, state) => const ProfileEditPage(),
        ),
        GoRoute(
          path: '/post/:id',
          name: 'post-detail',
          builder: (context, state) {
            final postId = state.pathParameters['id']!;
            return PostDetailPage(postId: postId);
          },
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

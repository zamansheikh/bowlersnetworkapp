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
import '../../features/pro_players/presentation/pages/pro_players_page.dart';
import '../../features/pro_players/presentation/pages/player_detail_page.dart';
import '../../features/overview/presentation/pages/overview_page.dart';
import '../../features/messages/presentation/pages/messages_page.dart';

class AppRouter {
  static GoRouter create(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(authCubit.stream),
      redirect: (context, state) {
        final authState = authCubit.state;
        final isAuth = authState is Authenticated;
        final isIncompleteProfile = authState is AuthenticatedIncompleteProfile;
        final isLoading = authState is AuthLoading;
        final isInitial = authState is AuthInitial;
        final isUnauthenticated = authState is Unauthenticated;

        final isSplash = state.matchedLocation == '/splash';
        final isSigningIn = state.matchedLocation == '/signin';
        final isSigningUp = state.matchedLocation.startsWith('/signup');
        final isCompletingProfile =
            state.matchedLocation == '/complete-profile';

        print('🛣️ Router: Redirecting from ${state.matchedLocation}');
        print('🛣️ Router: Auth state: ${authState.runtimeType}');

        // Show splash during initial auth loading or initial state
        if (isLoading || isInitial) {
          print('🛣️ Router: Staying on splash (loading/initial)');
          return '/splash';
        }

        // If user has incomplete profile and not on completion page, redirect there
        if (isIncompleteProfile && !isCompletingProfile) {
          print('🛣️ Router: Redirecting to profile completion');
          return '/complete-profile';
        }

        // If user is authenticated and on auth pages, go home
        if (isAuth &&
            (isSplash || isSigningIn || isSigningUp || isCompletingProfile)) {
          print('🛣️ Router: Authenticated user, redirecting to home');
          return '/';
        }

        // If user is not authenticated and not on auth pages, go to signin
        if (isUnauthenticated && !isSigningIn && !isSigningUp) {
          print('🛣️ Router: Unauthenticated user, redirecting to signin');
          return '/signin';
        }

        print('🛣️ Router: No redirect needed');
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
          path: '/overview',
          name: 'overview',
          builder: (context, state) => const OverviewPage(),
        ),
        GoRoute(
          path: '/post/:id',
          name: 'post-detail',
          builder: (context, state) {
            final postId = state.pathParameters['id']!;
            return PostDetailPage(postId: postId);
          },
        ),
        GoRoute(
          path: '/pro-players',
          name: 'pro-players',
          builder: (context, state) => const ProPlayersPage(),
        ),
        GoRoute(
          path: '/player/:userId',
          name: 'player-detail',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            final extra = state.extra as Map<String, String>?;
            final userIdParam = extra != null && extra.containsKey('userId')
                ? extra['userId']!
                : userId;
            return PlayerDetailPage(userName: userId, userId: userIdParam);
          },
        ),
        GoRoute(
          path: '/messages',
          name: 'messages',
          builder: (context, state) {
            final targetRoomId = state.uri.queryParameters['room_id'];
            return MessagesPage(
              targetRoomId: targetRoomId != null
                  ? int.tryParse(targetRoomId)
                  : null,
            );
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

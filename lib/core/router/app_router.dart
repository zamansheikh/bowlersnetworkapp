import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../features/games/presentation/pages/add_score_screen.dart';
import '../../features/games/presentation/pages/games_list_page.dart';
import '../../features/games/presentation/pages/edit_game_page.dart';
import '../../features/games/presentation/pages/game_analytics_page.dart';
import '../../features/games/presentation/pages/games_settings_page.dart';
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
import '../../features/events/presentation/pages/events_page.dart';
import '../../features/tournaments/presentation/pages/tournaments_page.dart';
import '../../features/tournaments/presentation/pages/tournament_detail_page.dart';
import '../../features/tournaments/domain/entities/tournament.dart';
import '../../features/teams/presentation/pages/teams_page.dart';
import '../../features/teams/presentation/pages/team_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../widgets/main_shell.dart';

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

        debugPrint('🛣️ Router: Redirecting from ${state.matchedLocation}');
        debugPrint('🛣️ Router: Auth state: ${authState.runtimeType}');

        // Show splash during initial auth loading or initial state
        if (isLoading || isInitial) {
          debugPrint('🛣️ Router: Staying on splash (loading/initial)');
          return '/splash';
        }

        // If user has incomplete profile and not on completion page, redirect there
        if (isIncompleteProfile && !isCompletingProfile) {
          debugPrint('🛣️ Router: Redirecting to profile completion');
          return '/complete-profile';
        }

        // If user is authenticated and on auth pages, go home
        if (isAuth &&
            (isSplash || isSigningIn || isSigningUp || isCompletingProfile)) {
          debugPrint('🛣️ Router: Authenticated user, redirecting to home');
          return '/';
        }

        // If user is not authenticated and not on auth pages, go to signin
        if (isUnauthenticated && !isSigningIn && !isSigningUp) {
          debugPrint('🛣️ Router: Unauthenticated user, redirecting to signin');
          return '/signin';
        }

        debugPrint('🛣️ Router: No redirect needed');
        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashPage(),
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

        // Shell route for main app navigation with bottom nav bar
        ShellRoute(
          builder: (context, state, child) {
            return MainShell(
              currentLocation: state.matchedLocation,
              child: child,
            );
          },
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/messages',
              name: 'messages',
              builder: (context, state) => const MessagesPage(),
            ),
            GoRoute(
              path: '/events',
              name: 'events',
              builder: (context, state) => const EventsPage(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const UserProfilePage(),
            ),
          ],
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

        // Routes outside shell (no bottom nav bar)
        GoRoute(
          path: '/complete-profile',
          name: 'complete-profile',
          builder: (context, state) => const ProfileCompletionPage(),
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
          path: '/tournaments',
          name: 'tournaments',
          builder: (context, state) => const TournamentsPage(),
        ),
        GoRoute(
          path: '/teams',
          name: 'teams',
          builder: (context, state) => const TeamsPage(),
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
          path: '/tournaments/:id',
          name: 'tournament-detail',
          builder: (context, state) {
            final tournamentId = int.parse(state.pathParameters['id']!);
            final tournament = state.extra as Tournament?;
            return TournamentDetailPage(
              tournamentId: tournamentId,
              tournament: tournament,
            );
          },
        ),
        GoRoute(
          path: '/teams/:id',
          name: 'team-detail',
          builder: (context, state) {
            final teamId = state.pathParameters['id']!;
            return TeamDetailsPage(teamId: teamId);
          },
        ),
        GoRoute(
          path: '/games',
          name: 'games',
          builder: (context, state) => const GamesListPage(),
        ),
        GoRoute(
          path: '/games-settings',
          name: 'games_settings',
          builder: (context, state) => const GamesSettingsPage(),
        ),
        GoRoute(
          path: '/add-score',
          name: 'add_score',
          builder: (context, state) {
            final setupData = state.extra;
            return AddScoreScreen(gameSetupData: setupData);
          },
        ),
        GoRoute(
          path: '/edit-game/:id',
          name: 'edit_game',
          builder: (context, state) {
            final gameId = state.pathParameters['id']!;
            return EditGamePage(gameId: gameId);
          },
        ),
        GoRoute(
          path: '/game-analytics/:id',
          name: 'game_analytics',
          builder: (context, state) {
            final gameId = state.pathParameters['id']!;
            return GameAnalyticsPage(gameId: gameId);
          },
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsPage(),
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

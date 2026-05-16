import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/consent_pending_screen.dart';
import '../../features/brands/presentation/screens/brands_screen.dart';
import '../../features/cards/presentation/screens/cards_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/chatter/presentation/screens/chatter_screen.dart';
import '../../features/chatter/presentation/screens/discussion_detail_screen.dart';
import '../../features/events/domain/entities/event.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/events/presentation/screens/event_editor_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/events/presentation/screens/invitations_screen.dart';
import '../../features/events/presentation/screens/my_events_screen.dart';
import '../../features/feedback/presentation/screens/feedback_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/password_recovery_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/follow/presentation/bloc/follow_list_bloc.dart';
import '../../features/follow/presentation/screens/follow_list_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/media/presentation/screens/media_screen.dart';
import '../../features/games/domain/entities/session.dart';
import '../../features/games/presentation/screens/equipment_screen.dart';
import '../../features/games/presentation/screens/games_screen.dart';
import '../../features/games/presentation/screens/play_screen.dart';
import '../../features/games/presentation/screens/session_detail_screen.dart';
import '../../features/games/presentation/screens/stats_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/messages/domain/entities/conversation.dart';
import '../../features/messages/presentation/screens/messages_screen.dart';
import '../../features/messages/presentation/screens/thread_screen.dart';
import '../../features/newsfeed/presentation/screens/feed_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/other_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/shell/main_shell_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/teams/presentation/screens/team_detail_screen.dart';
import '../../features/teams/presentation/screens/teams_screen.dart';
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

      // Secondary routes (reached from the side drawer / deep links).
      // Live outside the shell so they get a full back-able screen.
      GoRoute(
        path: RouteNames.leaderboard,
        builder: (_, _) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: RouteNames.search,
        builder: (_, _) => const SearchScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.feedback,
        builder: (_, _) => const FeedbackScreen(),
      ),
      GoRoute(
        path: RouteNames.cards,
        builder: (_, _) => const CardsScreen(),
      ),
      GoRoute(
        path: RouteNames.media,
        builder: (_, _) => const MediaScreen(),
      ),
      GoRoute(
        path: RouteNames.brands,
        builder: (_, _) => const BrandsScreen(),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        builder: (_, _) => const DashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.teams,
        builder: (_, _) => const TeamsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) {
                return const Scaffold(
                  body: Center(child: Text('Team not found')),
                );
              }
              return TeamDetailScreen(teamId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.events,
        builder: (_, _) => const EventsScreen(),
        routes: [
          // Specific sub-paths first so go_router prefers them over
          // the `:uid` parameterised route below.
          GoRoute(
            path: 'new',
            builder: (_, _) => const EventEditorScreen(),
          ),
          GoRoute(
            path: 'my',
            builder: (_, _) => const MyEventsScreen(),
          ),
          GoRoute(
            path: 'invitations',
            builder: (_, _) => const InvitationsScreen(),
          ),
          GoRoute(
            path: ':uid',
            builder: (_, state) => EventDetailScreen(
              uid: state.pathParameters['uid']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (_, state) => EventEditorScreen(
                  // `state.extra` is the already-loaded Event so we
                  // skip a redundant detail fetch when entering edit
                  // mode from the detail menu.
                  existing: state.extra as Event?,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.chatter,
        builder: (_, _) => const ChatterScreen(),
        routes: [
          GoRoute(
            path: ':uid',
            builder: (_, state) => DiscussionDetailScreen(
              uid: state.pathParameters['uid']!,
            ),
          ),
        ],
      ),
      // Other-user profile lives at `/u/:username` (NOT `/profile/...`)
      // so it never collides with the shell's `/profile/edit`,
      // `/profile/followers`, `/profile/followings` literals. The web
      // uses `/profile/{username}` but on mobile the `/profile` namespace
      // belongs to the logged-in user's tab.
      GoRoute(
        path: '/u/:username',
        builder: (_, state) => OtherProfileScreen(
          username: state.pathParameters['username']!,
        ),
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
              routes: [
                GoRoute(
                  path: 'sessions/:uid',
                  builder: (context, state) {
                    final session = state.extra as Session?;
                    if (session == null) {
                      return const Scaffold(
                        body: Center(child: Text('Session not found')),
                      );
                    }
                    return SessionDetailScreen(session: session);
                  },
                ),
                GoRoute(
                  path: 'play/:uid',
                  builder: (_, state) => PlayScreen(
                    sessionUid: state.pathParameters['uid']!,
                  ),
                ),
                GoRoute(
                  path: 'equipment',
                  builder: (_, _) => const EquipmentScreen(),
                ),
                GoRoute(
                  path: 'stats',
                  builder: (_, _) => const StatsScreen(),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.messages,
              builder: (_, _) => const MessagesScreen(),
              routes: [
                GoRoute(
                  path: ':uid',
                  builder: (context, state) {
                    final c = state.extra as ConversationListItem?;
                    if (c == null) {
                      return const Scaffold(
                        body: Center(child: Text('Conversation not found')),
                      );
                    }
                    return ThreadScreen(conversation: c);
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: RouteNames.profile,
              builder: (_, _) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (_, _) => const EditProfileScreen(),
                ),
                GoRoute(
                  path: 'followers',
                  builder: (_, _) => const FollowListScreen(
                    source: FollowListSource.myFollowers,
                  ),
                ),
                GoRoute(
                  path: 'followings',
                  builder: (_, _) => const FollowListScreen(
                    source: FollowListSource.myFollowings,
                  ),
                ),
              ],
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

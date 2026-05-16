/// Canonical route paths for go_router. Never hardcode raw strings at
/// call sites — use these constants so rename refactors are safe.
class RouteNames {
  RouteNames._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';

  // Auth
  static const String login = '/login';
  static const String signup = '/signup';
  static const String consentPending = '/consent-pending';
  static const String passwordRecovery = '/password-recovery';

  // Main app
  static const String home = '/';
  static const String newsfeed = '/newsfeed';
  static const String games = '/games';
  static const String messages = '/messages';
  static const String profile = '/profile';

  // Profile sub-routes (followers / followings list of the current user).
  static const String myFollowers = '/profile/followers';
  static const String myFollowings = '/profile/followings';

  // Secondary
  static const String chatter = '/chatter';
  static const String media = '/media';
  static const String events = '/events';
  static const String cards = '/cards';
  static const String teams = '/teams';
  static const String notifications = '/notifications';
  static const String dashboard = '/dashboard';
  static const String leaderboard = '/leaderboard';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String feedback = '/feedback';
}

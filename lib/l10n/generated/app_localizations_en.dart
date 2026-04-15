// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BowlersNetwork';

  @override
  String get appTagline => 'The ultimate bowling community';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionNext => 'Next';

  @override
  String get actionSkip => 'Skip';

  @override
  String get actionBack => 'Back';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDone => 'Done';

  @override
  String get actionRetry => 'Try Again';

  @override
  String get actionGetStarted => 'Get Started';

  @override
  String get actionLogin => 'Log In';

  @override
  String get actionSignUp => 'Sign Up';

  @override
  String get actionLogout => 'Log Out';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionSearch => 'Search';

  @override
  String get actionSeeAll => 'See All';

  @override
  String get actionViewAll => 'View All';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonSomethingWentWrong => 'Something went wrong';

  @override
  String get commonNoConnection => 'No internet connection';

  @override
  String get commonEmptyListTitle => 'Nothing here yet';

  @override
  String get onboardingPage1Title => 'Welcome to BowlersNetwork';

  @override
  String get onboardingPage1Description =>
      'The home for every bowler — amateurs, pros, coaches, and fans. Connect, compete, and grow your game.';

  @override
  String get onboardingPage2Title => 'Track Every Frame';

  @override
  String get onboardingPage2Description =>
      'Log games frame-by-frame, analyse pin-leaves, and review your performance across centers, balls, and conditions.';

  @override
  String get onboardingPage3Title => 'Join the Community';

  @override
  String get onboardingPage3Description =>
      'Share posts, watch splits, discuss strategy, and follow your favourite pros — all in one place.';

  @override
  String get onboardingPage4Title => 'Earn XP. Climb Ranks.';

  @override
  String get onboardingPage4Description =>
      'Every game, post, and reaction earns XP. Level up, collect badges, and rise through the leaderboard.';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to pick up where you left off.';

  @override
  String get loginEmailLabel => 'Email or username';

  @override
  String get loginEmailHint => 'you@example.com';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => '••••••••';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get signupTitle => 'Create your account';

  @override
  String get signupSubtitle => 'Join the bowling community in under a minute.';

  @override
  String get signupAlreadyHaveAccount => 'Already have an account?';

  @override
  String get homeTitle => 'Home';

  @override
  String homeGreeting(String name) {
    return 'Welcome, $name';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navNewsfeed => 'Newsfeed';

  @override
  String get navGames => 'Games';

  @override
  String get navMessages => 'Messages';

  @override
  String get navProfile => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';
}

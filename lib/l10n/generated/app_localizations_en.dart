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
  String get actionSend => 'Send';

  @override
  String get actionSubmit => 'Submit';

  @override
  String get actionVerify => 'Verify';

  @override
  String get actionResend => 'Resend code';

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
  String get loginCredentialRequired => 'Enter your email or username';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get signupTitle => 'Create your account';

  @override
  String get signupSubtitle => 'Join the bowling community in under a minute.';

  @override
  String get signupFirstNameLabel => 'First name';

  @override
  String get signupLastNameLabel => 'Last name';

  @override
  String get signupUsernameLabel => 'Username';

  @override
  String get signupUsernameHint => '4-12 characters, letters and numbers';

  @override
  String get signupEmailLabel => 'Email';

  @override
  String get signupPasswordLabel => 'Password';

  @override
  String get signupPasswordHint => 'At least 8 characters';

  @override
  String get signupDobLabel => 'Date of birth';

  @override
  String get signupIsCoachLabel => 'I\'m a coach';

  @override
  String get signupParentEmailLabel => 'Parent\'s email';

  @override
  String get signupParentEmailHint => 'We\'ll email them for consent';

  @override
  String get signupStepAccount => 'Account';

  @override
  String get signupStepVerify => 'Verify email';

  @override
  String get signupStepProfile => 'Your info';

  @override
  String get signupVerificationCodeLabel => 'Verification code';

  @override
  String signupVerificationSent(String email) {
    return 'We sent a 6-digit code to $email';
  }

  @override
  String get signupAlreadyHaveAccount => 'Already have an account?';

  @override
  String get signupFieldRequired => 'This field is required';

  @override
  String get signupPasswordTooShort => 'Password must be at least 8 characters';

  @override
  String get signupInvalidEmail => 'Enter a valid email';

  @override
  String get signupInvalidUsername =>
      '4-12 characters, letters, numbers, underscores';

  @override
  String get signupMustBe13 => 'You must be at least 13 years old';

  @override
  String get consentPendingTitle => 'Waiting on parent consent';

  @override
  String get consentPendingDescription =>
      'We emailed your parent for approval. Once they confirm, your account will unlock automatically.';

  @override
  String get consentPendingRefresh => 'Check again';

  @override
  String get recoveryTitle => 'Reset your password';

  @override
  String get recoverySubtitle =>
      'Enter the email for your account and we\'ll send you a 6-digit code.';

  @override
  String get recoverySentTitle => 'Check your email';

  @override
  String recoverySentDescription(String email) {
    return 'We sent a verification code to $email.';
  }

  @override
  String get recoveryNewPasswordLabel => 'New password';

  @override
  String get recoveryConfirmPasswordLabel => 'Confirm password';

  @override
  String get recoveryPasswordMismatch => 'Passwords don\'t match';

  @override
  String get recoveryDone =>
      'Password updated — sign in with your new password.';

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
  String get profileCompletionBannerTitle => 'Complete your profile';

  @override
  String profileCompletionBannerHint(int percent) {
    return '$percent% done — finish your profile to unlock the app.';
  }

  @override
  String get profileFollowers => 'Followers';

  @override
  String get profileFollowing => 'Following';

  @override
  String get profileFollow => 'Follow';

  @override
  String get profileUnfollow => 'Following';

  @override
  String get profileEdit => 'Edit profile';

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

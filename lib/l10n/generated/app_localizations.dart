import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'BowlersNetwork'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'The ultimate bowling community'**
  String get appTagline;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get actionSkip;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get actionRetry;

  /// No description provided for @actionGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get actionGetStarted;

  /// No description provided for @actionLogin.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get actionLogin;

  /// No description provided for @actionSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get actionSignUp;

  /// No description provided for @actionLogout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get actionLogout;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get actionSearch;

  /// No description provided for @actionSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get actionSeeAll;

  /// No description provided for @actionViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get actionViewAll;

  /// No description provided for @actionSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get actionSend;

  /// No description provided for @actionSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get actionSubmit;

  /// No description provided for @actionVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get actionVerify;

  /// No description provided for @actionResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get actionResend;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get commonNoConnection;

  /// No description provided for @commonEmptyListTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get commonEmptyListTitle;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BowlersNetwork'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Description.
  ///
  /// In en, this message translates to:
  /// **'The home for every bowler — amateurs, pros, coaches, and fans. Connect, compete, and grow your game.'**
  String get onboardingPage1Description;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Track Every Frame'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Description.
  ///
  /// In en, this message translates to:
  /// **'Log games frame-by-frame, analyse pin-leaves, and review your performance across centers, balls, and conditions.'**
  String get onboardingPage2Description;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Join the Community'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Description.
  ///
  /// In en, this message translates to:
  /// **'Share posts, watch splits, discuss strategy, and follow your favourite pros — all in one place.'**
  String get onboardingPage3Description;

  /// No description provided for @onboardingPage4Title.
  ///
  /// In en, this message translates to:
  /// **'Earn XP. Climb Ranks.'**
  String get onboardingPage4Title;

  /// No description provided for @onboardingPage4Description.
  ///
  /// In en, this message translates to:
  /// **'Every game, post, and reaction earns XP. Level up, collect badges, and rise through the leaderboard.'**
  String get onboardingPage4Description;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to pick up where you left off.'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••••'**
  String get loginPasswordHint;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginCredentialRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or username'**
  String get loginCredentialRequired;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordRequired;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the bowling community in under a minute.'**
  String get signupSubtitle;

  /// No description provided for @signupFirstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get signupFirstNameLabel;

  /// No description provided for @signupLastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get signupLastNameLabel;

  /// No description provided for @signupUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get signupUsernameLabel;

  /// No description provided for @signupUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'4-12 characters, letters and numbers'**
  String get signupUsernameHint;

  /// No description provided for @signupEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get signupEmailLabel;

  /// No description provided for @signupPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signupPasswordLabel;

  /// No description provided for @signupPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get signupPasswordHint;

  /// No description provided for @signupDobLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get signupDobLabel;

  /// No description provided for @signupIsCoachLabel.
  ///
  /// In en, this message translates to:
  /// **'I\'m a coach'**
  String get signupIsCoachLabel;

  /// No description provided for @signupParentEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent\'s email'**
  String get signupParentEmailLabel;

  /// No description provided for @signupParentEmailHint.
  ///
  /// In en, this message translates to:
  /// **'We\'ll email them for consent'**
  String get signupParentEmailHint;

  /// No description provided for @signupStepAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get signupStepAccount;

  /// No description provided for @signupStepVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify email'**
  String get signupStepVerify;

  /// No description provided for @signupStepProfile.
  ///
  /// In en, this message translates to:
  /// **'Your info'**
  String get signupStepProfile;

  /// No description provided for @signupVerificationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get signupVerificationCodeLabel;

  /// No description provided for @signupVerificationSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}'**
  String signupVerificationSent(String email);

  /// No description provided for @signupAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get signupAlreadyHaveAccount;

  /// No description provided for @signupFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get signupFieldRequired;

  /// No description provided for @signupPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get signupPasswordTooShort;

  /// No description provided for @signupInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get signupInvalidEmail;

  /// No description provided for @signupInvalidUsername.
  ///
  /// In en, this message translates to:
  /// **'4-12 characters, letters, numbers, underscores'**
  String get signupInvalidUsername;

  /// No description provided for @signupMustBe13.
  ///
  /// In en, this message translates to:
  /// **'You must be at least 13 years old'**
  String get signupMustBe13;

  /// No description provided for @consentPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting on parent consent'**
  String get consentPendingTitle;

  /// No description provided for @consentPendingDescription.
  ///
  /// In en, this message translates to:
  /// **'We emailed your parent for approval. Once they confirm, your account will unlock automatically.'**
  String get consentPendingDescription;

  /// No description provided for @consentPendingRefresh.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get consentPendingRefresh;

  /// No description provided for @recoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get recoveryTitle;

  /// No description provided for @recoverySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the email for your account and we\'ll send you a 6-digit code.'**
  String get recoverySubtitle;

  /// No description provided for @recoverySentTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get recoverySentTitle;

  /// No description provided for @recoverySentDescription.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification code to {email}.'**
  String recoverySentDescription(String email);

  /// No description provided for @recoveryNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get recoveryNewPasswordLabel;

  /// No description provided for @recoveryConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get recoveryConfirmPasswordLabel;

  /// No description provided for @recoveryPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get recoveryPasswordMismatch;

  /// No description provided for @recoveryDone.
  ///
  /// In en, this message translates to:
  /// **'Password updated — sign in with your new password.'**
  String get recoveryDone;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String homeGreeting(String name);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navNewsfeed.
  ///
  /// In en, this message translates to:
  /// **'Newsfeed'**
  String get navNewsfeed;

  /// No description provided for @navGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get navGames;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @profileCompletionBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get profileCompletionBannerTitle;

  /// No description provided for @profileCompletionBannerHint.
  ///
  /// In en, this message translates to:
  /// **'{percent}% done — finish your profile to unlock the app.'**
  String profileCompletionBannerHint(int percent);

  /// No description provided for @profileFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get profileFollowers;

  /// No description provided for @profileFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profileFollowing;

  /// No description provided for @profileFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get profileFollow;

  /// No description provided for @profileUnfollow.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get profileUnfollow;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

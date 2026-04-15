class AppConstants {
  AppConstants._();

  static const String appName = 'BowlersNetwork';
  static const String appTagline = 'The ultimate bowling community';

  // ScreenUtil design reference (iPhone 14 logical size)
  static const double designWidth = 390;
  static const double designHeight = 844;

  // Asset paths for logos
  static const String remoteLogoUrl =
      'https://logos.bowlersnetwork.com/bn_logo_2026.png';
}

/// Keys used with SharedPreferences / secure storage. Centralised so we never
/// drift on key naming across features.
class StorageKeys {
  StorageKeys._();

  // Auth
  static const String authToken = 'bn_auth_token';
  static const String userId = 'bn_user_id';
  static const String isPro = 'bn_is_pro';

  // Theme + locale
  static const String themeMode = 'bn_theme'; // light | dark | system
  static const String locale = 'bn_locale'; // e.g. "en", "es"

  // Onboarding
  static const String onboardingSeen = 'bn_onboarding_seen';

  // Preferences
  static const String xpBubblesEnabled = 'bn_xp_bubbles_enabled';
  static const String pushNotificationsEnabled = 'bn_push_enabled';
}

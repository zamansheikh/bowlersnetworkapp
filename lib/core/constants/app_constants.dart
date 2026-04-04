class AppConstants {
  AppConstants._();

  static const String appName = 'BowlersNetwork';
  static const String appTagline = 'The Ultimate Bowling Community';

  // Design sizes (for ScreenUtil)
  static const double designWidth = 393;
  static const double designHeight = 852;

  // Limits
  static const int maxBioLength = 280;
  static const int maxGroupMembers = 50;
  static const int maxPhotosPerPost = 10;
  static const int maxVideoSizeMb = 100;
  static const int maxVoiceNoteDurationSec = 300;
  static const int maxIntroVideoDurationSec = 30;
  static const int maxBrands = 5;
  static const int maxPinnedPosts = 3;
  static const int otpLength = 6;
  static const int otpResendSeconds = 60;
  static const int searchDebounceMs = 300;

  // Age
  static const int minimumAge = 13;
  static const int adultAge = 18;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String profileCompleteKey = 'profile_complete';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String fcmTokenKey = 'fcm_token';
}

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://backend.bowlersnetwork.com';
  static const String wsBaseUrl = 'wss://backend.bowlersnetwork.com';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int defaultPageSize = 20;
}

class Endpoints {
  Endpoints._();

  // Cloud / file upload
  static const String uploadSinglepart =
      '/api/cloud/upload/singlepart/requests/initiate';
  static const String uploadMultipartInitiate =
      '/api/cloud/upload/multipart/requests/initiate';
  static const String uploadMultipartComplete =
      '/api/cloud/upload/multipart/requests/complete';

  // Auth
  static const String verifyEmail = '/api/auth/verify-email';
  static const String signup = '/api/auth/signup';
  static const String login = '/api/auth/login';

  /// Step-1 validation — mirrors web's first signup step. Returns 200 if the
  /// registration data is valid AND username/email are unused. Lets us show
  /// "username taken" / "email exists" errors before asking for OTP.
  static const String signupValidateRegistration =
      '/api/auth/signup/validate/registration';

  // Password recovery
  static const String recoveryInitiateOtp =
      '/api/access/recovery/initiate/otp';
  static const String recoveryValidateOtp =
      '/api/access/recovery/validate/otp';
  static const String recoveryInitiateMagicLink =
      '/api/access/recovery/initiate/magic-link';
  static const String recoveryValidateMagicKey =
      '/api/access/recovery/validate/magic-key';
  static const String recoveryResetPassword =
      '/api/access/recovery/reset-password';

  // Profile
  static const String myProfile = '/api/profile';
  static const String profileCompletion = '/api/profile/completion';
  static String profileByUsername(String username) => '/api/profile/$username';
  static String profileById(int userId) => '/api/profile/id/$userId';

  // Follow
  static String follow(int userId) => '/api/follow/$userId';
  static const String followers = '/api/followers';
  static const String followings = '/api/followings';

  // Notifications (used for FCM registration after login)
  static const String registerDevice = '/api/notifications/devices/register';
  static const String unregisterDevice =
      '/api/notifications/devices/unregister';

  // Newsfeed
  static const String feed = '/api/newsfeed/feed';
  static String postDetail(String postId) => '/api/newsfeed/$postId';
  static String reactToPost(String postId) => '/api/newsfeed/$postId/react';
  static String savePost(String postId) => '/api/newsfeed/$postId/save';
  static String hidePost(String postId) => '/api/newsfeed/$postId/hide';
  static String sharePost(String postId) => '/api/newsfeed/$postId/share';
  static String postComments(String postId) =>
      '/api/newsfeed/$postId/comments';

  // Reporting
  static const String report = '/api/report';
}

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
  static const String profilePicture = '/api/profile/profile-picture';
  static const String coverPicture = '/api/profile/cover-picture';
  static String profileByUsername(String username) => '/api/profile/$username';
  static String profileById(int userId) => '/api/profile/id/$userId';

  // XP
  static const String xpLevelInfo = '/api/xp/level-info';
  static const String xpDashboard = '/api/xp/dashboard';

  // Brands
  static const String brands = '/api/brands';
  static const String brandsSponsors = '/api/brands/sponsors';

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

  // Comments
  static String commentDetail(int commentId) =>
      '/api/newsfeed/comments/$commentId';
  static String commentLike(int commentId) =>
      '/api/newsfeed/comments/$commentId/like';
  static String commentPin(int commentId) =>
      '/api/newsfeed/comments/$commentId/pin';
  static String commentHide(int commentId) =>
      '/api/newsfeed/comments/$commentId/hide';
  static String commentReplies(int commentId) =>
      '/api/newsfeed/comments/$commentId/replies';

  // Newsfeed creation endpoints — one per post type
  static const String createTextPost = '/api/newsfeed/create/text';
  static const String createPhotoPost = '/api/newsfeed/create/photo';
  static const String createVideoPost = '/api/newsfeed/create/video';
  static const String createScorePost = '/api/newsfeed/create/score';
  static const String createPollPost = '/api/newsfeed/create/poll';

  // Reporting
  static const String report = '/api/report';

  // Games
  static const String gamesSessionsList = '/api/games/sessions/list';
  static const String gamesSessionsCreate = '/api/games/sessions';
  static const String gamesStats = '/api/games/stats';
  static const String gamesEquipment = '/api/games/equipment';
  static String gamesSessionDetail(String uid) =>
      '/api/games/sessions/$uid';
  static String gamesSessionDelete(String uid) =>
      '/api/games/sessions/$uid/delete';
  static String gamesSessionSubmitGame(String uid) =>
      '/api/games/sessions/$uid/submit-game';
  static String gameDetail(int gameId) => '/api/games/$gameId';
  static String gameShared(int gameId) => '/api/games/shared/$gameId';

  // Messages
  static const String conversationsList = '/api/messages/conversations';
  static String conversationDetail(String uid) =>
      '/api/messages/conversations/$uid';
  static String conversationMessages(String uid) =>
      '/api/messages/conversations/$uid/messages';
  static String conversationSend(String uid) =>
      '/api/messages/conversations/$uid/messages/send';
  static String conversationRead(String uid) =>
      '/api/messages/conversations/$uid/read';
  static const String createPrivateConversation = '/api/messages/private';
  static const String createGroupConversation = '/api/messages/group';
  static String deleteMessage(String uid) => '/api/messages/$uid/delete';
}

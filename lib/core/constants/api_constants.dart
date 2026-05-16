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
  static const String login = '/api/auth/login';
  static const String authFeatureStatus = '/api/auth/feature-status';

  // ── Signup (4-step flow, mirrors web exactly) ─────────────────────────────
  // 1. validate/registration — pre-check uniqueness + format BEFORE asking
  //    the user for OTP. Lets us show "username taken" etc. inline.
  // 2. validate/profile — optional pre-check for the (also optional)
  //    bowler-profile step (handedness, ball carry, etc.).
  // 3. submit — emails the OTP. Caches registration server-side.
  // 4. complete — verify OTP + finalise account. Returns auth token.
  static const String signupValidateRegistration =
      '/api/auth/signup/validate/registration';
  static const String signupValidateProfile =
      '/api/auth/signup/validate/profile';
  static const String signupSubmit = '/api/auth/signup/submit';
  static const String signupComplete = '/api/auth/signup/complete';

  // Parental consent (for under-18 signups).
  static const String authConsentVerify = '/api/auth/consent/verify';
  static const String authConsentResend = '/api/auth/consent/resend';

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

  // Per-field profile editors. Each one is a POST whose body shape is
  // documented in the profile section of the backend api-docs.
  static const String profileBio = '/api/profile/bio';
  static const String profileNickname = '/api/profile/nickname';
  static const String profileGender = '/api/profile/gender';
  static const String profileBirthdate = '/api/profile/birthdate';
  static const String profileAddress = '/api/profile/address';
  static const String profileHomeCenter = '/api/profile/home-center';
  static const String profileBallHandlingStyle =
      '/api/profile/ball-handling-style';
  static const String profileOfficialGameStat =
      '/api/profile/official-game-stat';

  // Newsfeed — user-scoped post lists used by the Posts tab on the
  // profile screens.
  static const String myPosts = '/api/newsfeed/my-posts';
  static String userPosts(int userId) => '/api/newsfeed/users/$userId/posts';

  // Centers — scoped search used by the home-center autocomplete in the
  // edit-profile screen.
  static const String searchCenters = '/api/search/centers';

  // Media — per-user video / split lists. The view signature actually
  // expects `username`, NOT `user_id` (the `/channel/<int:user_id>/`
  // route is misconfigured server-side and 500s). The `channels` plural
  // + username path is what the web hits. Responses are wrapped:
  // `{videos: [...], page, page_size}` / `{splits: [...], page, page_size}`.
  static String mediaChannelVideos(String username) =>
      '/api/media/channels/$username/videos';
  static String mediaChannelSplits(String username) =>
      '/api/media/channels/$username/splits';

  // Feedback — bug reports / suggestions submitted by users.
  static const String feedbackSubmit = '/api/feedback/submit';

  // Notification preferences — per-category opt-in/out toggles.
  static const String notificationPreferences =
      '/api/notifications/preferences';

  // Account actions (mutating user identity / credentials).
  static const String accountChangeUsername =
      '/api/account/change-username';
  static const String accountRequestEmailChange =
      '/api/account/request-email-change';
  static const String accountConfirmEmailChange =
      '/api/account/confirm-email-change';

  // Cards — viewer's own cards / collections + per-user cards. Like &
  // collect toggles return authoritative `{is_..., ..._count}` payloads.
  static const String myCards = '/api/cards/my';
  static const String myCardCollections = '/api/cards/collections';
  static const String cardsFeed = '/api/cards/feed';
  static String userCards(int userId) => '/api/cards/user/$userId';
  static String cardLike(int cardId) => '/api/cards/$cardId/like';
  static String cardCollect(int cardId) => '/api/cards/$cardId/collect';

  // XP
  static const String xpLevelInfo = '/api/xp/level-info';
  static const String xpDashboard = '/api/xp/dashboard';
  static const String xpHistory = '/api/xp/history';
  static const String xpBreakdown = '/api/xp/breakdown';
  static const String xpInsights = '/api/xp/insights';
  static const String xpRanks = '/api/xp/ranks';
  static String xpLeaderboard(String boardType) =>
      '/api/xp/leaderboard/$boardType';

  // Brands
  static const String brands = '/api/brands';
  static const String brandsSponsors = '/api/brands/sponsors';
  static String brandFavoriteToggle(int brandId) =>
      '/api/brands/$brandId/favorite';

  // Follow — toggle endpoint is GET, mirroring the web. POST returns 405.
  static String followToggle(int userId) => '/api/follow/$userId';
  static const String myFollowers = '/api/followers';
  static const String myFollowings = '/api/followings';
  static String userFollowers(int userId) => '/api/users/$userId/followers';
  static String userFollowings(int userId) => '/api/users/$userId/followings';

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
  static String pinPost(String postId) => '/api/newsfeed/$postId/pin';
  static String postCommentsToggle(String postId) =>
      '/api/newsfeed/$postId/comments-toggle';
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
  static const String gamesEquipmentAdd = '/api/games/equipment/add';
  static const String gamesEquipmentStats = '/api/games/equipment/stats';
  static String gamesEquipmentDelete(int ballId) =>
      '/api/games/equipment/$ballId/delete';
  static String gamesSessionDetail(String uid) =>
      '/api/games/sessions/$uid';
  static String gamesSessionDelete(String uid) =>
      '/api/games/sessions/$uid/delete';
  static String gamesSessionSubmitGame(String uid) =>
      '/api/games/sessions/$uid/submit-game';
  static String gamesSessionSubmitQuick(String uid) =>
      '/api/games/sessions/$uid/submit-quick';
  static String gamesSessionStartGame(String uid) =>
      '/api/games/sessions/$uid/start-game';
  static String gameDetail(int gameId) => '/api/games/$gameId';
  static String gameShared(int gameId) => '/api/games/shared/$gameId';
  static String gameFrameUpdate(int gameId, int frameNumber) =>
      '/api/games/$gameId/frames/$frameNumber';

  // Live broadcast (game-side livescore lifecycle).
  static const String liveStart = '/api/games/lives/start';
  static String liveEnd(int id) => '/api/games/lives/$id/end';
  static const String liveMyActive = '/api/games/lives/me/active';

  // Ball catalog (used by the ball picker modal).
  static const String ballsCatalog = '/api/balls';

  // Stats sub-resources (drives the analytics dashboard).
  static const String gamesStatsPinLeaves = '/api/games/stats/pin-leaves';
  static const String gamesStatsSpares = '/api/games/stats/spares';
  static const String gamesStatsTrends = '/api/games/stats/trends';
  static const String gamesStatsByCenter = '/api/games/stats/by-center';
  static const String gamesStatsByContext = '/api/games/stats/by-context';
  static const String gamesStatsFrames = '/api/games/stats/frames';
  static const String gamesStatsDistribution = '/api/games/stats/distribution';

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
  static String conversationMute(String uid) =>
      '/api/messages/conversations/$uid/mute';
  static String conversationLeave(String uid) =>
      '/api/messages/conversations/$uid/leave';
  static String conversationDeleteSelf(String uid) =>
      '/api/messages/conversations/$uid/delete';
  static String conversationUpdate(String uid) =>
      '/api/messages/conversations/$uid/update';
  static String conversationMembers(String uid) =>
      '/api/messages/conversations/$uid/members';
  static String conversationMemberRemove(String uid, int userId) =>
      '/api/messages/conversations/$uid/members/$userId';

  // User search (used by DM / group create + team invites)
  static const String usersSearch = '/api/users/search';

  // Universal search — central predictive search across all content types.
  // GET /api/search?q={query}&types={comma,separated,types}
  static const String search = '/api/search';

  // Chatter (discussions + opinions + topics).
  // NOTE: detail endpoint is path-templated on the UID (string), while all
  // mutating endpoints below use the numeric DB id returned in the detail
  // payload.
  static const String chatterTopics = '/api/chatter/topics';
  static const String chatterDiscussions = '/api/chatter/discussions';
  static String chatterDiscussion(String uid) =>
      '/api/chatter/discussions/$uid';
  static String chatterDiscussionUpvote(int id) =>
      '/api/chatter/discussions/$id/upvote';
  static String chatterDiscussionOpinions(int id) =>
      '/api/chatter/discussions/$id/opinions';
  static String chatterOpinionUpvote(int id) =>
      '/api/chatter/opinions/$id/upvote';
  static const String mediaVideos = '/api/media/videos';
  static const String mediaSplits = '/api/media/splits';
  static const String eventsFeed = '/api/events/feed';
  static const String eventsTypes = '/api/events/types';
  static const String eventsCreate = '/api/events';
  static const String eventsMy = '/api/events/my';
  static const String eventInvitationsList = '/api/events/invitations';
  static String eventDetail(String uid) => '/api/events/$uid';
  static String eventInterest(String uid) => '/api/events/$uid/interest';
  static String eventUpdate(String uid) => '/api/events/$uid/update';
  static String eventDelete(String uid) => '/api/events/$uid/delete';
  static String eventInterested(String uid) =>
      '/api/events/$uid/interested';
  static String eventGoing(String uid) => '/api/events/$uid/going';
  static String eventInvite(String uid) => '/api/events/$uid/invite';
  static String eventInviteDiscover(String uid) =>
      '/api/events/$uid/invite/discover';
  static String eventNotes(String uid) => '/api/events/$uid/notes';
  static String eventNoteReply(int noteId) =>
      '/api/events/notes/$noteId/reply';
  static String eventNoteDelete(int noteId) =>
      '/api/events/notes/$noteId/delete';
  static String eventInvitationRespond(int invitationId) =>
      '/api/events/invitations/$invitationId/respond';
  static const String gamesLives = '/api/games/lives';

  // Teams — every endpoint is auth-gated. /api/teams/my returns ALL teams
  // the viewer is a member of (creator or accepted invitee). Create / edit /
  // delete are creator-only. Invitation list returns BOTH received (to me)
  // and sent (by my created teams).
  static const String teamsMy = '/api/teams/my';
  static const String teamsCreate = '/api/teams';
  static const String teamsValidateName = '/api/teams/validate-name';
  static const String teamInvite = '/api/teams/invite';
  static const String teamInvitations = '/api/teams/invitations';
  static String teamDetail(int teamId) => '/api/teams/$teamId';
  static String teamLogo(int teamId) => '/api/teams/$teamId/logo';
  static String teamMembers(int teamId) => '/api/teams/$teamId/members';
  static String teamLeave(int teamId) => '/api/teams/$teamId/leave';
  static String teamMemberRemove(int teamId, int userId) =>
      '/api/teams/$teamId/members/$userId';
  static String teamMemberRole(int teamId, int userId) =>
      '/api/teams/$teamId/members/$userId/role';
  static String teamMemberJersey(int teamId, int userId) =>
      '/api/teams/$teamId/members/$userId/jersey';
  static String teamInvitationAccept(int invitationId) =>
      '/api/teams/invitations/$invitationId/accept';
  static String teamInvitationDecline(int invitationId) =>
      '/api/teams/invitations/$invitationId/decline';
  static String teamInvitationCancel(int invitationId) =>
      '/api/teams/invitations/$invitationId';

  // WebSocket paths (appended to ApiConstants.wsBaseUrl, token in query).
  static const String wsChat = '/ws/chat/';
  static const String wsNotifications = '/ws/notifications/';

  /// Live-broadcast WS for the broadcaster. Pass the numeric LiveScore id.
  /// Inbound events: `init`, `viewer_count`, `broadcast_ended`.
  static String wsLive(int livescoreId) => '/ws/live/$livescoreId/';
}

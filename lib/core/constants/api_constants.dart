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

  // Auth
  static const String verifyEmail = '/api/auth/verify-email';
  static const String signup = '/api/auth/signup';
  static const String login = '/api/auth/login';
  static const String prosLogin = '/api/auth/pros/login';
  static const String consentVerify = '/api/auth/consent/verify';
  static const String consentResend = '/api/auth/consent/resend';

  // Recovery
  static const String recoveryInitiateOtp = '/api/access/recovery/initiate/otp';
  static const String recoveryValidateOtp = '/api/access/recovery/validate/otp';
  static const String recoveryInitiateMagicLink = '/api/access/recovery/initiate/magic-link';
  static const String recoveryValidateMagicKey = '/api/access/recovery/validate/magic-key';
  static const String recoveryResetPassword = '/api/access/recovery/reset-password';

  // Profile
  static const String profile = '/api/profile';
  static const String profileCompletion = '/api/profile/completion';
  static const String profileGender = '/api/profile/gender';
  static const String profileBirthdate = '/api/profile/birthdate';
  static const String profileAddress = '/api/profile/address';
  static const String profileHomeCenter = '/api/profile/home-center';
  static const String profileBallHandlingStyle = '/api/profile/ball-handling-style';
  static const String profileBio = '/api/profile/bio';
  static const String profileNickname = '/api/profile/nickname';
  static const String profileCriticalInfo = '/api/profile/critical-info';
  static const String profileContactInfo = '/api/profile/contact-info';
  static const String profilePicture = '/api/profile/profile-picture';
  static const String profileCoverPicture = '/api/profile/cover-picture';
  static const String profileIntroVideo = '/api/profile/intro-video';
  static const String profileOfficialGameStat = '/api/profile/official-game-stat';
  static String profileByUsername(String username) => '/api/profile/$username';
  static String profileById(int userId) => '/api/profile/id/$userId';

  // Follow
  static String follow(int userId) => '/api/follow/$userId';
  static const String followers = '/api/followers';
  static const String followings = '/api/followings';

  // Referral
  static const String referralLink = '/api/referral/link';
  static const String myReferrals = '/api/referral/my-referrals';

  // Newsfeed
  static const String feed = '/api/newsfeed/feed';
  static const String createTextPost = '/api/newsfeed/create/text';
  static const String createPhotoPost = '/api/newsfeed/create/photo';
  static const String createVideoPost = '/api/newsfeed/create/video';
  static const String createScorePost = '/api/newsfeed/create/score';
  static const String createPollPost = '/api/newsfeed/create/poll';
  static String post(String postId) => '/api/newsfeed/$postId';
  static String postReact(String postId) => '/api/newsfeed/$postId/react';
  static String postReactions(String postId) => '/api/newsfeed/$postId/reactions';
  static String postSave(String postId) => '/api/newsfeed/$postId/save';
  static String postHide(String postId) => '/api/newsfeed/$postId/hide';
  static String postPin(String postId) => '/api/newsfeed/$postId/pin';
  static String postAudience(String postId) => '/api/newsfeed/$postId/audience';
  static String postCommentsToggle(String postId) => '/api/newsfeed/$postId/comments-toggle';
  static String postShare(String postId) => '/api/newsfeed/$postId/share';
  static String postComments(String postId) => '/api/newsfeed/$postId/comments';
  static String postVote(String postId) => '/api/newsfeed/$postId/vote';
  static String postClosePoll(String postId) => '/api/newsfeed/$postId/close-poll';
  static String postPublishResults(String postId) => '/api/newsfeed/$postId/publish-results';
  static String postPollAnalytics(String postId) => '/api/newsfeed/$postId/poll-analytics';
  static String editComment(String commentId) => '/api/newsfeed/comments/$commentId';
  static String likeComment(String commentId) => '/api/newsfeed/comments/$commentId/like';
  static String hideComment(String commentId) => '/api/newsfeed/comments/$commentId/hide';
  static String pinComment(String commentId) => '/api/newsfeed/comments/$commentId/pin';
  static const String myPosts = '/api/newsfeed/my-posts';
  static String userPosts(int userId) => '/api/newsfeed/users/$userId/posts';
  static const String savedPosts = '/api/newsfeed/saved';
  static const String hiddenPosts = '/api/newsfeed/hidden';

  // User Relationships
  static String blockUser(int userId) => '/api/users/$userId/block';
  static String muteUser(int userId) => '/api/users/$userId/mute';
  static String restrictUser(int userId) => '/api/users/$userId/restrict';

  // Chatter
  static const String chatterTopics = '/api/chatter/topics';
  static const String chatterDiscussions = '/api/chatter/discussions';
  static String chatterDiscussion(String id) => '/api/chatter/discussions/$id';
  static String chatterDiscussionLock(String id) => '/api/chatter/discussions/$id/lock';
  static String chatterDiscussionResolve(String id) => '/api/chatter/discussions/$id/resolve';
  static String chatterDiscussionPin(String id) => '/api/chatter/discussions/$id/pin';
  static String chatterDiscussionSave(String id) => '/api/chatter/discussions/$id/save';
  static String chatterDiscussionHide(String id) => '/api/chatter/discussions/$id/hide';
  static String chatterDiscussionUpvote(String id) => '/api/chatter/discussions/$id/upvote';
  static String chatterDiscussionDownvote(String id) => '/api/chatter/discussions/$id/downvote';
  static String chatterOpinions(String id) => '/api/chatter/discussions/$id/opinions';
  static String chatterOpinion(String id) => '/api/chatter/opinions/$id';
  static String chatterOpinionPin(String id) => '/api/chatter/opinions/$id/pin';
  static String chatterOpinionUpvote(String id) => '/api/chatter/opinions/$id/upvote';
  static String chatterOpinionDownvote(String id) => '/api/chatter/opinions/$id/downvote';
  static const String chatterCredibility = '/api/chatter/credibility';
  static const String chatterCredibilityLog = '/api/chatter/credibility/log';
  static const String myDiscussions = '/api/chatter/my-discussions';
  static const String myOpinions = '/api/chatter/my-opinions';
  static const String savedDiscussions = '/api/chatter/saved';
  static const String hiddenDiscussions = '/api/chatter/hidden';

  // Media - Videos
  static const String videos = '/api/media/videos';
  static const String createVideo = '/api/media/videos/create';
  static String video(String uid) => '/api/media/videos/$uid';
  static String videoLike(String uid) => '/api/media/videos/$uid/like';
  static String videoSave(String uid) => '/api/media/videos/$uid/save';
  static String videoHide(String uid) => '/api/media/videos/$uid/hide';
  static String videoPin(String uid) => '/api/media/videos/$uid/pin';
  static String videoAudience(String uid) => '/api/media/videos/$uid/audience';
  static String videoCommentsToggle(String uid) => '/api/media/videos/$uid/comments-toggle';
  static String videoView(String uid) => '/api/media/videos/$uid/view';
  static String videoComments(String uid) => '/api/media/videos/$uid/comments';

  // Media - Splits
  static const String splits = '/api/media/splits';
  static const String createSplit = '/api/media/splits/create';
  static String split(String uid) => '/api/media/splits/$uid';
  static String splitLike(String uid) => '/api/media/splits/$uid/like';
  static String splitSave(String uid) => '/api/media/splits/$uid/save';
  static String splitHide(String uid) => '/api/media/splits/$uid/hide';
  static String splitPin(String uid) => '/api/media/splits/$uid/pin';
  static String splitAudience(String uid) => '/api/media/splits/$uid/audience';
  static String splitCommentsToggle(String uid) => '/api/media/splits/$uid/comments-toggle';
  static String splitView(String uid) => '/api/media/splits/$uid/view';
  static String splitComments(String uid) => '/api/media/splits/$uid/comments';

  // Media - Comments
  static String mediaComment(String id) => '/api/media/comments/$id';
  static String mediaCommentLike(String id) => '/api/media/comments/$id/like';
  static String mediaCommentHide(String id) => '/api/media/comments/$id/hide';
  static String mediaCommentPin(String id) => '/api/media/comments/$id/pin';

  // Media - Libraries & Albums
  static const String libraries = '/api/media/libraries';
  static const String createLibrary = '/api/media/libraries/create';
  static String library(String uid) => '/api/media/libraries/$uid';
  static String userLibraries(int userId) => '/api/media/users/$userId/libraries';
  static const String gallery = '/api/media/gallery';
  static const String createAlbum = '/api/media/albums/create';
  static String album(String uid) => '/api/media/albums/$uid';
  static String albumLike(String uid) => '/api/media/albums/$uid/like';
  static String albumSave(String uid) => '/api/media/albums/$uid/save';
  static String albumHide(String uid) => '/api/media/albums/$uid/hide';
  static String albumAudience(String uid) => '/api/media/albums/$uid/audience';
  static String albumCommentsToggle(String uid) => '/api/media/albums/$uid/comments-toggle';
  static String albumView(String uid) => '/api/media/albums/$uid/view';
  static String albumMove(String uid) => '/api/media/albums/$uid/move';
  static String albumReorder(String uid) => '/api/media/albums/$uid/reorder';
  static String albumComments(String uid) => '/api/media/albums/$uid/comments';

  // Media - Images
  static const String images = '/api/media/images';
  static const String imagesBatch = '/api/media/images/batch';
  static String image(String uid) => '/api/media/images/$uid';
  static String imageLike(String uid) => '/api/media/images/$uid/like';
  static String imageMove(String uid) => '/api/media/images/$uid/move';
  static String imageComments(String uid) => '/api/media/images/$uid/comments';

  // Media - Channel
  static String channel(int userId) => '/api/media/channel/$userId';
  static String channelVideos(int userId) => '/api/media/channel/$userId/videos';
  static String channelSplits(int userId) => '/api/media/channel/$userId/splits';
  static String channelGallery(int userId) => '/api/media/channel/$userId/gallery';

  // Media - User Content
  static const String myVideos = '/api/media/my-videos';
  static const String mySplits = '/api/media/my-splits';
  static const String myAlbums = '/api/media/my-albums';
  static const String savedMedia = '/api/media/saved';
  static const String hiddenMedia = '/api/media/hidden';

  // Cards
  static const String cardDesigns = '/api/cards/designs';
  static String cardDesignTemplate(String designId) => '/api/cards/designs/$designId/template';
  static const String createCard = '/api/cards/create';
  static const String myCards = '/api/cards/my';
  static const String cardsFeed = '/api/cards/feed';
  static String userCards(int userId) => '/api/cards/user/$userId';
  static String deleteCard(String cardId) => '/api/cards/$cardId';
  static String cardLike(String cardId) => '/api/cards/$cardId/like';
  static String cardCollect(String cardId) => '/api/cards/$cardId/collect';
  static String cardCollectors(String cardId) => '/api/cards/$cardId/collectors';

  // Brands
  static const String brands = '/api/brands';
  static const String brandSponsors = '/api/brands/sponsors';
  static String brandFavorite(String brandId) => '/api/brands/$brandId/favorite';

  // Centers
  static const String centers = '/api/centers';

  // Events
  static const String eventTypes = '/api/events/types';
  static const String events = '/api/events';
  static const String myEvents = '/api/events/my';
  static String event(String uid) => '/api/events/$uid';
  static String eventInterest(String uid) => '/api/events/$uid/interest';
  static String eventInterested(String uid) => '/api/events/$uid/interested';
  static String eventGoing(String uid) => '/api/events/$uid/going';
  static String eventInvite(String uid) => '/api/events/$uid/invite';
  static String eventInviteDiscover(String uid) => '/api/events/$uid/invite/discover';
  static const String eventInvitations = '/api/events/invitations';
  static String eventInvitationRespond(String id) => '/api/events/invitations/$id/respond';
  static String eventNotes(String uid) => '/api/events/$uid/notes';
  static String eventNoteReply(String noteId) => '/api/events/notes/$noteId/reply';
  static String eventNoteDelete(String noteId) => '/api/events/notes/$noteId';
  static const String eventCalendar = '/api/events/calendar';
  static String eventCalendarDate(String date) => '/api/events/calendar/$date';
  static const String eventsNearby = '/api/events/nearby';

  // Games
  static const String gameSessions = '/api/games/sessions';
  static String gameSession(String uid) => '/api/games/sessions/$uid';
  static String addGame(String sessionUid) => '/api/games/sessions/$sessionUid/games';
  static String game(String gameId) => '/api/games/$gameId';
  static String gameFrames(String gameId) => '/api/games/$gameId/frames';
  static String gameFrame(String gameId, int frameNumber) => '/api/games/$gameId/frames/$frameNumber';
  static const String equipment = '/api/games/equipment';
  static String equipmentItem(String ballId) => '/api/games/equipment/$ballId';
  static const String gameStats = '/api/games/stats';
  static const String gameStatsPinLeaves = '/api/games/stats/pin-leaves';
  static const String gameStatsSpares = '/api/games/stats/spares';
  static const String gameStatsTrends = '/api/games/stats/trends';
  static const String gameStatsByCenter = '/api/games/stats/by-center';
  static const String gameStatsByContext = '/api/games/stats/by-context';
  static const String gameStatsFrames = '/api/games/stats/frames';
  static const String gameStatsSessionTrends = '/api/games/stats/session-trends';

  // Notifications
  static const String notifications = '/api/notifications';
  static const String notificationsUnreadCount = '/api/notifications/unread-count';
  static String notificationRead(String id) => '/api/notifications/$id/read';
  static const String notificationsReadAll = '/api/notifications/read-all';
  static String notificationDelete(String id) => '/api/notifications/$id';
  static const String notificationsClearAll = '/api/notifications/clear-all';
  static const String notificationPreferences = '/api/notifications/preferences';
  static const String notificationSubscribe = '/api/notifications/subscribe';
  static const String notificationUnsubscribe = '/api/notifications/unsubscribe';
  static const String deviceRegister = '/api/notifications/devices/register';
  static const String deviceUnregister = '/api/notifications/devices/unregister';

  // Messages
  static const String conversations = '/api/messages/conversations';
  static const String createConversation = '/api/messages/conversations/create';
  static String conversation(String uid) => '/api/messages/conversations/$uid';
  static String conversationMembers(String uid) => '/api/messages/conversations/$uid/members';
  static String conversationRemoveMember(String uid, int userId) =>
      '/api/messages/conversations/$uid/members/$userId';
  static String conversationLeave(String uid) => '/api/messages/conversations/$uid/leave';
  static String conversationMute(String uid) => '/api/messages/conversations/$uid/mute';
  static String conversationMessages(String uid) => '/api/messages/conversations/$uid/messages';
  static String conversationRead(String uid) => '/api/messages/conversations/$uid/read';
  static String deleteMessage(String uid) => '/api/messages/$uid';

  // Teams
  static const String myTeams = '/api/teams/my';
  static const String teams = '/api/teams';
  static String team(String teamId) => '/api/teams/$teamId';
  static String teamMembers(String teamId) => '/api/teams/$teamId/members';
  static String teamRemoveMember(String teamId, int userId) => '/api/teams/$teamId/members/$userId';
  static String teamLeave(String teamId) => '/api/teams/$teamId/leave';
  static String teamLogo(String teamId) => '/api/teams/$teamId/logo';
  static const String teamInvite = '/api/teams/invite';
  static const String teamInvitations = '/api/teams/invitations';
  static String teamInvitationAccept(String id) => '/api/teams/invitations/$id/accept';
  static String teamInvitationDecline(String id) => '/api/teams/invitations/$id/decline';
  static String teamInvitationCancel(String id) => '/api/teams/invitations/$id';

  // XP
  static const String xpDashboard = '/api/xp/dashboard';
  static const String xpHistory = '/api/xp/history';
  static const String xpBreakdown = '/api/xp/breakdown';
  static const String xpLevelInfo = '/api/xp/level-info';
  static String xpLeaderboard(String boardType) => '/api/xp/leaderboard/$boardType';
  static const String xpRanks = '/api/xp/ranks';

  // Dashboard
  static const String dashboardOverview = '/api/dashboard/overview';
  static const String dashboardSocial = '/api/dashboard/overview/social';
  static const String dashboardContent = '/api/dashboard/overview/content';
  static const String dashboardActivity = '/api/dashboard/overview/activity';
  static const String dashboardXp = '/api/dashboard/xp';
  static const String dashboardXpHistory = '/api/dashboard/xp/history';
  static const String dashboardGames = '/api/dashboard/games';
  static const String dashboardGamesTrends = '/api/dashboard/games/trends';
  static const String dashboardGamesReport = '/api/dashboard/games/report';

  // Search
  static const String search = '/api/search';
  static const String searchUsers = '/api/search/users';
  static const String searchPosts = '/api/search/posts';
  static const String searchDiscussions = '/api/search/discussions';
  static const String searchCenters = '/api/search/centers';
  static const String searchBrands = '/api/search/brands';
  static const String searchEvents = '/api/search/events';

  // Cloud Upload
  static const String uploadSinglepart = '/api/cloud/upload/singlepart/requests/initiate';
  static const String uploadMultipartInitiate = '/api/cloud/upload/multipart/requests/initiate';
  static const String uploadMultipartPresignedUrl = '/api/cloud/upload/multipart/requests/presigned-url';
  static const String uploadMultipartComplete = '/api/cloud/upload/multipart/requests/complete';
  static const String uploadMultipartAbort = '/api/cloud/upload/multipart/requests/abort';
  static const String uploadKey = '/api/cloud/upload/requests/key';
  static const String uploadPresignedUrl = '/api/cloud/upload/requests/presigned-url';
  static const String uploadPublicUrl = '/api/cloud/upload/requests/public-url';

  // Reporting
  static const String report = '/api/report';
  static const String appeals = '/api/appeals';

  // WebSocket
  static const String wsChat = '/ws/chat/';
  static const String wsNotifications = '/ws/notifications/';
}

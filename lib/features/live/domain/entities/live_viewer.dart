import 'package:equatable/equatable.dart';

/// The 6 reaction emojis a viewer can drop on a broadcast. Backend
/// enum is closed (adding a new type requires a deploy), so we model
/// it as an enum and treat unknown server values as null.
enum LiveReactionType {
  like('like', '👍'),
  fire('fire', '🔥'),
  strike('strike', '🎳'),
  clap('clap', '👏'),
  wow('wow', '😮'),
  haha('haha', '😂');

  const LiveReactionType(this.wire, this.emoji);
  final String wire;
  final String emoji;

  static LiveReactionType? fromWire(String? value) {
    if (value == null) return null;
    for (final r in LiveReactionType.values) {
      if (r.wire == value) return r;
    }
    return null;
  }
}

enum LiveStatus {
  active('active'),
  ended('ended');

  const LiveStatus(this.wire);
  final String wire;

  static LiveStatus fromWire(String? value) {
    if (value == 'ended') return LiveStatus.ended;
    return LiveStatus.active;
  }
}

enum LiveEndReason {
  none(''),
  manual('manual'),
  idleTimeout('idle_timeout');

  const LiveEndReason(this.wire);
  final String wire;

  static LiveEndReason fromWire(String? value) {
    return switch (value) {
      'manual' => LiveEndReason.manual,
      'idle_timeout' => LiveEndReason.idleTimeout,
      _ => LiveEndReason.none,
    };
  }

  String get label => switch (this) {
        LiveEndReason.manual => 'Broadcaster ended the stream.',
        LiveEndReason.idleTimeout => 'Broadcast timed out from inactivity.',
        LiveEndReason.none => 'This broadcast has ended.',
      };
}

/// Slim broadcaster shape used by both the list cards and the detail
/// header. Mirrors `LiveScoreUserBrief` on the web.
class LiveBroadcastUser extends Equatable {
  const LiveBroadcastUser({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.level,
    this.rankDisplay,
    this.badgeIconUrl,
    this.isFollowing,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final bool isPro;
  final int? level;
  final String? rankDisplay;
  final String? badgeIconUrl;
  final bool? isFollowing;

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? username : full;
  }

  @override
  List<Object?> get props => [
        id,
        username,
        firstName,
        lastName,
        profilePictureUrl,
        isPro,
        level,
        rankDisplay,
        badgeIconUrl,
        isFollowing,
      ];
}

/// One card on the /live list. Lightweight subset of [LiveBroadcastDetail].
class LiveBroadcastListItem extends Equatable {
  const LiveBroadcastListItem({
    required this.id,
    required this.uid,
    this.title = '',
    this.status = LiveStatus.active,
    this.viewerCount = 0,
    this.viewerPeak = 0,
    this.reactionsCount = 0,
    this.commentsCount = 0,
    this.startedAt,
    this.user,
  });

  final int id;
  final String uid;
  final String title;
  final LiveStatus status;
  final int viewerCount;
  final int viewerPeak;
  final int reactionsCount;
  final int commentsCount;
  final DateTime? startedAt;
  final LiveBroadcastUser? user;

  bool get isActive => status == LiveStatus.active;

  @override
  List<Object?> get props => [
        id,
        uid,
        title,
        status,
        viewerCount,
        viewerPeak,
        reactionsCount,
        commentsCount,
        startedAt,
        user,
      ];
}

/// Single frame inside a live game. Mirrors web's loose
/// `{frame_number, ball_*_pins_standing, is_strike, is_spare, frame_score}`.
/// Server may omit fields for not-yet-bowled frames; we leave defaults.
class LiveGameFrame extends Equatable {
  const LiveGameFrame({
    required this.frameNumber,
    this.isStrike = false,
    this.isSpare = false,
    this.pinfall,
    this.frameScore,
    this.ball1PinsStanding,
    this.ball2PinsStanding,
    this.ball3PinsStanding,
  });

  final int frameNumber;
  final bool isStrike;
  final bool isSpare;

  /// Pinfall for this frame so far. Null = not yet bowled.
  final int? pinfall;

  /// Running game total at this frame; null = pending bonus resolution.
  final int? frameScore;

  /// Pin numbers (1-10) STILL STANDING after each ball — backend stores
  /// these as JSON lists. Empty list after ball 1 = strike. `null` =
  /// that ball wasn't thrown yet (or the frame hasn't been bowled).
  final List<int>? ball1PinsStanding;
  final List<int>? ball2PinsStanding;
  final List<int>? ball3PinsStanding;

  bool get hasBeenBowled =>
      (ball1PinsStanding != null && ball1PinsStanding!.length < 10) ||
      isStrike ||
      isSpare ||
      pinfall != null ||
      frameScore != null;

  @override
  List<Object?> get props => [
        frameNumber,
        isStrike,
        isSpare,
        pinfall,
        frameScore,
        ball1PinsStanding,
        ball2PinsStanding,
        ball3PinsStanding,
      ];
}

/// Single game inside a live session. The detail endpoint may return
/// multiple games (one per game number); frame_update events replace
/// a single game in-place.
class LiveGame extends Equatable {
  const LiveGame({
    required this.id,
    required this.gameNumber,
    this.totalScore = 0,
    this.isComplete = false,
    this.frames = const [],
  });

  final int id;
  final int gameNumber;
  final int totalScore;
  final bool isComplete;
  final List<LiveGameFrame> frames;

  LiveGame copyWith({
    int? totalScore,
    bool? isComplete,
    List<LiveGameFrame>? frames,
  }) =>
      LiveGame(
        id: id,
        gameNumber: gameNumber,
        totalScore: totalScore ?? this.totalScore,
        isComplete: isComplete ?? this.isComplete,
        frames: frames ?? this.frames,
      );

  @override
  List<Object?> get props => [id, gameNumber, totalScore, isComplete, frames];
}

class LiveSession extends Equatable {
  const LiveSession({this.uid = '', this.games = const []});
  final String uid;
  final List<LiveGame> games;
  @override
  List<Object?> get props => [uid, games];
}

/// Full detail payload for /live/:uid. Carries everything the viewer
/// screen needs in one round-trip; WebSocket events mutate sub-fields
/// in place.
class LiveBroadcastDetail extends Equatable {
  const LiveBroadcastDetail({
    required this.id,
    required this.uid,
    this.title = '',
    this.status = LiveStatus.active,
    this.endReason = LiveEndReason.none,
    this.viewerCount = 0,
    this.viewerPeak = 0,
    this.reactionsCount = 0,
    this.commentsCount = 0,
    this.invitesCount = 0,
    this.streamedMinutes = 0,
    this.startedAt,
    this.endedAt,
    this.lastFrameAt,
    this.sharePostUid,
    this.user,
    this.isOwner = false,
    this.myReaction,
    this.reactionSummary = const {},
    this.session = const LiveSession(),
  });

  final int id;
  final String uid;
  final String title;
  final LiveStatus status;
  final LiveEndReason endReason;
  final int viewerCount;
  final int viewerPeak;
  final int reactionsCount;
  final int commentsCount;
  final int invitesCount;
  final int streamedMinutes;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime? lastFrameAt;
  final String? sharePostUid;
  final LiveBroadcastUser? user;
  final bool isOwner;
  final LiveReactionType? myReaction;

  /// reaction_type wire → count (sparse: only present types appear).
  final Map<String, int> reactionSummary;

  final LiveSession session;

  bool get isActive => status == LiveStatus.active;

  LiveBroadcastDetail copyWith({
    LiveStatus? status,
    LiveEndReason? endReason,
    int? viewerCount,
    int? reactionsCount,
    int? commentsCount,
    DateTime? endedAt,
    LiveReactionType? myReaction,
    bool clearMyReaction = false,
    Map<String, int>? reactionSummary,
    LiveSession? session,
  }) =>
      LiveBroadcastDetail(
        id: id,
        uid: uid,
        title: title,
        status: status ?? this.status,
        endReason: endReason ?? this.endReason,
        viewerCount: viewerCount ?? this.viewerCount,
        viewerPeak: viewerPeak,
        reactionsCount: reactionsCount ?? this.reactionsCount,
        commentsCount: commentsCount ?? this.commentsCount,
        invitesCount: invitesCount,
        streamedMinutes: streamedMinutes,
        startedAt: startedAt,
        endedAt: endedAt ?? this.endedAt,
        lastFrameAt: lastFrameAt,
        sharePostUid: sharePostUid,
        user: user,
        isOwner: isOwner,
        myReaction: clearMyReaction ? null : (myReaction ?? this.myReaction),
        reactionSummary: reactionSummary ?? this.reactionSummary,
        session: session ?? this.session,
      );

  @override
  List<Object?> get props => [
        id,
        uid,
        title,
        status,
        endReason,
        viewerCount,
        viewerPeak,
        reactionsCount,
        commentsCount,
        invitesCount,
        streamedMinutes,
        startedAt,
        endedAt,
        lastFrameAt,
        sharePostUid,
        user,
        isOwner,
        myReaction,
        reactionSummary,
        session,
      ];
}

/// One comment row on a live broadcast.
class LiveBroadcastComment extends Equatable {
  const LiveBroadcastComment({
    required this.id,
    required this.body,
    required this.createdAt,
    this.user,
  });

  final int id;
  final String body;
  final DateTime createdAt;
  final LiveBroadcastUser? user;

  @override
  List<Object?> get props => [id, body, createdAt, user];
}

/// Paginated comments page — `nextCursorId` is null when there are no
/// older comments left.
class LiveCommentsPage extends Equatable {
  const LiveCommentsPage({
    this.comments = const [],
    this.nextCursorId,
  });
  final List<LiveBroadcastComment> comments;
  final int? nextCursorId;
  @override
  List<Object?> get props => [comments, nextCursorId];
}

/// Available list-page filters.
enum LiveListScope {
  all('all', 'All'),
  following('following', 'Following');

  const LiveListScope(this.wire, this.label);
  final String wire;
  final String label;
}

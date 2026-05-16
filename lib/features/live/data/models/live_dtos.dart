import 'package:json_annotation/json_annotation.dart';

part 'live_dtos.g.dart';

/// Response from `POST /api/games/lives/start` and the `active` payload of
/// `GET /api/games/lives/me/active`.
@JsonSerializable(createToJson: false)
class LiveBroadcastDto {
  const LiveBroadcastDto({
    required this.id,
    required this.uid,
    this.title = '',
    this.viewerCount = 0,
    this.sessionUid,
    this.currentGame,
  });

  final int id;
  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(name: 'viewer_count', defaultValue: 0)
  final int viewerCount;
  @JsonKey(name: 'session_uid')
  final String? sessionUid;
  @JsonKey(name: 'current_game')
  final LiveCurrentGameDto? currentGame;

  factory LiveBroadcastDto.fromJson(Map<String, dynamic> json) =>
      _$LiveBroadcastDtoFromJson(json);
}

/// `current_game` nested object — when broadcasting, every per-frame PUT
/// targets this game id.
@JsonSerializable(createToJson: false)
class LiveCurrentGameDto {
  const LiveCurrentGameDto({required this.id, this.gameNumber = 1});

  final int id;
  @JsonKey(name: 'game_number', defaultValue: 1)
  final int gameNumber;

  factory LiveCurrentGameDto.fromJson(Map<String, dynamic> json) =>
      _$LiveCurrentGameDtoFromJson(json);
}

/// Wrapper for `GET /api/games/lives/me/active` — body is `{active: {...}|null}`.
@JsonSerializable(createToJson: false)
class LiveMyActiveDto {
  const LiveMyActiveDto({this.active});

  final LiveBroadcastDto? active;

  factory LiveMyActiveDto.fromJson(Map<String, dynamic> json) =>
      _$LiveMyActiveDtoFromJson(json);
}

// ─────────────────────────────────────────────────────────────────────────────
// Viewer-side DTOs (list + detail + comments + reactions)
// ─────────────────────────────────────────────────────────────────────────────

/// Slim broadcaster shape — mirrors `LiveScoreUserBrief` on the web.
@JsonSerializable(createToJson: false)
class LiveBroadcastUserDto {
  const LiveBroadcastUserDto({
    this.id = 0,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.level,
    this.rankDisplay,
    this.badgeIconUrl,
    this.isFollowing,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String username;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'is_pro', defaultValue: false)
  final bool isPro;
  final int? level;
  @JsonKey(name: 'rank_display')
  final String? rankDisplay;
  @JsonKey(name: 'badge_icon_url')
  final String? badgeIconUrl;
  @JsonKey(name: 'is_following')
  final bool? isFollowing;

  factory LiveBroadcastUserDto.fromJson(Map<String, dynamic> json) =>
      _$LiveBroadcastUserDtoFromJson(json);
}

/// One frame inside a live game. Most fields optional because the
/// backend omits them for not-yet-bowled frames. The `ball_*_pins_standing`
/// arrays are lists of pin numbers (1-10) still upright after each ball.
@JsonSerializable(createToJson: false)
class LiveGameFrameDto {
  const LiveGameFrameDto({
    this.frameNumber = 0,
    this.isStrike = false,
    this.isSpare = false,
    this.pinfall,
    this.frameScore,
    this.ball1PinsStanding,
    this.ball2PinsStanding,
    this.ball3PinsStanding,
  });

  @JsonKey(name: 'frame_number', defaultValue: 0)
  final int frameNumber;
  @JsonKey(name: 'is_strike', defaultValue: false)
  final bool isStrike;
  @JsonKey(name: 'is_spare', defaultValue: false)
  final bool isSpare;
  final int? pinfall;
  @JsonKey(name: 'frame_score')
  final int? frameScore;

  /// Pin numbers (1-10) still standing after the first ball. Empty
  /// list = strike (all pins down). Backend type is JSONField default=list,
  /// so this is always present for bowled frames.
  @JsonKey(name: 'ball_1_pins_standing')
  final List<int>? ball1PinsStanding;
  @JsonKey(name: 'ball_2_pins_standing')
  final List<int>? ball2PinsStanding;
  @JsonKey(name: 'ball_3_pins_standing')
  final List<int>? ball3PinsStanding;

  factory LiveGameFrameDto.fromJson(Map<String, dynamic> json) =>
      _$LiveGameFrameDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class LiveGameDto {
  const LiveGameDto({
    this.id = 0,
    this.gameNumber = 1,
    this.totalScore = 0,
    this.isComplete = false,
    this.frames = const [],
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(name: 'game_number', defaultValue: 1)
  final int gameNumber;
  @JsonKey(name: 'total_score', defaultValue: 0)
  final int totalScore;
  @JsonKey(name: 'is_complete', defaultValue: false)
  final bool isComplete;
  @JsonKey(defaultValue: <LiveGameFrameDto>[])
  final List<LiveGameFrameDto> frames;

  factory LiveGameDto.fromJson(Map<String, dynamic> json) =>
      _$LiveGameDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class LiveSessionDto {
  const LiveSessionDto({this.uid = '', this.games = const []});
  @JsonKey(defaultValue: '')
  final String uid;
  @JsonKey(defaultValue: <LiveGameDto>[])
  final List<LiveGameDto> games;
  factory LiveSessionDto.fromJson(Map<String, dynamic> json) =>
      _$LiveSessionDtoFromJson(json);
}

/// One row from `GET /api/games/lives`.
@JsonSerializable(createToJson: false)
class LiveBroadcastListItemDto {
  const LiveBroadcastListItemDto({
    this.id = 0,
    this.uid = '',
    this.title = '',
    this.status = 'active',
    this.viewerCount = 0,
    this.viewerPeak = 0,
    this.reactionsCount = 0,
    this.commentsCount = 0,
    this.startedAt,
    this.user,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: 'active')
  final String status;
  @JsonKey(name: 'viewer_count', defaultValue: 0)
  final int viewerCount;
  @JsonKey(name: 'viewer_peak', defaultValue: 0)
  final int viewerPeak;
  @JsonKey(name: 'reactions_count', defaultValue: 0)
  final int reactionsCount;
  @JsonKey(name: 'comments_count', defaultValue: 0)
  final int commentsCount;
  @JsonKey(name: 'started_at')
  final String? startedAt;
  final LiveBroadcastUserDto? user;

  factory LiveBroadcastListItemDto.fromJson(Map<String, dynamic> json) =>
      _$LiveBroadcastListItemDtoFromJson(json);
}

/// Cursor-paginated list response.
@JsonSerializable(createToJson: false)
class LiveBroadcastListDto {
  const LiveBroadcastListDto({
    this.results = const [],
    this.nextCursorId,
  });
  @JsonKey(defaultValue: <LiveBroadcastListItemDto>[])
  final List<LiveBroadcastListItemDto> results;
  @JsonKey(name: 'next_cursor_id')
  final int? nextCursorId;

  factory LiveBroadcastListDto.fromJson(Map<String, dynamic> json) =>
      _$LiveBroadcastListDtoFromJson(json);
}

/// `GET /api/games/lives/{id}` or `/by-uid/{uid}` — full detail.
@JsonSerializable(createToJson: false)
class LiveBroadcastDetailDto {
  const LiveBroadcastDetailDto({
    this.id = 0,
    this.uid = '',
    this.title = '',
    this.status = 'active',
    this.endReason = '',
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
    this.session,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String uid;
  @JsonKey(defaultValue: '')
  final String title;
  @JsonKey(defaultValue: 'active')
  final String status;
  @JsonKey(name: 'end_reason', defaultValue: '')
  final String endReason;
  @JsonKey(name: 'viewer_count', defaultValue: 0)
  final int viewerCount;
  @JsonKey(name: 'viewer_peak', defaultValue: 0)
  final int viewerPeak;
  @JsonKey(name: 'reactions_count', defaultValue: 0)
  final int reactionsCount;
  @JsonKey(name: 'comments_count', defaultValue: 0)
  final int commentsCount;
  @JsonKey(name: 'invites_count', defaultValue: 0)
  final int invitesCount;
  @JsonKey(name: 'streamed_minutes', defaultValue: 0)
  final int streamedMinutes;
  @JsonKey(name: 'started_at')
  final String? startedAt;
  @JsonKey(name: 'ended_at')
  final String? endedAt;
  @JsonKey(name: 'last_frame_at')
  final String? lastFrameAt;
  @JsonKey(name: 'share_post_uid')
  final String? sharePostUid;
  final LiveBroadcastUserDto? user;
  @JsonKey(name: 'is_owner', defaultValue: false)
  final bool isOwner;
  @JsonKey(name: 'my_reaction')
  final String? myReaction;
  @JsonKey(name: 'reaction_summary', defaultValue: <String, int>{})
  final Map<String, int> reactionSummary;
  final LiveSessionDto? session;

  factory LiveBroadcastDetailDto.fromJson(Map<String, dynamic> json) =>
      _$LiveBroadcastDetailDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class LiveCommentDto {
  const LiveCommentDto({
    this.id = 0,
    this.body = '',
    this.createdAt,
    this.user,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String body;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  final LiveBroadcastUserDto? user;

  factory LiveCommentDto.fromJson(Map<String, dynamic> json) =>
      _$LiveCommentDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class LiveCommentsPageDto {
  const LiveCommentsPageDto({
    this.results = const [],
    this.nextCursorId,
  });
  @JsonKey(defaultValue: <LiveCommentDto>[])
  final List<LiveCommentDto> results;
  @JsonKey(name: 'next_cursor_id')
  final int? nextCursorId;

  factory LiveCommentsPageDto.fromJson(Map<String, dynamic> json) =>
      _$LiveCommentsPageDtoFromJson(json);
}

/// Reaction toggle response. `created=true` when a fresh row was inserted,
/// false when the type changed for an existing row.
@JsonSerializable(createToJson: false)
class LiveReactionAckDto {
  const LiveReactionAckDto({this.reactionType, this.created = false});
  @JsonKey(name: 'reaction_type')
  final String? reactionType;
  @JsonKey(defaultValue: false)
  final bool created;

  factory LiveReactionAckDto.fromJson(Map<String, dynamic> json) =>
      _$LiveReactionAckDtoFromJson(json);
}

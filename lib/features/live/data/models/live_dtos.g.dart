// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveBroadcastDto _$LiveBroadcastDtoFromJson(Map<String, dynamic> json) =>
    LiveBroadcastDto(
      id: (json['id'] as num).toInt(),
      uid: json['uid'] as String,
      title: json['title'] as String? ?? '',
      viewerCount: (json['viewer_count'] as num?)?.toInt() ?? 0,
      sessionUid: json['session_uid'] as String?,
      currentGame: json['current_game'] == null
          ? null
          : LiveCurrentGameDto.fromJson(
              json['current_game'] as Map<String, dynamic>,
            ),
    );

LiveCurrentGameDto _$LiveCurrentGameDtoFromJson(Map<String, dynamic> json) =>
    LiveCurrentGameDto(
      id: (json['id'] as num).toInt(),
      gameNumber: (json['game_number'] as num?)?.toInt() ?? 1,
    );

LiveMyActiveDto _$LiveMyActiveDtoFromJson(Map<String, dynamic> json) =>
    LiveMyActiveDto(
      active: json['active'] == null
          ? null
          : LiveBroadcastDto.fromJson(json['active'] as Map<String, dynamic>),
    );

LiveBroadcastUserDto _$LiveBroadcastUserDtoFromJson(
  Map<String, dynamic> json,
) => LiveBroadcastUserDto(
  id: (json['id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  firstName: json['first_name'] as String? ?? '',
  lastName: json['last_name'] as String? ?? '',
  profilePictureUrl: json['profile_picture_url'] as String?,
  isPro: json['is_pro'] as bool? ?? false,
  level: (json['level'] as num?)?.toInt(),
  rankDisplay: json['rank_display'] as String?,
  badgeIconUrl: json['badge_icon_url'] as String?,
  isFollowing: json['is_following'] as bool?,
);

LiveGameFrameDto _$LiveGameFrameDtoFromJson(Map<String, dynamic> json) =>
    LiveGameFrameDto(
      frameNumber: (json['frame_number'] as num?)?.toInt() ?? 0,
      isStrike: json['is_strike'] as bool? ?? false,
      isSpare: json['is_spare'] as bool? ?? false,
      pinfall: (json['pinfall'] as num?)?.toInt(),
      frameScore: (json['frame_score'] as num?)?.toInt(),
      ball1PinsStanding: (json['ball_1_pins_standing'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      ball2PinsStanding: (json['ball_2_pins_standing'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      ball3PinsStanding: (json['ball_3_pins_standing'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

LiveGameDto _$LiveGameDtoFromJson(Map<String, dynamic> json) => LiveGameDto(
  id: (json['id'] as num?)?.toInt() ?? 0,
  gameNumber: (json['game_number'] as num?)?.toInt() ?? 1,
  totalScore: (json['total_score'] as num?)?.toInt() ?? 0,
  isComplete: json['is_complete'] as bool? ?? false,
  frames:
      (json['frames'] as List<dynamic>?)
          ?.map((e) => LiveGameFrameDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

LiveSessionDto _$LiveSessionDtoFromJson(Map<String, dynamic> json) =>
    LiveSessionDto(
      uid: json['uid'] as String? ?? '',
      games:
          (json['games'] as List<dynamic>?)
              ?.map((e) => LiveGameDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

LiveBroadcastListItemDto _$LiveBroadcastListItemDtoFromJson(
  Map<String, dynamic> json,
) => LiveBroadcastListItemDto(
  id: (json['id'] as num?)?.toInt() ?? 0,
  uid: json['uid'] as String? ?? '',
  title: json['title'] as String? ?? '',
  status: json['status'] as String? ?? 'active',
  viewerCount: (json['viewer_count'] as num?)?.toInt() ?? 0,
  viewerPeak: (json['viewer_peak'] as num?)?.toInt() ?? 0,
  reactionsCount: (json['reactions_count'] as num?)?.toInt() ?? 0,
  commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
  startedAt: json['started_at'] as String?,
  user: json['user'] == null
      ? null
      : LiveBroadcastUserDto.fromJson(json['user'] as Map<String, dynamic>),
);

LiveBroadcastListDto _$LiveBroadcastListDtoFromJson(
  Map<String, dynamic> json,
) => LiveBroadcastListDto(
  entries:
      (json['entries'] as List<dynamic>?)
          ?.map(
            (e) => LiveBroadcastListItemDto.fromJson(e as Map<String, dynamic>),
          )
          .toList() ??
      [],
  nextCursorId: (json['next_cursor'] as num?)?.toInt(),
);

LiveBroadcastDetailDto _$LiveBroadcastDetailDtoFromJson(
  Map<String, dynamic> json,
) => LiveBroadcastDetailDto(
  id: (json['id'] as num?)?.toInt() ?? 0,
  uid: json['uid'] as String? ?? '',
  title: json['title'] as String? ?? '',
  status: json['status'] as String? ?? 'active',
  endReason: json['end_reason'] as String? ?? '',
  viewerCount: (json['viewer_count'] as num?)?.toInt() ?? 0,
  viewerPeak: (json['viewer_peak'] as num?)?.toInt() ?? 0,
  reactionsCount: (json['reactions_count'] as num?)?.toInt() ?? 0,
  commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
  invitesCount: (json['invites_count'] as num?)?.toInt() ?? 0,
  streamedMinutes: (json['streamed_minutes'] as num?)?.toInt() ?? 0,
  startedAt: json['started_at'] as String?,
  endedAt: json['ended_at'] as String?,
  lastFrameAt: json['last_frame_at'] as String?,
  sharePostUid: json['share_post_uid'] as String?,
  user: json['user'] == null
      ? null
      : LiveBroadcastUserDto.fromJson(json['user'] as Map<String, dynamic>),
  isOwner: json['is_owner'] as bool? ?? false,
  myReaction: json['my_reaction'] as String?,
  reactionSummary:
      (json['reaction_summary'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      {},
  session: json['session'] == null
      ? null
      : LiveSessionDto.fromJson(json['session'] as Map<String, dynamic>),
);

LiveCommentDto _$LiveCommentDtoFromJson(Map<String, dynamic> json) =>
    LiveCommentDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      body: json['body'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      user: json['user'] == null
          ? null
          : LiveBroadcastUserDto.fromJson(json['user'] as Map<String, dynamic>),
    );

LiveCommentsPageDto _$LiveCommentsPageDtoFromJson(Map<String, dynamic> json) =>
    LiveCommentsPageDto(
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map((e) => LiveCommentDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextCursorId: (json['next_cursor'] as num?)?.toInt(),
    );

LiveReactionAckDto _$LiveReactionAckDtoFromJson(Map<String, dynamic> json) =>
    LiveReactionAckDto(
      reactionType: json['reaction_type'] as String?,
      created: json['created'] as bool? ?? false,
    );

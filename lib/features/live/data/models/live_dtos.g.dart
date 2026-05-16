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

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

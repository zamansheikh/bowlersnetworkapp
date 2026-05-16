import 'package:json_annotation/json_annotation.dart';

part 'follow_dtos.g.dart';

/// Response from `GET /api/follow/{user_id}` — toggle is idempotent server
/// side; the response gives us the authoritative new state.
@JsonSerializable(createToJson: false)
class FollowToggleResponseDto {
  const FollowToggleResponseDto({
    this.isFollowing = false,
    this.followerCount = 0,
  });

  @JsonKey(name: 'is_following', defaultValue: false)
  final bool isFollowing;

  @JsonKey(name: 'follower_count', defaultValue: 0)
  final int followerCount;

  factory FollowToggleResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FollowToggleResponseDtoFromJson(json);
}

/// Response from `/api/followers` and `/api/users/<id>/followers`.
@JsonSerializable(createToJson: false)
class FollowersPageDto {
  const FollowersPageDto({this.followers = const [], this.count = 0});

  @JsonKey(defaultValue: [])
  final List<FollowUserDto> followers;
  @JsonKey(defaultValue: 0)
  final int count;

  factory FollowersPageDto.fromJson(Map<String, dynamic> json) =>
      _$FollowersPageDtoFromJson(json);
}

/// Response from `/api/followings` and `/api/users/<id>/followings`.
@JsonSerializable(createToJson: false)
class FollowingsPageDto {
  const FollowingsPageDto({this.followings = const [], this.count = 0});

  @JsonKey(defaultValue: [])
  final List<FollowUserDto> followings;
  @JsonKey(defaultValue: 0)
  final int count;

  factory FollowingsPageDto.fromJson(Map<String, dynamic> json) =>
      _$FollowingsPageDtoFromJson(json);
}

/// User row in the followers/followings list. Backend returns the full
/// `user_minimal` shape (id/username/name/pic/pro/xp) plus `followed_at`
/// and `is_following` (the viewer's relationship to this user).
@JsonSerializable(createToJson: false)
class FollowUserDto {
  const FollowUserDto({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.level,
    this.rankDisplay,
    this.badgeIconUrl,
    this.isFollowing = false,
    this.followedAt,
  });

  final int id;
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
  @JsonKey(name: 'is_following', defaultValue: false)
  final bool isFollowing;
  @JsonKey(name: 'followed_at')
  final String? followedAt;

  factory FollowUserDto.fromJson(Map<String, dynamic> json) =>
      _$FollowUserDtoFromJson(json);
}

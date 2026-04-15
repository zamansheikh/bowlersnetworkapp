import 'package:json_annotation/json_annotation.dart';

part 'profile_dto.g.dart';

/// Minimal shape of GET /api/profile — we only pull the fields the mobile app
/// needs in Phase 1. Remaining nested sub-models (address, ball_handling_style,
/// etc.) can be parsed later via [raw].
@JsonSerializable(createToJson: false)
class ProfileDto {
  const ProfileDto({
    required this.user,
    required this.completionPercentage,
    required this.isComplete,
    this.profileMedia,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  final ProfileUserDto user;

  @JsonKey(name: 'profile_media')
  final ProfileMediaDto? profileMedia;

  @JsonKey(name: 'follower_count', defaultValue: 0)
  final int followerCount;
  @JsonKey(name: 'following_count', defaultValue: 0)
  final int followingCount;

  @JsonKey(name: 'completion_percentage')
  final int completionPercentage;
  @JsonKey(name: 'is_complete')
  final bool isComplete;

  factory ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileUserDto {
  const ProfileUserDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    this.isPro = false,
  });

  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String username;
  @JsonKey(name: 'is_pro', defaultValue: false)
  final bool isPro;

  factory ProfileUserDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileUserDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileMediaDto {
  const ProfileMediaDto({
    this.profilePictureUrl,
    this.coverPictureUrl,
    this.introVideoUrl,
  });

  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'cover_picture_url')
  final String? coverPictureUrl;
  @JsonKey(name: 'intro_video_url')
  final String? introVideoUrl;

  factory ProfileMediaDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileMediaDtoFromJson(json);
}

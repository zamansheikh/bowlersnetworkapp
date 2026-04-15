// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => ProfileDto(
  user: ProfileUserDto.fromJson(json['user'] as Map<String, dynamic>),
  completionPercentage: (json['completion_percentage'] as num).toInt(),
  isComplete: json['is_complete'] as bool,
  profileMedia: json['profile_media'] == null
      ? null
      : ProfileMediaDto.fromJson(json['profile_media'] as Map<String, dynamic>),
  followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
  followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
);

ProfileUserDto _$ProfileUserDtoFromJson(Map<String, dynamic> json) =>
    ProfileUserDto(
      id: (json['id'] as num).toInt(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      username: json['username'] as String,
      isPro: json['is_pro'] as bool? ?? false,
    );

ProfileMediaDto _$ProfileMediaDtoFromJson(Map<String, dynamic> json) =>
    ProfileMediaDto(
      profilePictureUrl: json['profile_picture_url'] as String?,
      coverPictureUrl: json['cover_picture_url'] as String?,
      introVideoUrl: json['intro_video_url'] as String?,
    );

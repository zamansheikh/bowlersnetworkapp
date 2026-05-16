// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowToggleResponseDto _$FollowToggleResponseDtoFromJson(
  Map<String, dynamic> json,
) => FollowToggleResponseDto(
  isFollowing: json['is_following'] as bool? ?? false,
  followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
);

FollowersPageDto _$FollowersPageDtoFromJson(Map<String, dynamic> json) =>
    FollowersPageDto(
      followers:
          (json['followers'] as List<dynamic>?)
              ?.map((e) => FollowUserDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

FollowingsPageDto _$FollowingsPageDtoFromJson(Map<String, dynamic> json) =>
    FollowingsPageDto(
      followings:
          (json['followings'] as List<dynamic>?)
              ?.map((e) => FollowUserDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

FollowUserDto _$FollowUserDtoFromJson(Map<String, dynamic> json) =>
    FollowUserDto(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      isPro: json['is_pro'] as bool? ?? false,
      level: (json['level'] as num?)?.toInt(),
      rankDisplay: json['rank_display'] as String?,
      badgeIconUrl: json['badge_icon_url'] as String?,
      isFollowing: json['is_following'] as bool? ?? false,
      followedAt: json['followed_at'] as String?,
    );

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
  bio: json['bio'] == null
      ? null
      : ProfileBioDto.fromJson(json['bio'] as Map<String, dynamic>),
  nickname: json['nickname'] == null
      ? null
      : ProfileNicknameDto.fromJson(json['nickname'] as Map<String, dynamic>),
  gender: json['gender'] == null
      ? null
      : ProfileGenderDto.fromJson(json['gender'] as Map<String, dynamic>),
  birthdate: json['birthdate'] == null
      ? null
      : ProfileBirthdateDto.fromJson(json['birthdate'] as Map<String, dynamic>),
  address: json['address'] == null
      ? null
      : ProfileAddressDto.fromJson(json['address'] as Map<String, dynamic>),
  homeCenter: json['home_center'] == null
      ? null
      : ProfileHomeCenterDto.fromJson(
          json['home_center'] as Map<String, dynamic>,
        ),
  ballHandlingStyle: json['ball_handling_style'] == null
      ? null
      : ProfileBallHandlingDto.fromJson(
          json['ball_handling_style'] as Map<String, dynamic>,
        ),
  contactInfo: json['contact_info'] == null
      ? null
      : ProfileContactInfoDto.fromJson(
          json['contact_info'] as Map<String, dynamic>,
        ),
  officialGameStat: json['official_game_stat'] == null
      ? null
      : ProfileGameStatDto.fromJson(
          json['official_game_stat'] as Map<String, dynamic>,
        ),
  criticalInfo: json['critical_info'] == null
      ? null
      : ProfileCriticalInfoDto.fromJson(
          json['critical_info'] as Map<String, dynamic>,
        ),
  followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
  followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
  isFollowing: json['is_following'] as bool?,
  canFollow: json['can_follow'] as bool?,
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

ProfileBioDto _$ProfileBioDtoFromJson(Map<String, dynamic> json) =>
    ProfileBioDto(
      content: json['content'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      isAdded: json['is_added'] as bool? ?? false,
    );

ProfileNicknameDto _$ProfileNicknameDtoFromJson(Map<String, dynamic> json) =>
    ProfileNicknameDto(
      name: json['name'] as String?,
      isAdded: json['is_added'] as bool? ?? false,
    );

ProfileGenderDto _$ProfileGenderDtoFromJson(Map<String, dynamic> json) =>
    ProfileGenderDto(
      value: json['value'] as String?,
      isAdded: json['is_added'] as bool? ?? false,
    );

ProfileBirthdateDto _$ProfileBirthdateDtoFromJson(Map<String, dynamic> json) =>
    ProfileBirthdateDto(
      dateOfBirth: json['date_of_birth'] as String?,
      dateStr: json['date_str'] as String?,
      age: (json['age'] as num?)?.toInt(),
      isUnderage: json['is_underage'] as bool? ?? false,
      isAdded: json['is_added'] as bool? ?? false,
    );

ProfileAddressDto _$ProfileAddressDtoFromJson(Map<String, dynamic> json) =>
    ProfileAddressDto(
      location: json['location'] == null
          ? null
          : ProfileLocationDto.fromJson(
              json['location'] as Map<String, dynamic>,
            ),
      isAdded: json['is_added'] as bool? ?? false,
    );

ProfileLocationDto _$ProfileLocationDtoFromJson(Map<String, dynamic> json) =>
    ProfileLocationDto(
      address: json['address'] as String?,
      zipCode: json['zip_code'] as String?,
    );

ProfileHomeCenterDto _$ProfileHomeCenterDtoFromJson(
  Map<String, dynamic> json,
) => ProfileHomeCenterDto(
  centerId: (json['center_id'] as num?)?.toInt(),
  centerName: json['center_name'] as String?,
  isAdded: json['is_added'] as bool? ?? false,
);

ProfileBallHandlingDto _$ProfileBallHandlingDtoFromJson(
  Map<String, dynamic> json,
) => ProfileBallHandlingDto(
  handedness: json['handedness'] as String?,
  ballCarry: json['ball_carry'] as String?,
  grip: json['grip'] as String?,
  description: json['description'] as String?,
  isAdded: json['is_added'] as bool? ?? false,
);

ProfileContactInfoDto _$ProfileContactInfoDtoFromJson(
  Map<String, dynamic> json,
) => ProfileContactInfoDto(
  email: json['email'] as String?,
  isAdded: json['is_added'] as bool? ?? false,
);

ProfileGameStatDto _$ProfileGameStatDtoFromJson(Map<String, dynamic> json) =>
    ProfileGameStatDto(
      average: json['average'] as num?,
      highGame: (json['high_game'] as num?)?.toInt(),
      highSeries: (json['high_series'] as num?)?.toInt(),
      experience: (json['experience'] as num?)?.toInt(),
      isAdded: json['is_added'] as bool? ?? false,
    );

ProfileCriticalInfoDto _$ProfileCriticalInfoDtoFromJson(
  Map<String, dynamic> json,
) => ProfileCriticalInfoDto(
  isCoach: json['is_coach'] as bool? ?? false,
  isAdded: json['is_added'] as bool? ?? false,
);

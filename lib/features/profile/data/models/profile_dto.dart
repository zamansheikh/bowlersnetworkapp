import 'package:json_annotation/json_annotation.dart';

part 'profile_dto.g.dart';

/// GET /api/profile — we pick only the fields the mobile app actually
/// renders today. Deeper sub-models (address geo, ball-handling) can be
/// parsed later from [PostJsonRaw] if needed.
@JsonSerializable(createToJson: false)
class ProfileDto {
  const ProfileDto({
    required this.user,
    required this.completionPercentage,
    required this.isComplete,
    this.profileMedia,
    this.bio,
    this.nickname,
    this.gender,
    this.birthdate,
    this.address,
    this.homeCenter,
    this.ballHandlingStyle,
    this.contactInfo,
    this.officialGameStat,
    this.criticalInfo,
    this.followerCount = 0,
    this.followingCount = 0,
    this.isFollowing,
    this.canFollow,
  });

  final ProfileUserDto user;

  @JsonKey(name: 'profile_media')
  final ProfileMediaDto? profileMedia;

  final ProfileBioDto? bio;
  final ProfileNicknameDto? nickname;
  final ProfileGenderDto? gender;
  final ProfileBirthdateDto? birthdate;
  final ProfileAddressDto? address;

  @JsonKey(name: 'home_center')
  final ProfileHomeCenterDto? homeCenter;

  @JsonKey(name: 'ball_handling_style')
  final ProfileBallHandlingDto? ballHandlingStyle;

  @JsonKey(name: 'contact_info')
  final ProfileContactInfoDto? contactInfo;

  @JsonKey(name: 'official_game_stat')
  final ProfileGameStatDto? officialGameStat;

  @JsonKey(name: 'critical_info')
  final ProfileCriticalInfoDto? criticalInfo;

  @JsonKey(name: 'follower_count', defaultValue: 0)
  final int followerCount;
  @JsonKey(name: 'following_count', defaultValue: 0)
  final int followingCount;

  @JsonKey(name: 'completion_percentage')
  final int completionPercentage;
  @JsonKey(name: 'is_complete')
  final bool isComplete;

  @JsonKey(name: 'is_following')
  final bool? isFollowing;
  @JsonKey(name: 'can_follow')
  final bool? canFollow;

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

@JsonSerializable(createToJson: false)
class ProfileBioDto {
  const ProfileBioDto({this.content, this.isPublic = true, this.isAdded = false});
  final String? content;
  @JsonKey(name: 'is_public', defaultValue: true)
  final bool isPublic;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  factory ProfileBioDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileBioDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileNicknameDto {
  const ProfileNicknameDto({this.name, this.isAdded = false});
  final String? name;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  factory ProfileNicknameDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileNicknameDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileGenderDto {
  const ProfileGenderDto({this.value, this.isAdded = false});
  final String? value;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  factory ProfileGenderDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileGenderDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileBirthdateDto {
  const ProfileBirthdateDto({
    this.dateOfBirth,
    this.dateStr,
    this.age,
    this.isUnderage = false,
    this.isAdded = false,
  });

  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  @JsonKey(name: 'date_str')
  final String? dateStr;
  final int? age;
  @JsonKey(name: 'is_underage', defaultValue: false)
  final bool isUnderage;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  factory ProfileBirthdateDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileBirthdateDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileAddressDto {
  const ProfileAddressDto({this.location, this.isAdded = false});
  final ProfileLocationDto? location;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  factory ProfileAddressDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileAddressDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileLocationDto {
  const ProfileLocationDto({this.address, this.zipCode});
  final String? address;
  @JsonKey(name: 'zip_code')
  final String? zipCode;

  factory ProfileLocationDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileLocationDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileHomeCenterDto {
  const ProfileHomeCenterDto({
    this.centerId,
    this.centerName,
    this.isAdded = false,
  });
  @JsonKey(name: 'center_id')
  final int? centerId;
  @JsonKey(name: 'center_name')
  final String? centerName;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  factory ProfileHomeCenterDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileHomeCenterDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileBallHandlingDto {
  const ProfileBallHandlingDto({
    this.handedness,
    this.ballCarry,
    this.grip,
    this.description,
    this.isAdded = false,
  });
  final String? handedness;
  @JsonKey(name: 'ball_carry')
  final String? ballCarry;
  final String? grip;
  final String? description;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  factory ProfileBallHandlingDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileBallHandlingDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileContactInfoDto {
  const ProfileContactInfoDto({this.email, this.isAdded = false});
  final String? email;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  factory ProfileContactInfoDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileContactInfoDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileGameStatDto {
  const ProfileGameStatDto({
    this.average,
    this.highGame,
    this.highSeries,
    this.experience,
    this.isAdded = false,
  });
  final num? average;
  @JsonKey(name: 'high_game')
  final int? highGame;
  @JsonKey(name: 'high_series')
  final int? highSeries;
  final int? experience;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  factory ProfileGameStatDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileGameStatDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileCriticalInfoDto {
  const ProfileCriticalInfoDto({this.isCoach = false, this.isAdded = false});
  @JsonKey(name: 'is_coach', defaultValue: false)
  final bool isCoach;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  factory ProfileCriticalInfoDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileCriticalInfoDtoFromJson(json);
}

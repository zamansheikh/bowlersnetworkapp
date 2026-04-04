// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileCompletionModel _$ProfileCompletionModelFromJson(
  Map<String, dynamic> json,
) => ProfileCompletionModel(
  completionPercentage: (json['completion_percentage'] as num).toInt(),
  isComplete: json['is_complete'] as bool,
);

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
  user: json['user'] == null
      ? null
      : ProfileUserModel.fromJson(json['user'] as Map<String, dynamic>),
  gender: json['gender'] == null
      ? null
      : ProfileGenderModel.fromJson(json['gender'] as Map<String, dynamic>),
  birthdate: json['birthdate'] == null
      ? null
      : ProfileBirthdateModel.fromJson(
          json['birthdate'] as Map<String, dynamic>,
        ),
  address: json['address'] == null
      ? null
      : ProfileAddressModel.fromJson(json['address'] as Map<String, dynamic>),
  homeCenter: json['home_center'] == null
      ? null
      : ProfileHomeCenterModel.fromJson(
          json['home_center'] as Map<String, dynamic>,
        ),
  ballHandlingStyle: json['ball_handling_style'] == null
      ? null
      : ProfileBallHandlingModel.fromJson(
          json['ball_handling_style'] as Map<String, dynamic>,
        ),
  bio: json['bio'] == null
      ? null
      : ProfileBioModel.fromJson(json['bio'] as Map<String, dynamic>),
  nickname: json['nickname'] == null
      ? null
      : ProfileNicknameModel.fromJson(json['nickname'] as Map<String, dynamic>),
  profileMedia: json['profile_media'] == null
      ? null
      : ProfileMediaModel.fromJson(
          json['profile_media'] as Map<String, dynamic>,
        ),
  officialGameStat: json['official_game_stat'] == null
      ? null
      : ProfileGameStatModel.fromJson(
          json['official_game_stat'] as Map<String, dynamic>,
        ),
  followerCount: (json['follower_count'] as num?)?.toInt(),
  followingCount: (json['following_count'] as num?)?.toInt(),
  completionPercentage: (json['completion_percentage'] as num?)?.toInt(),
  isComplete: json['is_complete'] as bool?,
);

ProfileUserModel _$ProfileUserModelFromJson(Map<String, dynamic> json) =>
    ProfileUserModel(
      id: (json['id'] as num).toInt(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      username: json['username'] as String,
      isPro: json['is_pro'] as bool? ?? false,
    );

ProfileGenderModel _$ProfileGenderModelFromJson(Map<String, dynamic> json) =>
    ProfileGenderModel(
      value: json['value'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      isAdded: json['is_added'] as bool? ?? false,
    );

ProfileBirthdateModel _$ProfileBirthdateModelFromJson(
  Map<String, dynamic> json,
) => ProfileBirthdateModel(
  dateOfBirth: json['date_of_birth'] as String?,
  age: (json['age'] as num?)?.toInt(),
  isPublic: json['is_public'] as bool? ?? true,
  isAdded: json['is_added'] as bool? ?? false,
);

ProfileAddressModel _$ProfileAddressModelFromJson(Map<String, dynamic> json) =>
    ProfileAddressModel(
      location: json['location'] == null
          ? null
          : ProfileLocationModel.fromJson(
              json['location'] as Map<String, dynamic>,
            ),
      isPublic: json['is_public'] as bool? ?? true,
      isAdded: json['is_added'] as bool? ?? false,
    );

ProfileLocationModel _$ProfileLocationModelFromJson(
  Map<String, dynamic> json,
) => ProfileLocationModel(
  address: json['address'] as String?,
  zipCode: json['zip_code'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

ProfileHomeCenterModel _$ProfileHomeCenterModelFromJson(
  Map<String, dynamic> json,
) => ProfileHomeCenterModel(
  centerId: (json['center_id'] as num?)?.toInt(),
  centerName: json['center_name'] as String?,
  isPublic: json['is_public'] as bool? ?? true,
  isAdded: json['is_added'] as bool? ?? false,
);

ProfileBallHandlingModel _$ProfileBallHandlingModelFromJson(
  Map<String, dynamic> json,
) => ProfileBallHandlingModel(
  handedness: json['handedness'] as String?,
  ballCarry: json['ball_carry'] as String?,
  grip: json['grip'] as String?,
  isPublic: json['is_public'] as bool? ?? true,
  isAdded: json['is_added'] as bool? ?? false,
);

ProfileBioModel _$ProfileBioModelFromJson(Map<String, dynamic> json) =>
    ProfileBioModel(
      content: json['content'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      isAdded: json['is_added'] as bool? ?? false,
    );

ProfileNicknameModel _$ProfileNicknameModelFromJson(
  Map<String, dynamic> json,
) => ProfileNicknameModel(
  name: json['name'] as String?,
  isPublic: json['is_public'] as bool? ?? true,
  isAdded: json['is_added'] as bool? ?? false,
);

ProfileMediaModel _$ProfileMediaModelFromJson(Map<String, dynamic> json) =>
    ProfileMediaModel(
      profilePictureUrl: json['profile_picture_url'] as String?,
      coverPictureUrl: json['cover_picture_url'] as String?,
      introVideoUrl: json['intro_video_url'] as String?,
    );

ProfileGameStatModel _$ProfileGameStatModelFromJson(
  Map<String, dynamic> json,
) => ProfileGameStatModel(
  average: (json['average'] as num?)?.toDouble(),
  highGame: (json['high_game'] as num?)?.toInt(),
  highSeries: (json['high_series'] as num?)?.toInt(),
  experience: (json['experience'] as num?)?.toInt(),
  isPublic: json['is_public'] as bool? ?? true,
  isAdded: json['is_added'] as bool? ?? false,
);

CenterModel _$CenterModelFromJson(Map<String, dynamic> json) => CenterModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  logo: json['logo'] as String?,
  lanes: (json['lanes'] as num?)?.toInt(),
  address: json['address'] as String?,
  zipCode: json['zip_code'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

CloudUploadResponseModel _$CloudUploadResponseModelFromJson(
  Map<String, dynamic> json,
) => CloudUploadResponseModel(
  key: json['key'] as String,
  publicUrl: json['public_url'] as String,
  presignedUrl: json['presigned_url'] as String,
);

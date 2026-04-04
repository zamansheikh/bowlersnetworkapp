import 'package:json_annotation/json_annotation.dart';

part 'profile_models.g.dart';

@JsonSerializable(createToJson: false)
class ProfileCompletionModel {
  @JsonKey(name: 'completion_percentage')
  final int completionPercentage;
  @JsonKey(name: 'is_complete')
  final bool isComplete;

  const ProfileCompletionModel({required this.completionPercentage, required this.isComplete});
  factory ProfileCompletionModel.fromJson(Map<String, dynamic> json) => _$ProfileCompletionModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileModel {
  final ProfileUserModel? user;
  final ProfileGenderModel? gender;
  final ProfileBirthdateModel? birthdate;
  final ProfileAddressModel? address;
  @JsonKey(name: 'home_center')
  final ProfileHomeCenterModel? homeCenter;
  @JsonKey(name: 'ball_handling_style')
  final ProfileBallHandlingModel? ballHandlingStyle;
  final ProfileBioModel? bio;
  final ProfileNicknameModel? nickname;
  @JsonKey(name: 'profile_media')
  final ProfileMediaModel? profileMedia;
  @JsonKey(name: 'official_game_stat')
  final ProfileGameStatModel? officialGameStat;
  @JsonKey(name: 'follower_count')
  final int? followerCount;
  @JsonKey(name: 'following_count')
  final int? followingCount;
  @JsonKey(name: 'completion_percentage')
  final int? completionPercentage;
  @JsonKey(name: 'is_complete')
  final bool? isComplete;

  const ProfileModel({
    this.user, this.gender, this.birthdate, this.address, this.homeCenter,
    this.ballHandlingStyle, this.bio, this.nickname, this.profileMedia,
    this.officialGameStat, this.followerCount, this.followingCount,
    this.completionPercentage, this.isComplete,
  });
  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileUserModel {
  final int id;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  final String username;
  @JsonKey(name: 'is_pro', defaultValue: false)
  final bool isPro;

  const ProfileUserModel({required this.id, required this.firstName, required this.lastName, required this.username, this.isPro = false});
  factory ProfileUserModel.fromJson(Map<String, dynamic> json) => _$ProfileUserModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileGenderModel {
  final String? value;
  @JsonKey(name: 'is_public', defaultValue: true)
  final bool isPublic;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  const ProfileGenderModel({this.value, this.isPublic = true, this.isAdded = false});
  factory ProfileGenderModel.fromJson(Map<String, dynamic> json) => _$ProfileGenderModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileBirthdateModel {
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  final int? age;
  @JsonKey(name: 'is_public', defaultValue: true)
  final bool isPublic;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  const ProfileBirthdateModel({this.dateOfBirth, this.age, this.isPublic = true, this.isAdded = false});
  factory ProfileBirthdateModel.fromJson(Map<String, dynamic> json) => _$ProfileBirthdateModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileAddressModel {
  final ProfileLocationModel? location;
  @JsonKey(name: 'is_public', defaultValue: true)
  final bool isPublic;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  const ProfileAddressModel({this.location, this.isPublic = true, this.isAdded = false});
  factory ProfileAddressModel.fromJson(Map<String, dynamic> json) => _$ProfileAddressModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileLocationModel {
  final String? address;
  @JsonKey(name: 'zip_code')
  final String? zipCode;
  final double? latitude;
  final double? longitude;

  const ProfileLocationModel({this.address, this.zipCode, this.latitude, this.longitude});
  factory ProfileLocationModel.fromJson(Map<String, dynamic> json) => _$ProfileLocationModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileHomeCenterModel {
  @JsonKey(name: 'center_id')
  final int? centerId;
  @JsonKey(name: 'center_name')
  final String? centerName;
  @JsonKey(name: 'is_public', defaultValue: true)
  final bool isPublic;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  const ProfileHomeCenterModel({this.centerId, this.centerName, this.isPublic = true, this.isAdded = false});
  factory ProfileHomeCenterModel.fromJson(Map<String, dynamic> json) => _$ProfileHomeCenterModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileBallHandlingModel {
  final String? handedness;
  @JsonKey(name: 'ball_carry')
  final String? ballCarry;
  final String? grip;
  @JsonKey(name: 'is_public', defaultValue: true)
  final bool isPublic;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  const ProfileBallHandlingModel({this.handedness, this.ballCarry, this.grip, this.isPublic = true, this.isAdded = false});
  factory ProfileBallHandlingModel.fromJson(Map<String, dynamic> json) => _$ProfileBallHandlingModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileBioModel {
  final String? content;
  @JsonKey(name: 'is_public', defaultValue: true)
  final bool isPublic;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  const ProfileBioModel({this.content, this.isPublic = true, this.isAdded = false});
  factory ProfileBioModel.fromJson(Map<String, dynamic> json) => _$ProfileBioModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileNicknameModel {
  final String? name;
  @JsonKey(name: 'is_public', defaultValue: true)
  final bool isPublic;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  const ProfileNicknameModel({this.name, this.isPublic = true, this.isAdded = false});
  factory ProfileNicknameModel.fromJson(Map<String, dynamic> json) => _$ProfileNicknameModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileMediaModel {
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'cover_picture_url')
  final String? coverPictureUrl;
  @JsonKey(name: 'intro_video_url')
  final String? introVideoUrl;

  const ProfileMediaModel({this.profilePictureUrl, this.coverPictureUrl, this.introVideoUrl});
  factory ProfileMediaModel.fromJson(Map<String, dynamic> json) => _$ProfileMediaModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProfileGameStatModel {
  final double? average;
  @JsonKey(name: 'high_game')
  final int? highGame;
  @JsonKey(name: 'high_series')
  final int? highSeries;
  final int? experience;
  @JsonKey(name: 'is_public', defaultValue: true)
  final bool isPublic;
  @JsonKey(name: 'is_added', defaultValue: false)
  final bool isAdded;

  const ProfileGameStatModel({this.average, this.highGame, this.highSeries, this.experience, this.isPublic = true, this.isAdded = false});
  factory ProfileGameStatModel.fromJson(Map<String, dynamic> json) => _$ProfileGameStatModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class CenterModel {
  final int id;
  final String name;
  final String? logo;
  final int? lanes;
  final String? address;
  @JsonKey(name: 'zip_code')
  final String? zipCode;
  final double? latitude;
  final double? longitude;

  const CenterModel({required this.id, required this.name, this.logo, this.lanes, this.address, this.zipCode, this.latitude, this.longitude});
  factory CenterModel.fromJson(Map<String, dynamic> json) => _$CenterModelFromJson(json);
}

@JsonSerializable(createToJson: false)
class CloudUploadResponseModel {
  final String key;
  @JsonKey(name: 'public_url')
  final String publicUrl;
  @JsonKey(name: 'presigned_url')
  final String presignedUrl;

  const CloudUploadResponseModel({required this.key, required this.publicUrl, required this.presignedUrl});
  factory CloudUploadResponseModel.fromJson(Map<String, dynamic> json) => _$CloudUploadResponseModelFromJson(json);
}

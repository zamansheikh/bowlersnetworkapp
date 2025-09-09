// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  username: json['username'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  profilePictureUrl: json['profilePictureUrl'] as String,
  introVideoUrl: json['introVideoUrl'] as String,
  coverPhotoUrl: json['coverPhotoUrl'] as String,
  xp: (json['xp'] as num).toInt(),
  level: (json['level'] as num).toInt(),
  cardTheme: json['cardTheme'] as String,
  isPro: json['isPro'] as bool,
  sponsors: (json['sponsors'] as List<dynamic>)
      .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  followerCount: (json['followerCount'] as num).toInt(),
  stats: StatsModel.fromJson(json['stats'] as Map<String, dynamic>),
  favoriteBrands: (json['favoriteBrands'] as List<dynamic>)
      .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  isComplete: json['isComplete'] as bool,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'username': instance.username,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'profilePictureUrl': instance.profilePictureUrl,
  'introVideoUrl': instance.introVideoUrl,
  'coverPhotoUrl': instance.coverPhotoUrl,
  'xp': instance.xp,
  'level': instance.level,
  'cardTheme': instance.cardTheme,
  'isPro': instance.isPro,
  'sponsors': instance.sponsors,
  'followerCount': instance.followerCount,
  'stats': instance.stats,
  'favoriteBrands': instance.favoriteBrands,
  'isComplete': instance.isComplete,
};

BrandModel _$BrandModelFromJson(Map<String, dynamic> json) => BrandModel(
  brandId: (json['brandId'] as num).toInt(),
  brandType: json['brandType'] as String,
  name: json['name'] as String,
  formalName: json['formalName'] as String,
  logoUrl: json['logoUrl'] as String,
);

Map<String, dynamic> _$BrandModelToJson(BrandModel instance) =>
    <String, dynamic>{
      'brandId': instance.brandId,
      'brandType': instance.brandType,
      'name': instance.name,
      'formalName': instance.formalName,
      'logoUrl': instance.logoUrl,
    };

StatsModel _$StatsModelFromJson(Map<String, dynamic> json) => StatsModel(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  averageScore: (json['averageScore'] as num).toDouble(),
  highGame: (json['highGame'] as num).toInt(),
  highSeries: (json['highSeries'] as num).toInt(),
  experience: (json['experience'] as num).toInt(),
);

Map<String, dynamic> _$StatsModelToJson(StatsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'averageScore': instance.averageScore,
      'highGame': instance.highGame,
      'highSeries': instance.highSeries,
      'experience': instance.experience,
    };

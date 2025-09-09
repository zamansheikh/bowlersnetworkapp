import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends User {
  final String username;
  final String firstName;
  final String lastName;
  final String profilePictureUrl;
  final String introVideoUrl;
  final String coverPhotoUrl;
  final int xp;
  final int level;
  final String cardTheme;
  final bool isPro;
  final List<BrandModel> sponsors;
  final int followerCount;
  final StatsModel stats;
  final List<BrandModel> favoriteBrands;
  final bool isComplete;

  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.profilePictureUrl,
    required this.introVideoUrl,
    required this.coverPhotoUrl,
    required this.xp,
    required this.level,
    required this.cardTheme,
    required this.isPro,
    required this.sponsors,
    required this.followerCount,
    required this.stats,
    required this.favoriteBrands,
    required this.isComplete,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class BrandModel {
  final int brandId;
  final String brandType;
  final String name;
  final String formalName;
  final String logoUrl;

  const BrandModel({
    required this.brandId,
    required this.brandType,
    required this.name,
    required this.formalName,
    required this.logoUrl,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) =>
      _$BrandModelFromJson(json);

  Map<String, dynamic> toJson() => _$BrandModelToJson(this);
}

@JsonSerializable()
class StatsModel {
  final int id;
  final int userId;
  final double averageScore;
  final int highGame;
  final int highSeries;
  final int experience;

  const StatsModel({
    required this.id,
    required this.userId,
    required this.averageScore,
    required this.highGame,
    required this.highSeries,
    required this.experience,
  });

  factory StatsModel.fromJson(Map<String, dynamic> json) =>
      _$StatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$StatsModelToJson(this);
}

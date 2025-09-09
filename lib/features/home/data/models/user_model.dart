import '../../domain/entities/user.dart';

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

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: (json['user_id'] as num).toInt(),
    name: json['name'] as String,
    email: json['email'] as String,
    username: json['username'] as String,
    firstName: json['first_name'] as String,
    lastName: json['last_name'] as String,
    profilePictureUrl: json['profile_picture_url'] as String,
    introVideoUrl: json['intro_video_url'] as String,
    coverPhotoUrl: json['cover_photo_url'] as String,
    xp: (json['xp'] as num).toInt(),
    level: (json['level'] as num).toInt(),
    cardTheme: json['card_theme'] as String,
    isPro: json['is_pro'] as bool,
    sponsors: (json['sponsors'] as List<dynamic>)
        .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    followerCount: (json['follower_count'] as num).toInt(),
    stats: StatsModel.fromJson(json['stats'] as Map<String, dynamic>),
    favoriteBrands: (json['favorite_brands'] as List<dynamic>)
        .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    isComplete: json['is_complete'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'user_id': id,
    'name': name,
    'email': email,
    'username': username,
    'first_name': firstName,
    'last_name': lastName,
    'profile_picture_url': profilePictureUrl,
    'intro_video_url': introVideoUrl,
    'cover_photo_url': coverPhotoUrl,
    'xp': xp,
    'level': level,
    'card_theme': cardTheme,
    'is_pro': isPro,
    'sponsors': sponsors.map((e) => e.toJson()).toList(),
    'follower_count': followerCount,
    'stats': stats.toJson(),
    'favorite_brands': favoriteBrands.map((e) => e.toJson()).toList(),
    'is_complete': isComplete,
  };
}

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

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
    brandId: (json['brand_id'] as num).toInt(),
    brandType: json['brandType'] as String,
    name: json['name'] as String,
    formalName: json['formal_name'] as String,
    logoUrl: json['logo_url'] as String,
  );

  Map<String, dynamic> toJson() => {
    'brand_id': brandId,
    'brandType': brandType,
    'name': name,
    'formal_name': formalName,
    'logo_url': logoUrl,
  };
}

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

  factory StatsModel.fromJson(Map<String, dynamic> json) => StatsModel(
    id: (json['id'] as num).toInt(),
    userId: (json['user_id'] as num).toInt(),
    averageScore: (json['average_score'] as num).toDouble(),
    highGame: (json['high_game'] as num).toInt(),
    highSeries: (json['high_series'] as num).toInt(),
    experience: (json['experience'] as num).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'average_score': averageScore,
    'high_game': highGame,
    'high_series': highSeries,
    'experience': experience,
  };
}

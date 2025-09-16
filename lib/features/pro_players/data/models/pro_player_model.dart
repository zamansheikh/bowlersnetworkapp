import '../../domain/entities/pro_player.dart';
import '../../../home/data/models/feed_post.dart';

class ProPlayerModel extends ProPlayer {
  const ProPlayerModel({
    required super.userId,
    required super.username,
    required super.name,
    required super.firstName,
    required super.lastName,
    required super.profilePictureUrl,
    required super.introVideoUrl,
    required super.xp,
    required super.email,
    required super.level,
    required super.cardTheme,
    required super.isPro,
    required super.followerCount,
    required super.sponsors,
    required super.stats,
    required super.engagement,
    required super.isFollowed,
    required super.favoriteBrands,
    required super.posts,
  });

  factory ProPlayerModel.fromJson(Map<String, dynamic> json) {
    return ProPlayerModel(
      userId: (json['user_id'] as num).toInt(),
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String? ?? '',
      introVideoUrl: json['intro_video_url'] as String? ?? '',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? '',
      level: (json['level'] as num?)?.toInt() ?? 1,
      cardTheme: json['card_theme'] as String? ?? '',
      isPro: json['is_pro'] as bool? ?? false,
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
      sponsors: json['sponsors'] != null
          ? (json['sponsors'] as List<dynamic>)
                .map((e) => SponsorModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      stats: json['stats'] != null
          ? PlayerStatsModel.fromJson(json['stats'] as Map<String, dynamic>)
          : const PlayerStatsModel(
              id: 0,
              userId: 0,
              averageScore: 0.0,
              highGame: 0,
              highSeries: 0,
              experience: 0,
            ),
      engagement: json['engagement'] != null
          ? EngagementModel.fromJson(json['engagement'] as Map<String, dynamic>)
          : const EngagementModel(likes: 0, comments: 0, shares: 0, views: 0),
      isFollowed: json['is_followed'] as bool? ?? false,
      favoriteBrands: json['favorite_brands'] != null
          ? (json['favorite_brands'] as List<dynamic>)
                .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      posts: [], // Posts will be loaded separately
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'profile_picture_url': profilePictureUrl,
      'intro_video_url': introVideoUrl,
      'xp': xp,
      'email': email,
      'level': level,
      'card_theme': cardTheme,
      'is_pro': isPro,
      'follower_count': followerCount,
      'sponsors': sponsors.map((e) => (e as SponsorModel).toJson()).toList(),
      'stats': (stats as PlayerStatsModel).toJson(),
      'engagement': (engagement as EngagementModel).toJson(),
      'is_followed': isFollowed,
      'favorite_brands': favoriteBrands
          .map((e) => (e as BrandModel).toJson())
          .toList(),
    };
  }

  ProPlayerModel copyWith({
    bool? isFollowed,
    int? followerCount,
    List<FeedPost>? posts,
  }) {
    return ProPlayerModel(
      userId: userId,
      username: username,
      name: name,
      firstName: firstName,
      lastName: lastName,
      profilePictureUrl: profilePictureUrl,
      introVideoUrl: introVideoUrl,
      xp: xp,
      email: email,
      level: level,
      cardTheme: cardTheme,
      isPro: isPro,
      followerCount: followerCount ?? this.followerCount,
      sponsors: sponsors,
      stats: stats,
      engagement: engagement,
      isFollowed: isFollowed ?? this.isFollowed,
      favoriteBrands: favoriteBrands,
      posts: posts ?? this.posts,
    );
  }
}

class SponsorModel extends Sponsor {
  const SponsorModel({
    required super.brandId,
    required super.brandType,
    required super.name,
    required super.formalName,
    required super.logoUrl,
  });

  factory SponsorModel.fromJson(Map<String, dynamic> json) {
    return SponsorModel(
      brandId: (json['brand_id'] as num).toInt(),
      brandType: json['brandType'] as String? ?? '',
      name: json['name'] as String? ?? '',
      formalName: json['formal_name'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_id': brandId,
      'brandType': brandType,
      'name': name,
      'formal_name': formalName,
      'logo_url': logoUrl,
    };
  }
}

class PlayerStatsModel extends PlayerStats {
  const PlayerStatsModel({
    required super.id,
    required super.userId,
    required super.averageScore,
    required super.highGame,
    required super.highSeries,
    required super.experience,
  });

  factory PlayerStatsModel.fromJson(Map<String, dynamic> json) {
    return PlayerStatsModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      highGame: (json['high_game'] as num?)?.toInt() ?? 0,
      highSeries: (json['high_series'] as num?)?.toInt() ?? 0,
      experience: (json['experience'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'average_score': averageScore,
      'high_game': highGame,
      'high_series': highSeries,
      'experience': experience,
    };
  }
}

class EngagementModel extends Engagement {
  const EngagementModel({
    required super.likes,
    required super.comments,
    required super.shares,
    required super.views,
  });

  factory EngagementModel.fromJson(Map<String, dynamic> json) {
    return EngagementModel(
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'views': views,
    };
  }
}

class BrandModel extends Brand {
  const BrandModel({
    required super.brandId,
    required super.brandType,
    required super.name,
    required super.formalName,
    required super.logoUrl,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      brandId: (json['brand_id'] as num).toInt(),
      brandType: json['brandType'] as String? ?? '',
      name: json['name'] as String? ?? '',
      formalName: json['formal_name'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_id': brandId,
      'brandType': brandType,
      'name': name,
      'formal_name': formalName,
      'logo_url': logoUrl,
    };
  }
}

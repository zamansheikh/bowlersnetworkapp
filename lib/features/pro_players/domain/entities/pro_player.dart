import 'package:equatable/equatable.dart';
import '../../../home/data/models/feed_post.dart';

class ProPlayer extends Equatable {
  final int userId;
  final String username;
  final String name;
  final String firstName;
  final String lastName;
  final String profilePictureUrl;
  final String introVideoUrl;
  final int xp;
  final String email;
  final int level;
  final String cardTheme;
  final bool isPro;
  final int followerCount;
  final List<Sponsor> sponsors;
  final PlayerStats stats;
  final Engagement engagement;
  final bool isFollowed;
  final List<Brand> favoriteBrands;
  final List<FeedPost> posts;

  const ProPlayer({
    required this.userId,
    required this.username,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.profilePictureUrl,
    required this.introVideoUrl,
    required this.xp,
    required this.email,
    required this.level,
    required this.cardTheme,
    required this.isPro,
    required this.followerCount,
    required this.sponsors,
    required this.stats,
    required this.engagement,
    required this.isFollowed,
    required this.favoriteBrands,
    required this.posts,
  });

  @override
  List<Object> get props => [
    userId,
    username,
    name,
    firstName,
    lastName,
    profilePictureUrl,
    introVideoUrl,
    xp,
    email,
    level,
    cardTheme,
    isPro,
    followerCount,
    sponsors,
    stats,
    engagement,
    isFollowed,
    favoriteBrands,
    posts,
  ];
}

class Sponsor extends Equatable {
  final int brandId;
  final String brandType;
  final String name;
  final String formalName;
  final String logoUrl;

  const Sponsor({
    required this.brandId,
    required this.brandType,
    required this.name,
    required this.formalName,
    required this.logoUrl,
  });

  @override
  List<Object> get props => [brandId, brandType, name, formalName, logoUrl];
}

class PlayerStats extends Equatable {
  final int id;
  final int userId;
  final double averageScore;
  final int highGame;
  final int highSeries;
  final int experience;

  const PlayerStats({
    required this.id,
    required this.userId,
    required this.averageScore,
    required this.highGame,
    required this.highSeries,
    required this.experience,
  });

  @override
  List<Object> get props => [
    id,
    userId,
    averageScore,
    highGame,
    highSeries,
    experience,
  ];
}

class Engagement extends Equatable {
  final int likes;
  final int comments;
  final int shares;
  final int views;

  const Engagement({
    required this.likes,
    required this.comments,
    required this.shares,
    required this.views,
  });

  @override
  List<Object> get props => [likes, comments, shares, views];
}

class Brand extends Equatable {
  final int brandId;
  final String brandType;
  final String name;
  final String formalName;
  final String logoUrl;

  const Brand({
    required this.brandId,
    required this.brandType,
    required this.name,
    required this.formalName,
    required this.logoUrl,
  });

  @override
  List<Object> get props => [brandId, brandType, name, formalName, logoUrl];
}

import 'package:json_annotation/json_annotation.dart';

part 'leaderboard_dtos.g.dart';

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/xp/leaderboard/{board_type}
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class LeaderboardPageDto {
  const LeaderboardPageDto({
    this.entries = const [],
    this.myPosition,
    this.totalEntries = 0,
    this.hasNext = false,
  });

  @JsonKey(defaultValue: [])
  final List<LeaderboardEntryDto> entries;
  @JsonKey(name: 'my_position')
  final MyPositionDto? myPosition;
  @JsonKey(name: 'total_entries', defaultValue: 0)
  final int totalEntries;
  @JsonKey(name: 'has_next', defaultValue: false)
  final bool hasNext;

  factory LeaderboardPageDto.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardPageDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class LeaderboardEntryDto {
  const LeaderboardEntryDto({
    required this.position,
    required this.user,
    this.xpEarned = 0,
    this.rankDisplay = '',
  });

  final int position;
  final LeaderboardUserDto user;
  @JsonKey(name: 'xp_earned', defaultValue: 0)
  final int xpEarned;
  @JsonKey(name: 'rank_display', defaultValue: '')
  final String rankDisplay;

  factory LeaderboardEntryDto.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardEntryDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class LeaderboardUserDto {
  const LeaderboardUserDto({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.totalXp,
    this.level,
    this.rank,
    this.tier,
    this.rankDisplay,
    this.badgeIconUrl,
    this.isFollowing = false,
  });

  final int id;
  final String username;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'is_pro', defaultValue: false)
  final bool isPro;
  @JsonKey(name: 'total_xp')
  final int? totalXp;
  final int? level;
  final String? rank;
  final String? tier;
  @JsonKey(name: 'rank_display')
  final String? rankDisplay;
  @JsonKey(name: 'badge_icon_url')
  final String? badgeIconUrl;
  @JsonKey(name: 'is_following', defaultValue: false)
  final bool isFollowing;

  factory LeaderboardUserDto.fromJson(Map<String, dynamic> json) =>
      _$LeaderboardUserDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class MyPositionDto {
  const MyPositionDto({this.position = 0, this.xpEarned = 0});

  final int position;
  @JsonKey(name: 'xp_earned', defaultValue: 0)
  final int xpEarned;

  factory MyPositionDto.fromJson(Map<String, dynamic> json) =>
      _$MyPositionDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/xp/ranks  →  `[{rank, tiers: [{tier, level, badge_icon_url, points_required}]}]`
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class RankGroupDto {
  const RankGroupDto({required this.rank, this.tiers = const []});

  final RankDto rank;
  @JsonKey(defaultValue: [])
  final List<RankTierDto> tiers;

  factory RankGroupDto.fromJson(Map<String, dynamic> json) =>
      _$RankGroupDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class RankDto {
  const RankDto({
    required this.id,
    required this.name,
    this.order = 0,
    this.phase = '',
  });

  final int id;
  final String name;
  @JsonKey(defaultValue: 0)
  final int order;
  @JsonKey(defaultValue: '')
  final String phase;

  factory RankDto.fromJson(Map<String, dynamic> json) =>
      _$RankDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class RankTierDto {
  const RankTierDto({
    this.tier,
    required this.level,
    this.badgeIconUrl = '',
    this.pointsRequired = 0,
  });

  final TierDto? tier;
  final int level;
  @JsonKey(name: 'badge_icon_url', defaultValue: '')
  final String badgeIconUrl;
  @JsonKey(name: 'points_required', defaultValue: 0)
  final int pointsRequired;

  factory RankTierDto.fromJson(Map<String, dynamic> json) =>
      _$RankTierDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TierDto {
  const TierDto({
    required this.id,
    required this.name,
    this.order = 0,
    this.badgeIconUrl = '',
  });

  final int id;
  final String name;
  @JsonKey(defaultValue: 0)
  final int order;
  @JsonKey(name: 'badge_icon_url', defaultValue: '')
  final String badgeIconUrl;

  factory TierDto.fromJson(Map<String, dynamic> json) =>
      _$TierDtoFromJson(json);
}

// ──────────────────────────────────────────────────────────────────────────────
// GET /api/xp/dashboard
// ──────────────────────────────────────────────────────────────────────────────
@JsonSerializable(createToJson: false)
class XpDashboardDto {
  const XpDashboardDto({
    this.level = 1,
    this.totalPoints = 0,
    this.weeklyPoints = 0,
    this.monthlyPoints = 0,
    this.weeklyXpChange = 0,
    this.progressPercentage = 0,
    this.xpRemaining,
    this.last7DaysXp = 0,
    this.leaderboardPosition,
    this.rank,
    this.tier,
    this.rankDisplay,
    this.badgeIconUrl,
  });

  @JsonKey(defaultValue: 1)
  final int level;
  @JsonKey(name: 'total_points', defaultValue: 0)
  final int totalPoints;
  @JsonKey(name: 'weekly_points', defaultValue: 0)
  final int weeklyPoints;
  @JsonKey(name: 'monthly_points', defaultValue: 0)
  final int monthlyPoints;
  @JsonKey(name: 'weekly_xp_change', defaultValue: 0)
  final int weeklyXpChange;
  @JsonKey(name: 'progress_percentage', defaultValue: 0)
  final num progressPercentage;
  @JsonKey(name: 'xp_remaining')
  final int? xpRemaining;
  @JsonKey(name: 'last_7_days_xp', defaultValue: 0)
  final int last7DaysXp;
  @JsonKey(name: 'leaderboard_position')
  final int? leaderboardPosition;
  final String? rank;
  final String? tier;
  @JsonKey(name: 'rank_display')
  final String? rankDisplay;
  @JsonKey(name: 'badge_icon_url')
  final String? badgeIconUrl;

  factory XpDashboardDto.fromJson(Map<String, dynamic> json) =>
      _$XpDashboardDtoFromJson(json);
}

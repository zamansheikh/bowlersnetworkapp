// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaderboardPageDto _$LeaderboardPageDtoFromJson(Map<String, dynamic> json) =>
    LeaderboardPageDto(
      entries:
          (json['entries'] as List<dynamic>?)
              ?.map(
                (e) => LeaderboardEntryDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      myPosition: json['my_position'] == null
          ? null
          : MyPositionDto.fromJson(json['my_position'] as Map<String, dynamic>),
      totalEntries: (json['total_entries'] as num?)?.toInt() ?? 0,
      hasNext: json['has_next'] as bool? ?? false,
    );

LeaderboardEntryDto _$LeaderboardEntryDtoFromJson(Map<String, dynamic> json) =>
    LeaderboardEntryDto(
      position: (json['position'] as num).toInt(),
      user: LeaderboardUserDto.fromJson(json['user'] as Map<String, dynamic>),
      xpEarned: (json['xp_earned'] as num?)?.toInt() ?? 0,
      rankDisplay: json['rank_display'] as String? ?? '',
    );

LeaderboardUserDto _$LeaderboardUserDtoFromJson(Map<String, dynamic> json) =>
    LeaderboardUserDto(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      isPro: json['is_pro'] as bool? ?? false,
      totalXp: (json['total_xp'] as num?)?.toInt(),
      level: (json['level'] as num?)?.toInt(),
      rank: json['rank'] as String?,
      tier: json['tier'] as String?,
      rankDisplay: json['rank_display'] as String?,
      badgeIconUrl: json['badge_icon_url'] as String?,
      isFollowing: json['is_following'] as bool? ?? false,
    );

MyPositionDto _$MyPositionDtoFromJson(Map<String, dynamic> json) =>
    MyPositionDto(
      position: (json['position'] as num?)?.toInt() ?? 0,
      xpEarned: (json['xp_earned'] as num?)?.toInt() ?? 0,
    );

RankGroupDto _$RankGroupDtoFromJson(Map<String, dynamic> json) => RankGroupDto(
  rank: RankDto.fromJson(json['rank'] as Map<String, dynamic>),
  tiers:
      (json['tiers'] as List<dynamic>?)
          ?.map((e) => RankTierDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

RankDto _$RankDtoFromJson(Map<String, dynamic> json) => RankDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  order: (json['order'] as num?)?.toInt() ?? 0,
  phase: json['phase'] as String? ?? '',
);

RankTierDto _$RankTierDtoFromJson(Map<String, dynamic> json) => RankTierDto(
  tier: json['tier'] == null
      ? null
      : TierDto.fromJson(json['tier'] as Map<String, dynamic>),
  level: (json['level'] as num).toInt(),
  badgeIconUrl: json['badge_icon_url'] as String? ?? '',
  pointsRequired: (json['points_required'] as num?)?.toInt() ?? 0,
);

TierDto _$TierDtoFromJson(Map<String, dynamic> json) => TierDto(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  order: (json['order'] as num?)?.toInt() ?? 0,
  badgeIconUrl: json['badge_icon_url'] as String? ?? '',
);

XpDashboardDto _$XpDashboardDtoFromJson(Map<String, dynamic> json) =>
    XpDashboardDto(
      level: (json['level'] as num?)?.toInt() ?? 1,
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      weeklyPoints: (json['weekly_points'] as num?)?.toInt() ?? 0,
      monthlyPoints: (json['monthly_points'] as num?)?.toInt() ?? 0,
      weeklyXpChange: (json['weekly_xp_change'] as num?)?.toInt() ?? 0,
      progressPercentage: json['progress_percentage'] as num? ?? 0,
      xpRemaining: (json['xp_remaining'] as num?)?.toInt(),
      last7DaysXp: (json['last_7_days_xp'] as num?)?.toInt() ?? 0,
      leaderboardPosition: (json['leaderboard_position'] as num?)?.toInt(),
      rank: json['rank'] as String?,
      tier: json['tier'] as String?,
      rankDisplay: json['rank_display'] as String?,
      badgeIconUrl: json['badge_icon_url'] as String?,
    );

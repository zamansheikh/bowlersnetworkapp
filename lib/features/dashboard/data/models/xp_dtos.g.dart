// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'xp_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

XpInsightsDto _$XpInsightsDtoFromJson(Map<String, dynamic> json) =>
    XpInsightsDto(
      snapshotDate: json['snapshot_date'] as String?,
      overview: json['overview'] == null
          ? null
          : XpOverviewDto.fromJson(json['overview'] as Map<String, dynamic>),
      velocity: json['velocity'] == null
          ? null
          : XpVelocityDto.fromJson(json['velocity'] as Map<String, dynamic>),
      categoryBreakdown:
          (json['category_breakdown'] as List<dynamic>?)
              ?.map((e) => XpCategoryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topActions:
          (json['top_actions'] as List<dynamic>?)
              ?.map((e) => XpActionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      patterns: json['patterns'] == null
          ? null
          : XpPatternsDto.fromJson(json['patterns'] as Map<String, dynamic>),
      streak: json['streak'] == null
          ? null
          : XpStreakDto.fromJson(json['streak'] as Map<String, dynamic>),
      rank: json['rank'] == null
          ? null
          : XpRankDto.fromJson(json['rank'] as Map<String, dynamic>),
      history: json['history'] == null
          ? null
          : XpHistoryDto.fromJson(json['history'] as Map<String, dynamic>),
      projection: json['projection'] == null
          ? null
          : XpProjectionDto.fromJson(
              json['projection'] as Map<String, dynamic>,
            ),
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

XpOverviewDto _$XpOverviewDtoFromJson(Map<String, dynamic> json) =>
    XpOverviewDto(
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 0,
      rank: json['rank'] as String? ?? '',
      tier: json['tier'] as String? ?? '',
      rankDisplay: json['rank_display'] as String? ?? '',
      badgeIconUrl: json['badge_icon_url'] as String? ?? '',
      progressPercentage: json['progress_percentage'] as num? ?? 0,
      xpToNextLevel: (json['xp_to_next_level'] as num?)?.toInt(),
      nextLevel: (json['next_level'] as num?)?.toInt(),
      nextRankDisplay: json['next_rank_display'] as String? ?? '',
      nextBadgeIconUrl: json['next_badge_icon_url'] as String? ?? '',
      dailyXp: (json['daily_xp'] as num?)?.toInt() ?? 0,
      weeklyXp: (json['weekly_xp'] as num?)?.toInt() ?? 0,
    );

XpVelocityDto _$XpVelocityDtoFromJson(Map<String, dynamic> json) =>
    XpVelocityDto(
      earned7d: (json['earned_7d'] as num?)?.toInt() ?? 0,
      earned30d: (json['earned_30d'] as num?)?.toInt() ?? 0,
      lost7d: (json['lost_7d'] as num?)?.toInt() ?? 0,
      lost30d: (json['lost_30d'] as num?)?.toInt() ?? 0,
      avgDaily7d: json['avg_daily_7d'] as num? ?? 0,
      avgDaily30d: json['avg_daily_30d'] as num? ?? 0,
      activeDays7d: (json['active_days_7d'] as num?)?.toInt() ?? 0,
      activeDays30d: (json['active_days_30d'] as num?)?.toInt() ?? 0,
      net7d: (json['net_7d'] as num?)?.toInt() ?? 0,
      net30d: (json['net_30d'] as num?)?.toInt() ?? 0,
    );

XpCategoryDto _$XpCategoryDtoFromJson(Map<String, dynamic> json) =>
    XpCategoryDto(
      category: json['category'] as String? ?? '',
      earned: (json['earned'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
      percentage: json['percentage'] as num? ?? 0,
    );

XpActionDto _$XpActionDtoFromJson(Map<String, dynamic> json) => XpActionDto(
  action: json['action'] as String? ?? '',
  earned: (json['earned'] as num?)?.toInt() ?? 0,
  count: (json['count'] as num?)?.toInt() ?? 0,
);

XpPatternsDto _$XpPatternsDtoFromJson(
  Map<String, dynamic> json,
) => XpPatternsDto(
  hourlyXp:
      (json['hourly_xp'] as List<dynamic>?)?.map((e) => e as num).toList() ??
      [],
  dailyXp:
      (json['daily_xp'] as List<dynamic>?)?.map((e) => e as num).toList() ?? [],
  bestHour: (json['best_hour'] as num?)?.toInt(),
  bestHourLabel: json['best_hour_label'] as String? ?? '',
  bestDay: (json['best_day'] as num?)?.toInt(),
  bestDayName: json['best_day_name'] as String? ?? '',
);

XpStreakDto _$XpStreakDtoFromJson(Map<String, dynamic> json) => XpStreakDto(
  currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
  longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
  milestones:
      (json['milestones'] as List<dynamic>?)
          ?.map((e) => XpStreakMilestoneDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  nextMilestone: json['next_milestone'] == null
      ? null
      : XpStreakTargetDto.fromJson(
          json['next_milestone'] as Map<String, dynamic>,
        ),
  multiplier: json['multiplier'] as num? ?? 1,
);

XpStreakMilestoneDto _$XpStreakMilestoneDtoFromJson(
  Map<String, dynamic> json,
) => XpStreakMilestoneDto(
  length: (json['length'] as num?)?.toInt() ?? 0,
  xpAwarded: (json['xp_awarded'] as num?)?.toInt() ?? 0,
  reachedAt: json['reached_at'] as String?,
);

XpStreakTargetDto _$XpStreakTargetDtoFromJson(Map<String, dynamic> json) =>
    XpStreakTargetDto(
      target: (json['target'] as num?)?.toInt() ?? 0,
      daysAway: (json['days_away'] as num?)?.toInt() ?? 0,
    );

XpRankDto _$XpRankDtoFromJson(Map<String, dynamic> json) => XpRankDto(
  globalPosition: (json['global_position'] as num?)?.toInt() ?? 0,
  globalTotalRanked: (json['global_total_ranked'] as num?)?.toInt() ?? 0,
  globalPercentile: json['global_percentile'] as num? ?? 0,
);

XpHistoryDto _$XpHistoryDtoFromJson(Map<String, dynamic> json) => XpHistoryDto(
  labels:
      (json['labels'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  xpTotals:
      (json['xp_totals'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  xpDaily:
      (json['xp_daily'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
  levels:
      (json['levels'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      [],
);

XpProjectionDto _$XpProjectionDtoFromJson(Map<String, dynamic> json) =>
    XpProjectionDto(
      daysToNextLevel: (json['days_to_next_level'] as num?)?.toInt(),
      projectedLevel30d: (json['projected_level_30d'] as num?)?.toInt() ?? 0,
      currentVelocity: json['current_velocity'] as num? ?? 0,
    );

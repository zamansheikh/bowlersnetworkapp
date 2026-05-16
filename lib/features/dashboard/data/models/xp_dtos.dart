import 'package:json_annotation/json_annotation.dart';

part 'xp_dtos.g.dart';

@JsonSerializable(createToJson: false)
class XpInsightsDto {
  const XpInsightsDto({
    this.snapshotDate,
    this.overview,
    this.velocity,
    this.categoryBreakdown = const [],
    this.topActions = const [],
    this.patterns,
    this.streak,
    this.rank,
    this.history,
    this.projection,
    this.recommendations = const [],
  });

  @JsonKey(name: 'snapshot_date')
  final String? snapshotDate;
  final XpOverviewDto? overview;
  final XpVelocityDto? velocity;
  @JsonKey(name: 'category_breakdown', defaultValue: <XpCategoryDto>[])
  final List<XpCategoryDto> categoryBreakdown;
  @JsonKey(name: 'top_actions', defaultValue: <XpActionDto>[])
  final List<XpActionDto> topActions;
  final XpPatternsDto? patterns;
  final XpStreakDto? streak;
  final XpRankDto? rank;
  final XpHistoryDto? history;
  final XpProjectionDto? projection;
  @JsonKey(defaultValue: <String>[])
  final List<String> recommendations;

  factory XpInsightsDto.fromJson(Map<String, dynamic> json) =>
      _$XpInsightsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class XpOverviewDto {
  const XpOverviewDto({
    this.totalXp = 0,
    this.level = 0,
    this.rank = '',
    this.tier = '',
    this.rankDisplay = '',
    this.badgeIconUrl = '',
    this.progressPercentage = 0,
    this.xpToNextLevel,
    this.nextLevel,
    this.nextRankDisplay = '',
    this.nextBadgeIconUrl = '',
    this.dailyXp = 0,
    this.weeklyXp = 0,
  });

  @JsonKey(name: 'total_xp', defaultValue: 0)
  final int totalXp;
  @JsonKey(defaultValue: 0)
  final int level;
  @JsonKey(defaultValue: '')
  final String rank;
  @JsonKey(defaultValue: '')
  final String tier;
  @JsonKey(name: 'rank_display', defaultValue: '')
  final String rankDisplay;
  @JsonKey(name: 'badge_icon_url', defaultValue: '')
  final String badgeIconUrl;
  @JsonKey(name: 'progress_percentage', defaultValue: 0)
  final num progressPercentage;
  @JsonKey(name: 'xp_to_next_level')
  final int? xpToNextLevel;
  @JsonKey(name: 'next_level')
  final int? nextLevel;
  @JsonKey(name: 'next_rank_display', defaultValue: '')
  final String nextRankDisplay;
  @JsonKey(name: 'next_badge_icon_url', defaultValue: '')
  final String nextBadgeIconUrl;
  @JsonKey(name: 'daily_xp', defaultValue: 0)
  final int dailyXp;
  @JsonKey(name: 'weekly_xp', defaultValue: 0)
  final int weeklyXp;

  factory XpOverviewDto.fromJson(Map<String, dynamic> json) =>
      _$XpOverviewDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class XpVelocityDto {
  const XpVelocityDto({
    this.earned7d = 0,
    this.earned30d = 0,
    this.lost7d = 0,
    this.lost30d = 0,
    this.avgDaily7d = 0,
    this.avgDaily30d = 0,
    this.activeDays7d = 0,
    this.activeDays30d = 0,
    this.net7d = 0,
    this.net30d = 0,
  });

  @JsonKey(name: 'earned_7d', defaultValue: 0)
  final int earned7d;
  @JsonKey(name: 'earned_30d', defaultValue: 0)
  final int earned30d;
  @JsonKey(name: 'lost_7d', defaultValue: 0)
  final int lost7d;
  @JsonKey(name: 'lost_30d', defaultValue: 0)
  final int lost30d;
  @JsonKey(name: 'avg_daily_7d', defaultValue: 0)
  final num avgDaily7d;
  @JsonKey(name: 'avg_daily_30d', defaultValue: 0)
  final num avgDaily30d;
  @JsonKey(name: 'active_days_7d', defaultValue: 0)
  final int activeDays7d;
  @JsonKey(name: 'active_days_30d', defaultValue: 0)
  final int activeDays30d;
  @JsonKey(name: 'net_7d', defaultValue: 0)
  final int net7d;
  @JsonKey(name: 'net_30d', defaultValue: 0)
  final int net30d;

  factory XpVelocityDto.fromJson(Map<String, dynamic> json) =>
      _$XpVelocityDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class XpCategoryDto {
  const XpCategoryDto({
    this.category = '',
    this.earned = 0,
    this.count = 0,
    this.percentage = 0,
  });
  @JsonKey(defaultValue: '')
  final String category;
  @JsonKey(defaultValue: 0)
  final int earned;
  @JsonKey(defaultValue: 0)
  final int count;
  @JsonKey(defaultValue: 0)
  final num percentage;
  factory XpCategoryDto.fromJson(Map<String, dynamic> json) =>
      _$XpCategoryDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class XpActionDto {
  const XpActionDto({this.action = '', this.earned = 0, this.count = 0});
  @JsonKey(defaultValue: '')
  final String action;
  @JsonKey(defaultValue: 0)
  final int earned;
  @JsonKey(defaultValue: 0)
  final int count;
  factory XpActionDto.fromJson(Map<String, dynamic> json) =>
      _$XpActionDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class XpPatternsDto {
  const XpPatternsDto({
    this.hourlyXp = const [],
    this.dailyXp = const [],
    this.bestHour,
    this.bestHourLabel = '',
    this.bestDay,
    this.bestDayName = '',
  });
  @JsonKey(name: 'hourly_xp', defaultValue: <num>[])
  final List<num> hourlyXp;
  @JsonKey(name: 'daily_xp', defaultValue: <num>[])
  final List<num> dailyXp;
  @JsonKey(name: 'best_hour')
  final int? bestHour;
  @JsonKey(name: 'best_hour_label', defaultValue: '')
  final String bestHourLabel;
  @JsonKey(name: 'best_day')
  final int? bestDay;
  @JsonKey(name: 'best_day_name', defaultValue: '')
  final String bestDayName;
  factory XpPatternsDto.fromJson(Map<String, dynamic> json) =>
      _$XpPatternsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class XpStreakDto {
  const XpStreakDto({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.milestones = const [],
    this.nextMilestone,
    this.multiplier = 1,
  });
  @JsonKey(name: 'current_streak', defaultValue: 0)
  final int currentStreak;
  @JsonKey(name: 'longest_streak', defaultValue: 0)
  final int longestStreak;
  @JsonKey(defaultValue: <XpStreakMilestoneDto>[])
  final List<XpStreakMilestoneDto> milestones;
  @JsonKey(name: 'next_milestone')
  final XpStreakTargetDto? nextMilestone;
  @JsonKey(defaultValue: 1)
  final num multiplier;
  factory XpStreakDto.fromJson(Map<String, dynamic> json) =>
      _$XpStreakDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class XpStreakMilestoneDto {
  const XpStreakMilestoneDto({
    this.length = 0,
    this.xpAwarded = 0,
    this.reachedAt,
  });
  @JsonKey(defaultValue: 0)
  final int length;
  @JsonKey(name: 'xp_awarded', defaultValue: 0)
  final int xpAwarded;
  @JsonKey(name: 'reached_at')
  final String? reachedAt;
  factory XpStreakMilestoneDto.fromJson(Map<String, dynamic> json) =>
      _$XpStreakMilestoneDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class XpStreakTargetDto {
  const XpStreakTargetDto({this.target = 0, this.daysAway = 0});
  @JsonKey(defaultValue: 0)
  final int target;
  @JsonKey(name: 'days_away', defaultValue: 0)
  final int daysAway;
  factory XpStreakTargetDto.fromJson(Map<String, dynamic> json) =>
      _$XpStreakTargetDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class XpRankDto {
  const XpRankDto({
    this.globalPosition = 0,
    this.globalTotalRanked = 0,
    this.globalPercentile = 0,
  });
  @JsonKey(name: 'global_position', defaultValue: 0)
  final int globalPosition;
  @JsonKey(name: 'global_total_ranked', defaultValue: 0)
  final int globalTotalRanked;
  @JsonKey(name: 'global_percentile', defaultValue: 0)
  final num globalPercentile;
  factory XpRankDto.fromJson(Map<String, dynamic> json) =>
      _$XpRankDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class XpHistoryDto {
  const XpHistoryDto({
    this.labels = const [],
    this.xpTotals = const [],
    this.xpDaily = const [],
    this.levels = const [],
  });
  @JsonKey(defaultValue: <String>[])
  final List<String> labels;
  @JsonKey(name: 'xp_totals', defaultValue: <int>[])
  final List<int> xpTotals;
  @JsonKey(name: 'xp_daily', defaultValue: <int>[])
  final List<int> xpDaily;
  @JsonKey(defaultValue: <int>[])
  final List<int> levels;
  factory XpHistoryDto.fromJson(Map<String, dynamic> json) =>
      _$XpHistoryDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class XpProjectionDto {
  const XpProjectionDto({
    this.daysToNextLevel,
    this.projectedLevel30d = 0,
    this.currentVelocity = 0,
  });
  @JsonKey(name: 'days_to_next_level')
  final int? daysToNextLevel;
  @JsonKey(name: 'projected_level_30d', defaultValue: 0)
  final int projectedLevel30d;
  @JsonKey(name: 'current_velocity', defaultValue: 0)
  final num currentVelocity;
  factory XpProjectionDto.fromJson(Map<String, dynamic> json) =>
      _$XpProjectionDtoFromJson(json);
}

import 'package:equatable/equatable.dart';

/// Top-level response of /api/xp/insights. Each sub-section can be
/// empty for new users — the UI renders nothing rather than crashing.
class XpInsights extends Equatable {
  const XpInsights({
    this.snapshotDate,
    this.overview = const XpOverview(),
    this.velocity = const XpVelocity(),
    this.categoryBreakdown = const [],
    this.topActions = const [],
    this.patterns = const XpPatterns(),
    this.streak = const XpStreak(),
    this.rank = const XpRank(),
    this.history = const XpHistory(),
    this.projection = const XpProjection(),
    this.recommendations = const [],
  });

  final DateTime? snapshotDate;
  final XpOverview overview;
  final XpVelocity velocity;
  final List<XpCategoryEntry> categoryBreakdown;
  final List<XpActionEntry> topActions;
  final XpPatterns patterns;
  final XpStreak streak;
  final XpRank rank;
  final XpHistory history;
  final XpProjection projection;
  final List<String> recommendations;

  @override
  List<Object?> get props => [
        snapshotDate,
        overview,
        velocity,
        categoryBreakdown,
        topActions,
        patterns,
        streak,
        rank,
        history,
        projection,
        recommendations,
      ];
}

class XpOverview extends Equatable {
  const XpOverview({
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

  final int totalXp;
  final int level;
  final String rank;
  final String tier;
  final String rankDisplay;
  final String badgeIconUrl;
  final double progressPercentage;
  final int? xpToNextLevel;
  final int? nextLevel;
  final String nextRankDisplay;
  final String nextBadgeIconUrl;
  final int dailyXp;
  final int weeklyXp;

  @override
  List<Object?> get props => [
        totalXp,
        level,
        rank,
        tier,
        rankDisplay,
        badgeIconUrl,
        progressPercentage,
        xpToNextLevel,
        nextLevel,
        nextRankDisplay,
        nextBadgeIconUrl,
        dailyXp,
        weeklyXp,
      ];
}

class XpVelocity extends Equatable {
  const XpVelocity({
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

  final int earned7d;
  final int earned30d;
  final int lost7d;
  final int lost30d;
  final double avgDaily7d;
  final double avgDaily30d;
  final int activeDays7d;
  final int activeDays30d;
  final int net7d;
  final int net30d;

  @override
  List<Object?> get props => [
        earned7d,
        earned30d,
        lost7d,
        lost30d,
        avgDaily7d,
        avgDaily30d,
        activeDays7d,
        activeDays30d,
        net7d,
        net30d,
      ];
}

class XpCategoryEntry extends Equatable {
  const XpCategoryEntry({
    required this.category,
    this.earned = 0,
    this.count = 0,
    this.percentage = 0,
  });
  final String category;
  final int earned;
  final int count;
  final double percentage;
  @override
  List<Object?> get props => [category, earned, count, percentage];
}

class XpActionEntry extends Equatable {
  const XpActionEntry({
    required this.action,
    this.earned = 0,
    this.count = 0,
  });
  final String action;
  final int earned;
  final int count;
  @override
  List<Object?> get props => [action, earned, count];
}

class XpPatterns extends Equatable {
  const XpPatterns({
    this.hourlyXp = const [],
    this.dailyXp = const [],
    this.bestHour,
    this.bestHourLabel = '',
    this.bestDay,
    this.bestDayName = '',
  });

  /// 24 entries — XP per hour (0-23).
  final List<double> hourlyXp;

  /// 7 entries — XP per weekday (0=Mon by backend).
  final List<double> dailyXp;

  final int? bestHour;
  final String bestHourLabel;
  final int? bestDay;
  final String bestDayName;

  @override
  List<Object?> get props =>
      [hourlyXp, dailyXp, bestHour, bestHourLabel, bestDay, bestDayName];
}

class XpStreak extends Equatable {
  const XpStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.milestones = const [],
    this.nextMilestone,
    this.multiplier = 1,
  });

  final int currentStreak;
  final int longestStreak;
  final List<XpStreakMilestone> milestones;
  final XpStreakTarget? nextMilestone;
  final double multiplier;

  @override
  List<Object?> get props =>
      [currentStreak, longestStreak, milestones, nextMilestone, multiplier];
}

class XpStreakMilestone extends Equatable {
  const XpStreakMilestone({
    this.length = 0,
    this.xpAwarded = 0,
    this.reachedAt,
  });
  final int length;
  final int xpAwarded;
  final DateTime? reachedAt;
  @override
  List<Object?> get props => [length, xpAwarded, reachedAt];
}

class XpStreakTarget extends Equatable {
  const XpStreakTarget({this.target = 0, this.daysAway = 0});
  final int target;
  final int daysAway;
  @override
  List<Object?> get props => [target, daysAway];
}

class XpRank extends Equatable {
  const XpRank({
    this.globalPosition = 0,
    this.globalTotalRanked = 0,
    this.globalPercentile = 0,
  });
  final int globalPosition;
  final int globalTotalRanked;
  final double globalPercentile;
  @override
  List<Object?> get props =>
      [globalPosition, globalTotalRanked, globalPercentile];
}

class XpHistory extends Equatable {
  const XpHistory({
    this.labels = const [],
    this.xpTotals = const [],
    this.xpDaily = const [],
    this.levels = const [],
  });
  final List<String> labels;
  final List<int> xpTotals;
  final List<int> xpDaily;
  final List<int> levels;
  @override
  List<Object?> get props => [labels, xpTotals, xpDaily, levels];
}

class XpProjection extends Equatable {
  const XpProjection({
    this.daysToNextLevel,
    this.projectedLevel30d = 0,
    this.currentVelocity = 0,
  });
  final int? daysToNextLevel;
  final int projectedLevel30d;
  final double currentVelocity;
  @override
  List<Object?> get props =>
      [daysToNextLevel, projectedLevel30d, currentVelocity];
}

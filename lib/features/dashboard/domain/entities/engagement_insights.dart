import 'package:equatable/equatable.dart';

/// Top-level engagement insights — the response of /api/dashboard/insights.
/// Composed of several independent sections so the UI can render and
/// shimmer them piece-by-piece (some sections may be empty for new users).
class EngagementInsights extends Equatable {
  const EngagementInsights({
    this.engagement = const EngagementSummary(),
    this.content = const ContentBreakdown(),
    this.reactions = const ReactionsBreakdown(),
    this.audience = const AudienceBreakdown(),
    this.media = const MediaAnalyticsSummary(),
    this.followers = const FollowersGrowth(),
    this.comparison = const PeriodComparison(),
    this.recommendations = const [],
  });

  final EngagementSummary engagement;
  final ContentBreakdown content;
  final ReactionsBreakdown reactions;
  final AudienceBreakdown audience;
  final MediaAnalyticsSummary media;
  final FollowersGrowth followers;
  final PeriodComparison comparison;
  final List<String> recommendations;

  @override
  List<Object?> get props => [
        engagement,
        content,
        reactions,
        audience,
        media,
        followers,
        comparison,
        recommendations,
      ];
}

class EngagementSummary extends Equatable {
  const EngagementSummary({
    this.engagementRate = 0,
    this.totalEngagement = 0,
    this.totalPosts = 0,
    this.followerCount = 0,
  });

  final double engagementRate;
  final int totalEngagement;
  final int totalPosts;
  final int followerCount;

  @override
  List<Object?> get props =>
      [engagementRate, totalEngagement, totalPosts, followerCount];
}

class ContentBreakdown extends Equatable {
  const ContentBreakdown({
    this.postTypes = const [],
    this.mediaTypes = const [],
    this.topPosts = const [],
    this.bestPostType,
    this.worstPostType,
  });

  final List<PostTypePerformance> postTypes;
  final List<MediaTypePerformance> mediaTypes;
  final List<TopPost> topPosts;
  final TypePerformanceTag? bestPostType;
  final TypePerformanceTag? worstPostType;

  @override
  List<Object?> get props =>
      [postTypes, mediaTypes, topPosts, bestPostType, worstPostType];
}

class PostTypePerformance extends Equatable {
  const PostTypePerformance({
    required this.type,
    this.count = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.engagementRate = 0,
  });

  final String type;
  final int count;
  final int likes;
  final int comments;
  final int shares;
  final int saves;
  final double engagementRate;

  @override
  List<Object?> get props =>
      [type, count, likes, comments, shares, saves, engagementRate];
}

class MediaTypePerformance extends Equatable {
  const MediaTypePerformance({
    required this.type,
    this.count = 0,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.saves = 0,
    this.engagementRate = 0,
    this.avgCompletionRate,
  });

  final String type;
  final int count;
  final int views;
  final int likes;
  final int comments;
  final int saves;
  final double engagementRate;
  final double? avgCompletionRate;

  @override
  List<Object?> get props => [
        type,
        count,
        views,
        likes,
        comments,
        saves,
        engagementRate,
        avgCompletionRate,
      ];
}

class TopPost extends Equatable {
  const TopPost({
    required this.uid,
    this.captionPreview = '',
    this.postType = '',
    this.engagementRate = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
  });

  final String uid;
  final String captionPreview;
  final String postType;
  final double engagementRate;
  final int likes;
  final int comments;
  final int shares;
  final int saves;

  @override
  List<Object?> get props =>
      [uid, captionPreview, postType, engagementRate, likes, comments, shares, saves];
}

class TypePerformanceTag extends Equatable {
  const TypePerformanceTag({required this.type, this.engagementRate = 0});
  final String type;
  final double engagementRate;
  @override
  List<Object?> get props => [type, engagementRate];
}

class ReactionsBreakdown extends Equatable {
  const ReactionsBreakdown({
    this.total = 0,
    this.distribution = const {},
  });

  final int total;

  /// reaction name → count (e.g. {"like": 42, "fire": 7})
  final Map<String, int> distribution;

  @override
  List<Object?> get props => [total, distribution];
}

class AudienceBreakdown extends Equatable {
  const AudienceBreakdown({
    this.segments = const [],
    this.hourlyEngagement = const [],
    this.dailyEngagement = const [],
    this.bestAudience = '',
    this.bestDay,
    this.bestDayName = '',
    this.bestHourLabel = '',
  });

  /// Per-audience-bucket engagement rates ("Followers", "Non-followers", …)
  final List<AudienceSegment> segments;

  /// 24 entries — average engagement at each hour (0-23).
  final List<double> hourlyEngagement;

  /// 7 entries — average engagement on each weekday (0=Mon by backend).
  final List<double> dailyEngagement;

  final String bestAudience;
  final int? bestDay;
  final String bestDayName;
  final String bestHourLabel;

  @override
  List<Object?> get props => [
        segments,
        hourlyEngagement,
        dailyEngagement,
        bestAudience,
        bestDay,
        bestDayName,
        bestHourLabel,
      ];
}

class AudienceSegment extends Equatable {
  const AudienceSegment({
    required this.audience,
    this.count = 0,
    this.engagementRate = 0,
  });
  final String audience;
  final int count;
  final double engagementRate;
  @override
  List<Object?> get props => [audience, count, engagementRate];
}

class MediaAnalyticsSummary extends Equatable {
  const MediaAnalyticsSummary({
    this.totalViews = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.totalSaves = 0,
    this.trend = const MediaTrend(),
    this.trafficSources = const {},
  });

  final int totalViews;
  final int totalLikes;
  final int totalComments;
  final int totalSaves;
  final MediaTrend trend;

  /// source name → view count
  final Map<String, int> trafficSources;

  @override
  List<Object?> get props => [
        totalViews,
        totalLikes,
        totalComments,
        totalSaves,
        trend,
        trafficSources,
      ];
}

class MediaTrend extends Equatable {
  const MediaTrend({
    this.labels = const [],
    this.views = const [],
    this.likes = const [],
    this.comments = const [],
    this.saves = const [],
  });

  /// Date labels (ISO date strings) — aligned with the value arrays below.
  final List<String> labels;
  final List<int> views;
  final List<int> likes;
  final List<int> comments;
  final List<int> saves;

  @override
  List<Object?> get props => [labels, views, likes, comments, saves];
}

class FollowersGrowth extends Equatable {
  const FollowersGrowth({
    this.currentCount = 0,
    this.netChange = 0,
    this.gained = 0,
    this.lost = 0,
    this.growthRatePct = 0,
    this.trend = const FollowersTrend(),
  });

  final int currentCount;
  final int netChange;
  final int gained;
  final int lost;
  final double growthRatePct;
  final FollowersTrend trend;

  @override
  List<Object?> get props =>
      [currentCount, netChange, gained, lost, growthRatePct, trend];
}

class FollowersTrend extends Equatable {
  const FollowersTrend({
    this.labels = const [],
    this.followerCounts = const [],
    this.netChanges = const [],
  });

  final List<String> labels;
  final List<int> followerCounts;
  final List<int> netChanges;

  @override
  List<Object?> get props => [labels, followerCounts, netChanges];
}

class PeriodComparison extends Equatable {
  const PeriodComparison({this.weekly, this.monthly});
  final PeriodSnapshot? weekly;
  final PeriodSnapshot? monthly;
  @override
  List<Object?> get props => [weekly, monthly];
}

class PeriodSnapshot extends Equatable {
  const PeriodSnapshot({
    this.current = const PeriodTotals(),
    this.previous = const PeriodTotals(),
    this.deltas = const PeriodDeltas(),
  });

  final PeriodTotals current;
  final PeriodTotals previous;
  final PeriodDeltas deltas;

  @override
  List<Object?> get props => [current, previous, deltas];
}

class PeriodTotals extends Equatable {
  const PeriodTotals({
    this.posts = 0,
    this.engagement = 0,
    this.followersGained = 0,
    this.mediaViews = 0,
    this.discussions = 0,
  });

  final int posts;
  final int engagement;
  final int followersGained;
  final int mediaViews;
  final int discussions;

  @override
  List<Object?> get props =>
      [posts, engagement, followersGained, mediaViews, discussions];
}

class PeriodDeltas extends Equatable {
  const PeriodDeltas({
    this.postsPct,
    this.engagementPct,
    this.followersPct,
    this.mediaViewsPct,
    this.discussionsPct,
  });

  /// Percent change vs previous period. Null = no baseline (first period).
  final double? postsPct;
  final double? engagementPct;
  final double? followersPct;
  final double? mediaViewsPct;
  final double? discussionsPct;

  @override
  List<Object?> get props =>
      [postsPct, engagementPct, followersPct, mediaViewsPct, discussionsPct];
}

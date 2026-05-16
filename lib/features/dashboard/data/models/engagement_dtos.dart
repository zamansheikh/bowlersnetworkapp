import 'package:json_annotation/json_annotation.dart';

part 'engagement_dtos.g.dart';

@JsonSerializable(createToJson: false)
class EngagementInsightsDto {
  const EngagementInsightsDto({
    this.engagement,
    this.content,
    this.reactions,
    this.audience,
    this.media,
    this.followers,
    this.comparison,
    this.recommendations = const [],
  });

  final EngagementSummaryDto? engagement;
  final ContentBreakdownDto? content;
  final ReactionsBreakdownDto? reactions;
  final AudienceBreakdownDto? audience;
  final MediaAnalyticsDto? media;
  final FollowersGrowthDto? followers;
  final PeriodComparisonDto? comparison;
  @JsonKey(defaultValue: <String>[])
  final List<String> recommendations;

  factory EngagementInsightsDto.fromJson(Map<String, dynamic> json) =>
      _$EngagementInsightsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class EngagementSummaryDto {
  const EngagementSummaryDto({
    this.engagementRate = 0,
    this.totalEngagement = 0,
    this.totalPosts = 0,
    this.followerCount = 0,
  });

  @JsonKey(name: 'engagement_rate', defaultValue: 0)
  final num engagementRate;
  @JsonKey(name: 'total_engagement', defaultValue: 0)
  final int totalEngagement;
  @JsonKey(name: 'total_posts', defaultValue: 0)
  final int totalPosts;
  @JsonKey(name: 'follower_count', defaultValue: 0)
  final int followerCount;

  factory EngagementSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$EngagementSummaryDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ContentBreakdownDto {
  const ContentBreakdownDto({
    this.postTypeBreakdown = const [],
    this.mediaTypeBreakdown = const [],
    this.topPosts = const [],
    this.bestPostType,
    this.worstPostType,
  });

  @JsonKey(name: 'post_type_breakdown', defaultValue: <PostTypeStatDto>[])
  final List<PostTypeStatDto> postTypeBreakdown;
  @JsonKey(name: 'media_type_breakdown', defaultValue: <MediaTypeStatDto>[])
  final List<MediaTypeStatDto> mediaTypeBreakdown;
  @JsonKey(name: 'top_posts', defaultValue: <TopPostDto>[])
  final List<TopPostDto> topPosts;
  @JsonKey(name: 'best_post_type')
  final TypeTagDto? bestPostType;
  @JsonKey(name: 'worst_post_type')
  final TypeTagDto? worstPostType;

  factory ContentBreakdownDto.fromJson(Map<String, dynamic> json) =>
      _$ContentBreakdownDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class PostTypeStatDto {
  const PostTypeStatDto({
    this.type = '',
    this.count = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
    this.engagementRate = 0,
  });

  @JsonKey(defaultValue: '')
  final String type;
  @JsonKey(defaultValue: 0)
  final int count;
  @JsonKey(defaultValue: 0)
  final int likes;
  @JsonKey(defaultValue: 0)
  final int comments;
  @JsonKey(defaultValue: 0)
  final int shares;
  @JsonKey(defaultValue: 0)
  final int saves;
  @JsonKey(name: 'engagement_rate', defaultValue: 0)
  final num engagementRate;

  factory PostTypeStatDto.fromJson(Map<String, dynamic> json) =>
      _$PostTypeStatDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class MediaTypeStatDto {
  const MediaTypeStatDto({
    this.type = '',
    this.count = 0,
    this.views = 0,
    this.likes = 0,
    this.comments = 0,
    this.saves = 0,
    this.engagementRate = 0,
    this.avgCompletionRate,
  });

  @JsonKey(defaultValue: '')
  final String type;
  @JsonKey(defaultValue: 0)
  final int count;
  @JsonKey(defaultValue: 0)
  final int views;
  @JsonKey(defaultValue: 0)
  final int likes;
  @JsonKey(defaultValue: 0)
  final int comments;
  @JsonKey(defaultValue: 0)
  final int saves;
  @JsonKey(name: 'engagement_rate', defaultValue: 0)
  final num engagementRate;
  @JsonKey(name: 'avg_completion_rate')
  final num? avgCompletionRate;

  factory MediaTypeStatDto.fromJson(Map<String, dynamic> json) =>
      _$MediaTypeStatDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TopPostDto {
  const TopPostDto({
    this.uid = '',
    this.captionPreview = '',
    this.postType = '',
    this.engagementRate = 0,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.saves = 0,
  });

  @JsonKey(defaultValue: '')
  final String uid;
  @JsonKey(name: 'caption_preview', defaultValue: '')
  final String captionPreview;
  @JsonKey(name: 'post_type', defaultValue: '')
  final String postType;
  @JsonKey(name: 'engagement_rate', defaultValue: 0)
  final num engagementRate;
  @JsonKey(defaultValue: 0)
  final int likes;
  @JsonKey(defaultValue: 0)
  final int comments;
  @JsonKey(defaultValue: 0)
  final int shares;
  @JsonKey(defaultValue: 0)
  final int saves;

  factory TopPostDto.fromJson(Map<String, dynamic> json) =>
      _$TopPostDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TypeTagDto {
  const TypeTagDto({this.type = '', this.engagementRate = 0});
  @JsonKey(defaultValue: '')
  final String type;
  @JsonKey(name: 'engagement_rate', defaultValue: 0)
  final num engagementRate;
  factory TypeTagDto.fromJson(Map<String, dynamic> json) =>
      _$TypeTagDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ReactionsBreakdownDto {
  const ReactionsBreakdownDto({this.total = 0, this.distribution = const {}});
  @JsonKey(defaultValue: 0)
  final int total;
  @JsonKey(defaultValue: <String, int>{})
  final Map<String, int> distribution;
  factory ReactionsBreakdownDto.fromJson(Map<String, dynamic> json) =>
      _$ReactionsBreakdownDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class AudienceBreakdownDto {
  const AudienceBreakdownDto({
    this.audienceBreakdown = const [],
    this.hourlyEngagement = const [],
    this.dailyEngagement = const [],
    this.bestAudience = '',
    this.bestDay,
    this.bestDayName = '',
    this.bestHourLabel = '',
  });

  @JsonKey(name: 'audience_breakdown', defaultValue: <AudienceSegmentDto>[])
  final List<AudienceSegmentDto> audienceBreakdown;
  @JsonKey(name: 'hourly_engagement', defaultValue: <num>[])
  final List<num> hourlyEngagement;
  @JsonKey(name: 'daily_engagement', defaultValue: <num>[])
  final List<num> dailyEngagement;
  @JsonKey(name: 'best_audience', defaultValue: '')
  final String bestAudience;
  @JsonKey(name: 'best_day')
  final int? bestDay;
  @JsonKey(name: 'best_day_name', defaultValue: '')
  final String bestDayName;
  @JsonKey(name: 'best_hour_label', defaultValue: '')
  final String bestHourLabel;

  factory AudienceBreakdownDto.fromJson(Map<String, dynamic> json) =>
      _$AudienceBreakdownDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class AudienceSegmentDto {
  const AudienceSegmentDto({
    this.audience = '',
    this.count = 0,
    this.engagementRate = 0,
  });
  @JsonKey(defaultValue: '')
  final String audience;
  @JsonKey(defaultValue: 0)
  final int count;
  @JsonKey(name: 'engagement_rate', defaultValue: 0)
  final num engagementRate;
  factory AudienceSegmentDto.fromJson(Map<String, dynamic> json) =>
      _$AudienceSegmentDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class MediaAnalyticsDto {
  const MediaAnalyticsDto({
    this.summary,
    this.trend,
    this.trafficSources = const {},
  });

  final MediaSummaryDto? summary;
  final MediaTrendDto? trend;
  @JsonKey(name: 'traffic_sources', defaultValue: <String, int>{})
  final Map<String, int> trafficSources;

  factory MediaAnalyticsDto.fromJson(Map<String, dynamic> json) =>
      _$MediaAnalyticsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class MediaSummaryDto {
  const MediaSummaryDto({
    this.totalViews = 0,
    this.totalLikes = 0,
    this.totalComments = 0,
    this.totalSaves = 0,
  });
  @JsonKey(name: 'total_views', defaultValue: 0)
  final int totalViews;
  @JsonKey(name: 'total_likes', defaultValue: 0)
  final int totalLikes;
  @JsonKey(name: 'total_comments', defaultValue: 0)
  final int totalComments;
  @JsonKey(name: 'total_saves', defaultValue: 0)
  final int totalSaves;
  factory MediaSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$MediaSummaryDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class MediaTrendDto {
  const MediaTrendDto({
    this.labels = const [],
    this.views = const [],
    this.likes = const [],
    this.comments = const [],
    this.saves = const [],
  });
  @JsonKey(defaultValue: <String>[])
  final List<String> labels;
  @JsonKey(defaultValue: <int>[])
  final List<int> views;
  @JsonKey(defaultValue: <int>[])
  final List<int> likes;
  @JsonKey(defaultValue: <int>[])
  final List<int> comments;
  @JsonKey(defaultValue: <int>[])
  final List<int> saves;
  factory MediaTrendDto.fromJson(Map<String, dynamic> json) =>
      _$MediaTrendDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class FollowersGrowthDto {
  const FollowersGrowthDto({
    this.currentCount = 0,
    this.netChange = 0,
    this.gained = 0,
    this.lost = 0,
    this.growthRatePct = 0,
    this.trend,
  });
  @JsonKey(name: 'current_count', defaultValue: 0)
  final int currentCount;
  @JsonKey(name: 'net_change', defaultValue: 0)
  final int netChange;
  @JsonKey(defaultValue: 0)
  final int gained;
  @JsonKey(defaultValue: 0)
  final int lost;
  @JsonKey(name: 'growth_rate_pct', defaultValue: 0)
  final num growthRatePct;
  final FollowersTrendDto? trend;
  factory FollowersGrowthDto.fromJson(Map<String, dynamic> json) =>
      _$FollowersGrowthDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class FollowersTrendDto {
  const FollowersTrendDto({
    this.labels = const [],
    this.followerCounts = const [],
    this.netChanges = const [],
  });
  @JsonKey(defaultValue: <String>[])
  final List<String> labels;
  @JsonKey(name: 'follower_counts', defaultValue: <int>[])
  final List<int> followerCounts;
  @JsonKey(name: 'net_changes', defaultValue: <int>[])
  final List<int> netChanges;
  factory FollowersTrendDto.fromJson(Map<String, dynamic> json) =>
      _$FollowersTrendDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class PeriodComparisonDto {
  const PeriodComparisonDto({this.weekly, this.monthly});
  final PeriodSnapshotDto? weekly;
  final PeriodSnapshotDto? monthly;
  factory PeriodComparisonDto.fromJson(Map<String, dynamic> json) =>
      _$PeriodComparisonDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class PeriodSnapshotDto {
  const PeriodSnapshotDto({this.current, this.previous, this.deltas});
  final PeriodTotalsDto? current;
  final PeriodTotalsDto? previous;
  final PeriodDeltasDto? deltas;
  factory PeriodSnapshotDto.fromJson(Map<String, dynamic> json) =>
      _$PeriodSnapshotDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class PeriodTotalsDto {
  const PeriodTotalsDto({
    this.posts = 0,
    this.engagement = 0,
    this.followersGained = 0,
    this.mediaViews = 0,
    this.discussions = 0,
  });
  @JsonKey(defaultValue: 0)
  final int posts;
  @JsonKey(defaultValue: 0)
  final int engagement;
  @JsonKey(name: 'followers_gained', defaultValue: 0)
  final int followersGained;
  @JsonKey(name: 'media_views', defaultValue: 0)
  final int mediaViews;
  @JsonKey(defaultValue: 0)
  final int discussions;
  factory PeriodTotalsDto.fromJson(Map<String, dynamic> json) =>
      _$PeriodTotalsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class PeriodDeltasDto {
  const PeriodDeltasDto({
    this.postsPct,
    this.engagementPct,
    this.followersPct,
    this.mediaViewsPct,
    this.discussionsPct,
  });
  @JsonKey(name: 'posts_pct')
  final num? postsPct;
  @JsonKey(name: 'engagement_pct')
  final num? engagementPct;
  @JsonKey(name: 'followers_pct')
  final num? followersPct;
  @JsonKey(name: 'media_views_pct')
  final num? mediaViewsPct;
  @JsonKey(name: 'discussions_pct')
  final num? discussionsPct;
  factory PeriodDeltasDto.fromJson(Map<String, dynamic> json) =>
      _$PeriodDeltasDtoFromJson(json);
}

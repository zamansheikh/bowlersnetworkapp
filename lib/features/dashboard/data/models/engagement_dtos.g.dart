// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engagement_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EngagementInsightsDto _$EngagementInsightsDtoFromJson(
  Map<String, dynamic> json,
) => EngagementInsightsDto(
  engagement: json['engagement'] == null
      ? null
      : EngagementSummaryDto.fromJson(
          json['engagement'] as Map<String, dynamic>,
        ),
  content: json['content'] == null
      ? null
      : ContentBreakdownDto.fromJson(json['content'] as Map<String, dynamic>),
  reactions: json['reactions'] == null
      ? null
      : ReactionsBreakdownDto.fromJson(
          json['reactions'] as Map<String, dynamic>,
        ),
  audience: json['audience'] == null
      ? null
      : AudienceBreakdownDto.fromJson(json['audience'] as Map<String, dynamic>),
  media: json['media'] == null
      ? null
      : MediaAnalyticsDto.fromJson(json['media'] as Map<String, dynamic>),
  followers: json['followers'] == null
      ? null
      : FollowersGrowthDto.fromJson(json['followers'] as Map<String, dynamic>),
  comparison: json['comparison'] == null
      ? null
      : PeriodComparisonDto.fromJson(
          json['comparison'] as Map<String, dynamic>,
        ),
  recommendations:
      (json['recommendations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

EngagementSummaryDto _$EngagementSummaryDtoFromJson(
  Map<String, dynamic> json,
) => EngagementSummaryDto(
  engagementRate: json['engagement_rate'] as num? ?? 0,
  totalEngagement: (json['total_engagement'] as num?)?.toInt() ?? 0,
  totalPosts: (json['total_posts'] as num?)?.toInt() ?? 0,
  followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
);

ContentBreakdownDto _$ContentBreakdownDtoFromJson(Map<String, dynamic> json) =>
    ContentBreakdownDto(
      postTypeBreakdown:
          (json['post_type_breakdown'] as List<dynamic>?)
              ?.map((e) => PostTypeStatDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mediaTypeBreakdown:
          (json['media_type_breakdown'] as List<dynamic>?)
              ?.map((e) => MediaTypeStatDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topPosts:
          (json['top_posts'] as List<dynamic>?)
              ?.map((e) => TopPostDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bestPostType: json['best_post_type'] == null
          ? null
          : TypeTagDto.fromJson(json['best_post_type'] as Map<String, dynamic>),
      worstPostType: json['worst_post_type'] == null
          ? null
          : TypeTagDto.fromJson(
              json['worst_post_type'] as Map<String, dynamic>,
            ),
    );

PostTypeStatDto _$PostTypeStatDtoFromJson(Map<String, dynamic> json) =>
    PostTypeStatDto(
      type: json['type'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      shares: (json['shares'] as num?)?.toInt() ?? 0,
      saves: (json['saves'] as num?)?.toInt() ?? 0,
      engagementRate: json['engagement_rate'] as num? ?? 0,
    );

MediaTypeStatDto _$MediaTypeStatDtoFromJson(Map<String, dynamic> json) =>
    MediaTypeStatDto(
      type: json['type'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as num?)?.toInt() ?? 0,
      saves: (json['saves'] as num?)?.toInt() ?? 0,
      engagementRate: json['engagement_rate'] as num? ?? 0,
      avgCompletionRate: json['avg_completion_rate'] as num?,
    );

TopPostDto _$TopPostDtoFromJson(Map<String, dynamic> json) => TopPostDto(
  uid: json['uid'] as String? ?? '',
  captionPreview: json['caption_preview'] as String? ?? '',
  postType: json['post_type'] as String? ?? '',
  engagementRate: json['engagement_rate'] as num? ?? 0,
  likes: (json['likes'] as num?)?.toInt() ?? 0,
  comments: (json['comments'] as num?)?.toInt() ?? 0,
  shares: (json['shares'] as num?)?.toInt() ?? 0,
  saves: (json['saves'] as num?)?.toInt() ?? 0,
);

TypeTagDto _$TypeTagDtoFromJson(Map<String, dynamic> json) => TypeTagDto(
  type: json['type'] as String? ?? '',
  engagementRate: json['engagement_rate'] as num? ?? 0,
);

ReactionsBreakdownDto _$ReactionsBreakdownDtoFromJson(
  Map<String, dynamic> json,
) => ReactionsBreakdownDto(
  total: (json['total'] as num?)?.toInt() ?? 0,
  distribution:
      (json['distribution'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toInt()),
      ) ??
      {},
);

AudienceBreakdownDto _$AudienceBreakdownDtoFromJson(
  Map<String, dynamic> json,
) => AudienceBreakdownDto(
  audienceBreakdown:
      (json['audience_breakdown'] as List<dynamic>?)
          ?.map((e) => AudienceSegmentDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  hourlyEngagement:
      (json['hourly_engagement'] as List<dynamic>?)
          ?.map((e) => e as num)
          .toList() ??
      [],
  dailyEngagement:
      (json['daily_engagement'] as List<dynamic>?)
          ?.map((e) => e as num)
          .toList() ??
      [],
  bestAudience: json['best_audience'] as String? ?? '',
  bestDay: (json['best_day'] as num?)?.toInt(),
  bestDayName: json['best_day_name'] as String? ?? '',
  bestHourLabel: json['best_hour_label'] as String? ?? '',
);

AudienceSegmentDto _$AudienceSegmentDtoFromJson(Map<String, dynamic> json) =>
    AudienceSegmentDto(
      audience: json['audience'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      engagementRate: json['engagement_rate'] as num? ?? 0,
    );

MediaAnalyticsDto _$MediaAnalyticsDtoFromJson(Map<String, dynamic> json) =>
    MediaAnalyticsDto(
      summary: json['summary'] == null
          ? null
          : MediaSummaryDto.fromJson(json['summary'] as Map<String, dynamic>),
      trend: json['trend'] == null
          ? null
          : MediaTrendDto.fromJson(json['trend'] as Map<String, dynamic>),
      trafficSources:
          (json['traffic_sources'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          {},
    );

MediaSummaryDto _$MediaSummaryDtoFromJson(Map<String, dynamic> json) =>
    MediaSummaryDto(
      totalViews: (json['total_views'] as num?)?.toInt() ?? 0,
      totalLikes: (json['total_likes'] as num?)?.toInt() ?? 0,
      totalComments: (json['total_comments'] as num?)?.toInt() ?? 0,
      totalSaves: (json['total_saves'] as num?)?.toInt() ?? 0,
    );

MediaTrendDto _$MediaTrendDtoFromJson(Map<String, dynamic> json) =>
    MediaTrendDto(
      labels:
          (json['labels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      views:
          (json['views'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      likes:
          (json['likes'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      saves:
          (json['saves'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
    );

FollowersGrowthDto _$FollowersGrowthDtoFromJson(Map<String, dynamic> json) =>
    FollowersGrowthDto(
      currentCount: (json['current_count'] as num?)?.toInt() ?? 0,
      netChange: (json['net_change'] as num?)?.toInt() ?? 0,
      gained: (json['gained'] as num?)?.toInt() ?? 0,
      lost: (json['lost'] as num?)?.toInt() ?? 0,
      growthRatePct: json['growth_rate_pct'] as num? ?? 0,
      trend: json['trend'] == null
          ? null
          : FollowersTrendDto.fromJson(json['trend'] as Map<String, dynamic>),
    );

FollowersTrendDto _$FollowersTrendDtoFromJson(Map<String, dynamic> json) =>
    FollowersTrendDto(
      labels:
          (json['labels'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      followerCounts:
          (json['follower_counts'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      netChanges:
          (json['net_changes'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
    );

PeriodComparisonDto _$PeriodComparisonDtoFromJson(Map<String, dynamic> json) =>
    PeriodComparisonDto(
      weekly: json['weekly'] == null
          ? null
          : PeriodSnapshotDto.fromJson(json['weekly'] as Map<String, dynamic>),
      monthly: json['monthly'] == null
          ? null
          : PeriodSnapshotDto.fromJson(json['monthly'] as Map<String, dynamic>),
    );

PeriodSnapshotDto _$PeriodSnapshotDtoFromJson(Map<String, dynamic> json) =>
    PeriodSnapshotDto(
      current: json['current'] == null
          ? null
          : PeriodTotalsDto.fromJson(json['current'] as Map<String, dynamic>),
      previous: json['previous'] == null
          ? null
          : PeriodTotalsDto.fromJson(json['previous'] as Map<String, dynamic>),
      deltas: json['deltas'] == null
          ? null
          : PeriodDeltasDto.fromJson(json['deltas'] as Map<String, dynamic>),
    );

PeriodTotalsDto _$PeriodTotalsDtoFromJson(Map<String, dynamic> json) =>
    PeriodTotalsDto(
      posts: (json['posts'] as num?)?.toInt() ?? 0,
      engagement: (json['engagement'] as num?)?.toInt() ?? 0,
      followersGained: (json['followers_gained'] as num?)?.toInt() ?? 0,
      mediaViews: (json['media_views'] as num?)?.toInt() ?? 0,
      discussions: (json['discussions'] as num?)?.toInt() ?? 0,
    );

PeriodDeltasDto _$PeriodDeltasDtoFromJson(Map<String, dynamic> json) =>
    PeriodDeltasDto(
      postsPct: json['posts_pct'] as num?,
      engagementPct: json['engagement_pct'] as num?,
      followersPct: json['followers_pct'] as num?,
      mediaViewsPct: json['media_views_pct'] as num?,
      discussionsPct: json['discussions_pct'] as num?,
    );

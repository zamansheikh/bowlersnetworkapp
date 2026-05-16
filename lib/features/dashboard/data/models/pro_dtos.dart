import 'package:json_annotation/json_annotation.dart';

part 'pro_dtos.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Content
// ─────────────────────────────────────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class ProContentDto {
  const ProContentDto({
    this.windowDays = 7,
    this.summary,
    this.topPosts = const [],
    this.topVideos = const [],
    this.topSplits = const [],
    this.topDiscussions = const [],
    this.heatmap = const [],
  });

  @JsonKey(name: 'window_days', defaultValue: 7)
  final int windowDays;
  final ProContentSummaryDto? summary;
  @JsonKey(name: 'top_posts', defaultValue: <ProContentRowDto>[])
  final List<ProContentRowDto> topPosts;
  @JsonKey(name: 'top_videos', defaultValue: <ProContentRowDto>[])
  final List<ProContentRowDto> topVideos;
  @JsonKey(name: 'top_splits', defaultValue: <ProContentRowDto>[])
  final List<ProContentRowDto> topSplits;
  @JsonKey(name: 'top_discussions', defaultValue: <ProContentRowDto>[])
  final List<ProContentRowDto> topDiscussions;

  /// 7×24 matrix — backend returns rows as `List<List<int>>`.
  @JsonKey(defaultValue: <List<int>>[])
  final List<List<int>> heatmap;

  factory ProContentDto.fromJson(Map<String, dynamic> json) =>
      _$ProContentDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProContentSummaryDto {
  const ProContentSummaryDto({
    this.posts = 0,
    this.videos = 0,
    this.splits = 0,
    this.discussions = 0,
    this.total = 0,
  });
  @JsonKey(defaultValue: 0)
  final int posts;
  @JsonKey(defaultValue: 0)
  final int videos;
  @JsonKey(defaultValue: 0)
  final int splits;
  @JsonKey(defaultValue: 0)
  final int discussions;
  @JsonKey(defaultValue: 0)
  final int total;
  factory ProContentSummaryDto.fromJson(Map<String, dynamic> json) =>
      _$ProContentSummaryDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProContentRowDto {
  const ProContentRowDto({
    this.uid = '',
    this.label = '',
    this.createdAt,
    this.impressions = 0,
    this.reach = 0,
    this.engagement = 0,
    this.engagementRate = 0,
    this.previewUrl = '',
    this.previewKind = 'placeholder',
  });
  @JsonKey(defaultValue: '')
  final String uid;
  @JsonKey(defaultValue: '')
  final String label;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(defaultValue: 0)
  final int impressions;
  @JsonKey(defaultValue: 0)
  final int reach;
  @JsonKey(defaultValue: 0)
  final int engagement;
  @JsonKey(name: 'engagement_rate', defaultValue: 0)
  final num engagementRate;
  @JsonKey(name: 'preview_url', defaultValue: '')
  final String previewUrl;
  @JsonKey(name: 'preview_kind', defaultValue: 'placeholder')
  final String previewKind;
  factory ProContentRowDto.fromJson(Map<String, dynamic> json) =>
      _$ProContentRowDtoFromJson(json);
}

// ─────────────────────────────────────────────────────────────────────────────
// Audience
// ─────────────────────────────────────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class ProAudienceDto {
  const ProAudienceDto({
    this.windowDays = 7,
    this.totalFollowers = 0,
    this.newFollowersWindow = 0,
    this.dailyAcquisition = const [],
    this.ageDistribution = const [],
    this.genderDistribution = const [],
    this.skillDistribution = const [],
    this.topCenters = const [],
  });

  @JsonKey(name: 'window_days', defaultValue: 7)
  final int windowDays;
  @JsonKey(name: 'total_followers', defaultValue: 0)
  final int totalFollowers;
  @JsonKey(name: 'new_followers_window', defaultValue: 0)
  final int newFollowersWindow;
  @JsonKey(name: 'daily_acquisition', defaultValue: <DailyCountDto>[])
  final List<DailyCountDto> dailyAcquisition;
  @JsonKey(name: 'age_distribution', defaultValue: <KeyLabelCountDto>[])
  final List<KeyLabelCountDto> ageDistribution;
  @JsonKey(name: 'gender_distribution', defaultValue: <KeyLabelCountDto>[])
  final List<KeyLabelCountDto> genderDistribution;
  @JsonKey(name: 'skill_distribution', defaultValue: <KeyLabelCountDto>[])
  final List<KeyLabelCountDto> skillDistribution;
  @JsonKey(name: 'top_centers', defaultValue: <ProCenterCountDto>[])
  final List<ProCenterCountDto> topCenters;

  factory ProAudienceDto.fromJson(Map<String, dynamic> json) =>
      _$ProAudienceDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class DailyCountDto {
  const DailyCountDto({this.date = '', this.count = 0});
  @JsonKey(defaultValue: '')
  final String date;
  @JsonKey(defaultValue: 0)
  final int count;
  factory DailyCountDto.fromJson(Map<String, dynamic> json) =>
      _$DailyCountDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class KeyLabelCountDto {
  const KeyLabelCountDto({this.key = '', this.label = '', this.count = 0});
  @JsonKey(defaultValue: '')
  final String key;
  @JsonKey(defaultValue: '')
  final String label;
  @JsonKey(defaultValue: 0)
  final int count;
  factory KeyLabelCountDto.fromJson(Map<String, dynamic> json) =>
      _$KeyLabelCountDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProCenterCountDto {
  const ProCenterCountDto({this.centerId, this.name = '', this.count = 0});

  /// Backend types this as `int|str` (some legacy rows use string ids),
  /// so we accept either and coerce to string in the mapper.
  @JsonKey(name: 'center_id')
  final dynamic centerId;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: 0)
  final int count;
  factory ProCenterCountDto.fromJson(Map<String, dynamic> json) =>
      _$ProCenterCountDtoFromJson(json);
}

// ─────────────────────────────────────────────────────────────────────────────
// Referrals
// ─────────────────────────────────────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class ProReferralsDto {
  const ProReferralsDto({
    this.windowDays = 7,
    this.clicks,
    this.referrals,
    this.proAttribution,
  });
  @JsonKey(name: 'window_days', defaultValue: 7)
  final int windowDays;
  final ReferralClicksDto? clicks;
  final ReferralTotalsDto? referrals;
  @JsonKey(name: 'pro_attribution')
  final ProAttributionDto? proAttribution;
  factory ProReferralsDto.fromJson(Map<String, dynamic> json) =>
      _$ProReferralsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ReferralClicksDto {
  const ReferralClicksDto({
    this.totalClicks = 0,
    this.windowClicks = 0,
    this.convertedWindow = 0,
    this.conversionRate = 0,
    this.dailyClicks = const [],
    this.topCountries = const [],
    this.deviceMix = const [],
  });
  @JsonKey(name: 'total_clicks', defaultValue: 0)
  final int totalClicks;
  @JsonKey(name: 'window_clicks', defaultValue: 0)
  final int windowClicks;
  @JsonKey(name: 'converted_window', defaultValue: 0)
  final int convertedWindow;
  @JsonKey(name: 'conversion_rate', defaultValue: 0)
  final num conversionRate;
  @JsonKey(name: 'daily_clicks', defaultValue: <DailyCountDto>[])
  final List<DailyCountDto> dailyClicks;
  @JsonKey(name: 'top_countries', defaultValue: <KeyLabelCountDto>[])
  final List<KeyLabelCountDto> topCountries;
  @JsonKey(name: 'device_mix', defaultValue: <KeyLabelCountDto>[])
  final List<KeyLabelCountDto> deviceMix;
  factory ReferralClicksDto.fromJson(Map<String, dynamic> json) =>
      _$ReferralClicksDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ReferralTotalsDto {
  const ReferralTotalsDto({this.total = 0, this.inWindow = 0});
  @JsonKey(defaultValue: 0)
  final int total;
  @JsonKey(name: 'in_window', defaultValue: 0)
  final int inWindow;
  factory ReferralTotalsDto.fromJson(Map<String, dynamic> json) =>
      _$ReferralTotalsDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ProAttributionDto {
  const ProAttributionDto({
    this.trueCount = 0,
    this.secondaryCount = 0,
    this.shadowCount = 0,
    this.totalCount = 0,
    this.windowCount = 0,
    this.weightedScore = 0,
    this.weightMap,
  });
  @JsonKey(name: 'true_count', defaultValue: 0)
  final int trueCount;
  @JsonKey(name: 'secondary_count', defaultValue: 0)
  final int secondaryCount;
  @JsonKey(name: 'shadow_count', defaultValue: 0)
  final int shadowCount;
  @JsonKey(name: 'total_count', defaultValue: 0)
  final int totalCount;
  @JsonKey(name: 'window_count', defaultValue: 0)
  final int windowCount;
  @JsonKey(name: 'weighted_score', defaultValue: 0)
  final num weightedScore;
  @JsonKey(name: 'weight_map')
  final Map<String, dynamic>? weightMap;
  factory ProAttributionDto.fromJson(Map<String, dynamic> json) =>
      _$ProAttributionDtoFromJson(json);
}

// ─────────────────────────────────────────────────────────────────────────────
// Contribution (Weighted Index)
// ─────────────────────────────────────────────────────────────────────────────

@JsonSerializable(createToJson: false)
class ProContributionDto {
  const ProContributionDto({
    this.hasData = false,
    this.window = '',
    this.date,
    this.poolSize = 0,
    this.rank = 0,
    this.poolPercentage = 0,
    this.personalScore = 0,
    this.contentScore = 0,
    this.socialScore = 0,
    this.growthScore = 0,
    this.deltas,
  });

  @JsonKey(name: 'has_data', defaultValue: false)
  final bool hasData;
  @JsonKey(defaultValue: '')
  final String window;
  final String? date;
  @JsonKey(name: 'pool_size', defaultValue: 0)
  final int poolSize;
  @JsonKey(defaultValue: 0)
  final int rank;
  @JsonKey(name: 'pool_percentage', defaultValue: 0)
  final num poolPercentage;
  @JsonKey(name: 'personal_score', defaultValue: 0)
  final num personalScore;
  @JsonKey(name: 'content_score', defaultValue: 0)
  final num contentScore;
  @JsonKey(name: 'social_score', defaultValue: 0)
  final num socialScore;
  @JsonKey(name: 'growth_score', defaultValue: 0)
  final num growthScore;
  final ContributionDeltasDto? deltas;

  factory ProContributionDto.fromJson(Map<String, dynamic> json) =>
      _$ProContributionDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ContributionDeltasDto {
  const ContributionDeltasDto({
    this.poolPercentageChange,
    this.rankChange,
    this.personalScoreChange,
  });
  @JsonKey(name: 'pool_percentage_change')
  final num? poolPercentageChange;
  @JsonKey(name: 'rank_change')
  final int? rankChange;
  @JsonKey(name: 'personal_score_change')
  final num? personalScoreChange;
  factory ContributionDeltasDto.fromJson(Map<String, dynamic> json) =>
      _$ContributionDeltasDtoFromJson(json);
}

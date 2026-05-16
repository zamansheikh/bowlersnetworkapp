// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pro_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProContentDto _$ProContentDtoFromJson(
  Map<String, dynamic> json,
) => ProContentDto(
  windowDays: (json['window_days'] as num?)?.toInt() ?? 7,
  summary: json['summary'] == null
      ? null
      : ProContentSummaryDto.fromJson(json['summary'] as Map<String, dynamic>),
  topPosts:
      (json['top_posts'] as List<dynamic>?)
          ?.map((e) => ProContentRowDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  topVideos:
      (json['top_videos'] as List<dynamic>?)
          ?.map((e) => ProContentRowDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  topSplits:
      (json['top_splits'] as List<dynamic>?)
          ?.map((e) => ProContentRowDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  topDiscussions:
      (json['top_discussions'] as List<dynamic>?)
          ?.map((e) => ProContentRowDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  heatmap:
      (json['heatmap'] as List<dynamic>?)
          ?.map(
            (e) => (e as List<dynamic>).map((e) => (e as num).toInt()).toList(),
          )
          .toList() ??
      [],
);

ProContentSummaryDto _$ProContentSummaryDtoFromJson(
  Map<String, dynamic> json,
) => ProContentSummaryDto(
  posts: (json['posts'] as num?)?.toInt() ?? 0,
  videos: (json['videos'] as num?)?.toInt() ?? 0,
  splits: (json['splits'] as num?)?.toInt() ?? 0,
  discussions: (json['discussions'] as num?)?.toInt() ?? 0,
  total: (json['total'] as num?)?.toInt() ?? 0,
);

ProContentRowDto _$ProContentRowDtoFromJson(Map<String, dynamic> json) =>
    ProContentRowDto(
      uid: json['uid'] as String? ?? '',
      label: json['label'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      impressions: (json['impressions'] as num?)?.toInt() ?? 0,
      reach: (json['reach'] as num?)?.toInt() ?? 0,
      engagement: (json['engagement'] as num?)?.toInt() ?? 0,
      engagementRate: json['engagement_rate'] as num? ?? 0,
      previewUrl: json['preview_url'] as String? ?? '',
      previewKind: json['preview_kind'] as String? ?? 'placeholder',
    );

ProAudienceDto _$ProAudienceDtoFromJson(Map<String, dynamic> json) =>
    ProAudienceDto(
      windowDays: (json['window_days'] as num?)?.toInt() ?? 7,
      totalFollowers: (json['total_followers'] as num?)?.toInt() ?? 0,
      newFollowersWindow: (json['new_followers_window'] as num?)?.toInt() ?? 0,
      dailyAcquisition:
          (json['daily_acquisition'] as List<dynamic>?)
              ?.map((e) => DailyCountDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ageDistribution:
          (json['age_distribution'] as List<dynamic>?)
              ?.map((e) => KeyLabelCountDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      genderDistribution:
          (json['gender_distribution'] as List<dynamic>?)
              ?.map((e) => KeyLabelCountDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      skillDistribution:
          (json['skill_distribution'] as List<dynamic>?)
              ?.map((e) => KeyLabelCountDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topCenters:
          (json['top_centers'] as List<dynamic>?)
              ?.map(
                (e) => ProCenterCountDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );

DailyCountDto _$DailyCountDtoFromJson(Map<String, dynamic> json) =>
    DailyCountDto(
      date: json['date'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

KeyLabelCountDto _$KeyLabelCountDtoFromJson(Map<String, dynamic> json) =>
    KeyLabelCountDto(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

ProCenterCountDto _$ProCenterCountDtoFromJson(Map<String, dynamic> json) =>
    ProCenterCountDto(
      centerId: json['center_id'],
      name: json['name'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

ProReferralsDto _$ProReferralsDtoFromJson(Map<String, dynamic> json) =>
    ProReferralsDto(
      windowDays: (json['window_days'] as num?)?.toInt() ?? 7,
      clicks: json['clicks'] == null
          ? null
          : ReferralClicksDto.fromJson(json['clicks'] as Map<String, dynamic>),
      referrals: json['referrals'] == null
          ? null
          : ReferralTotalsDto.fromJson(
              json['referrals'] as Map<String, dynamic>,
            ),
      proAttribution: json['pro_attribution'] == null
          ? null
          : ProAttributionDto.fromJson(
              json['pro_attribution'] as Map<String, dynamic>,
            ),
    );

ReferralClicksDto _$ReferralClicksDtoFromJson(Map<String, dynamic> json) =>
    ReferralClicksDto(
      totalClicks: (json['total_clicks'] as num?)?.toInt() ?? 0,
      windowClicks: (json['window_clicks'] as num?)?.toInt() ?? 0,
      convertedWindow: (json['converted_window'] as num?)?.toInt() ?? 0,
      conversionRate: json['conversion_rate'] as num? ?? 0,
      dailyClicks:
          (json['daily_clicks'] as List<dynamic>?)
              ?.map((e) => DailyCountDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topCountries:
          (json['top_countries'] as List<dynamic>?)
              ?.map((e) => KeyLabelCountDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      deviceMix:
          (json['device_mix'] as List<dynamic>?)
              ?.map((e) => KeyLabelCountDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

ReferralTotalsDto _$ReferralTotalsDtoFromJson(Map<String, dynamic> json) =>
    ReferralTotalsDto(
      total: (json['total'] as num?)?.toInt() ?? 0,
      inWindow: (json['in_window'] as num?)?.toInt() ?? 0,
    );

ProAttributionDto _$ProAttributionDtoFromJson(Map<String, dynamic> json) =>
    ProAttributionDto(
      trueCount: (json['true_count'] as num?)?.toInt() ?? 0,
      secondaryCount: (json['secondary_count'] as num?)?.toInt() ?? 0,
      shadowCount: (json['shadow_count'] as num?)?.toInt() ?? 0,
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      windowCount: (json['window_count'] as num?)?.toInt() ?? 0,
      weightedScore: json['weighted_score'] as num? ?? 0,
      weightMap: json['weight_map'] as Map<String, dynamic>?,
    );

ProContributionDto _$ProContributionDtoFromJson(Map<String, dynamic> json) =>
    ProContributionDto(
      hasData: json['has_data'] as bool? ?? false,
      window: json['window'] as String? ?? '',
      date: json['date'] as String?,
      poolSize: (json['pool_size'] as num?)?.toInt() ?? 0,
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      poolPercentage: json['pool_percentage'] as num? ?? 0,
      personalScore: json['personal_score'] as num? ?? 0,
      contentScore: json['content_score'] as num? ?? 0,
      socialScore: json['social_score'] as num? ?? 0,
      growthScore: json['growth_score'] as num? ?? 0,
      deltas: json['deltas'] == null
          ? null
          : ContributionDeltasDto.fromJson(
              json['deltas'] as Map<String, dynamic>,
            ),
    );

ContributionDeltasDto _$ContributionDeltasDtoFromJson(
  Map<String, dynamic> json,
) => ContributionDeltasDto(
  poolPercentageChange: json['pool_percentage_change'] as num?,
  rankChange: (json['rank_change'] as num?)?.toInt(),
  personalScoreChange: json['personal_score_change'] as num?,
);

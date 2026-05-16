import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/alpha_score.dart';
import '../../domain/entities/dashboard_range.dart';
import '../../domain/entities/engagement_insights.dart';
import '../../domain/entities/games_insights.dart';
import '../../domain/entities/pro_audience.dart';
import '../../domain/entities/pro_content.dart';
import '../../domain/entities/pro_contribution.dart';
import '../../domain/entities/pro_referrals.dart';
import '../../domain/entities/xp_insights.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/engagement_dtos.dart';
import '../models/games_dtos.dart';
import '../models/pro_dtos.dart';
import '../models/xp_dtos.dart';

@LazySingleton(as: DashboardRepository)
class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._remote);

  final DashboardRemoteDatasource _remote;

  // ── Engagement ───────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, EngagementInsights>> getEngagementInsights({
    required DashboardRange range,
  }) =>
      _guard(() async {
        final dto = await _remote.getInsights(range: range.wire);
        return _toEngagement(dto);
      });

  @override
  Future<Either<Failure, AlphaScore>> getAlphaScore({
    required DashboardRange range,
  }) =>
      _guard(() async {
        final dto = await _remote.getAlphaScore(range: range.wire);
        return AlphaScore(
          score: dto.alphaScore,
          impactLevel: dto.impactLevel,
          tips: dto.tips
              .map((t) => AlphaTip(text: t.text, action: t.action))
              .toList(growable: false),
        );
      });

  // ── XP ───────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, XpInsights>> getXpInsights({
    required DashboardRange range,
  }) =>
      _guard(() async {
        final dto = await _remote.getXpInsights(range: range.wire);
        return _toXp(dto);
      });

  // ── Games ────────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, GamesReport>> getGamesReport({DateTime? month}) =>
      _guard(() async {
        // YYYY-MM-DD matching the backend's expected format. Pass null
        // when month is null so the backend defaults to the previous month.
        final monthParam = month == null
            ? null
            : '${month.year.toString().padLeft(4, '0')}-'
                '${month.month.toString().padLeft(2, '0')}-01';
        final dto = await _remote.getGamesReport(month: monthParam);
        return _toGamesReport(dto);
      });

  @override
  Future<Either<Failure, GamesTrends>> getGamesTrends({
    required DashboardRange range,
  }) =>
      _guard(() async {
        final dto = await _remote.getGamesTrends(range: range.wire);
        return GamesTrends(
          labels: List<String>.from(dto.labels),
          averages:
              dto.averages.map((n) => n.toDouble()).toList(growable: false),
          strikePcts: dto.strikePcts
              .map((n) => n.toDouble())
              .toList(growable: false),
          spareRates: dto.spareRates
              .map((n) => n.toDouble())
              .toList(growable: false),
        );
      });

  // ── Mappers ──────────────────────────────────────────────────────────────

  EngagementInsights _toEngagement(EngagementInsightsDto dto) {
    return EngagementInsights(
      engagement: dto.engagement == null
          ? const EngagementSummary()
          : EngagementSummary(
              engagementRate: dto.engagement!.engagementRate.toDouble(),
              totalEngagement: dto.engagement!.totalEngagement,
              totalPosts: dto.engagement!.totalPosts,
              followerCount: dto.engagement!.followerCount,
            ),
      content: dto.content == null
          ? const ContentBreakdown()
          : _toContent(dto.content!),
      reactions: dto.reactions == null
          ? const ReactionsBreakdown()
          : ReactionsBreakdown(
              total: dto.reactions!.total,
              distribution: Map<String, int>.from(dto.reactions!.distribution),
            ),
      audience: dto.audience == null
          ? const AudienceBreakdown()
          : _toAudience(dto.audience!),
      media: dto.media == null
          ? const MediaAnalyticsSummary()
          : _toMedia(dto.media!),
      followers: dto.followers == null
          ? const FollowersGrowth()
          : _toFollowers(dto.followers!),
      comparison: dto.comparison == null
          ? const PeriodComparison()
          : PeriodComparison(
              weekly: _toSnapshot(dto.comparison!.weekly),
              monthly: _toSnapshot(dto.comparison!.monthly),
            ),
      recommendations: List<String>.from(dto.recommendations),
    );
  }

  ContentBreakdown _toContent(ContentBreakdownDto dto) => ContentBreakdown(
        postTypes: dto.postTypeBreakdown
            .map((p) => PostTypePerformance(
                  type: p.type,
                  count: p.count,
                  likes: p.likes,
                  comments: p.comments,
                  shares: p.shares,
                  saves: p.saves,
                  engagementRate: p.engagementRate.toDouble(),
                ))
            .toList(growable: false),
        mediaTypes: dto.mediaTypeBreakdown
            .map((m) => MediaTypePerformance(
                  type: m.type,
                  count: m.count,
                  views: m.views,
                  likes: m.likes,
                  comments: m.comments,
                  saves: m.saves,
                  engagementRate: m.engagementRate.toDouble(),
                  avgCompletionRate: m.avgCompletionRate?.toDouble(),
                ))
            .toList(growable: false),
        topPosts: dto.topPosts
            .map((t) => TopPost(
                  uid: t.uid,
                  captionPreview: t.captionPreview,
                  postType: t.postType,
                  engagementRate: t.engagementRate.toDouble(),
                  likes: t.likes,
                  comments: t.comments,
                  shares: t.shares,
                  saves: t.saves,
                ))
            .toList(growable: false),
        bestPostType: dto.bestPostType == null
            ? null
            : TypePerformanceTag(
                type: dto.bestPostType!.type,
                engagementRate: dto.bestPostType!.engagementRate.toDouble(),
              ),
        worstPostType: dto.worstPostType == null
            ? null
            : TypePerformanceTag(
                type: dto.worstPostType!.type,
                engagementRate: dto.worstPostType!.engagementRate.toDouble(),
              ),
      );

  AudienceBreakdown _toAudience(AudienceBreakdownDto dto) => AudienceBreakdown(
        segments: dto.audienceBreakdown
            .map((s) => AudienceSegment(
                  audience: s.audience,
                  count: s.count,
                  engagementRate: s.engagementRate.toDouble(),
                ))
            .toList(growable: false),
        hourlyEngagement: dto.hourlyEngagement
            .map((n) => n.toDouble())
            .toList(growable: false),
        dailyEngagement: dto.dailyEngagement
            .map((n) => n.toDouble())
            .toList(growable: false),
        bestAudience: dto.bestAudience,
        bestDay: dto.bestDay,
        bestDayName: dto.bestDayName,
        bestHourLabel: dto.bestHourLabel,
      );

  MediaAnalyticsSummary _toMedia(MediaAnalyticsDto dto) =>
      MediaAnalyticsSummary(
        totalViews: dto.summary?.totalViews ?? 0,
        totalLikes: dto.summary?.totalLikes ?? 0,
        totalComments: dto.summary?.totalComments ?? 0,
        totalSaves: dto.summary?.totalSaves ?? 0,
        trend: dto.trend == null
            ? const MediaTrend()
            : MediaTrend(
                labels: List<String>.from(dto.trend!.labels),
                views: List<int>.from(dto.trend!.views),
                likes: List<int>.from(dto.trend!.likes),
                comments: List<int>.from(dto.trend!.comments),
                saves: List<int>.from(dto.trend!.saves),
              ),
        trafficSources: Map<String, int>.from(dto.trafficSources),
      );

  FollowersGrowth _toFollowers(FollowersGrowthDto dto) => FollowersGrowth(
        currentCount: dto.currentCount,
        netChange: dto.netChange,
        gained: dto.gained,
        lost: dto.lost,
        growthRatePct: dto.growthRatePct.toDouble(),
        trend: dto.trend == null
            ? const FollowersTrend()
            : FollowersTrend(
                labels: List<String>.from(dto.trend!.labels),
                followerCounts: List<int>.from(dto.trend!.followerCounts),
                netChanges: List<int>.from(dto.trend!.netChanges),
              ),
      );

  PeriodSnapshot? _toSnapshot(PeriodSnapshotDto? dto) {
    if (dto == null) return null;
    return PeriodSnapshot(
      current: _toTotals(dto.current),
      previous: _toTotals(dto.previous),
      deltas: _toDeltas(dto.deltas),
    );
  }

  PeriodTotals _toTotals(PeriodTotalsDto? dto) {
    if (dto == null) return const PeriodTotals();
    return PeriodTotals(
      posts: dto.posts,
      engagement: dto.engagement,
      followersGained: dto.followersGained,
      mediaViews: dto.mediaViews,
      discussions: dto.discussions,
    );
  }

  // ── Pro tabs ─────────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ProContent>> getProContent({
    required DashboardRange window,
  }) =>
      _guard(() async {
        final dto = await _remote.getProContent(window: window.wire);
        return _toProContent(dto);
      });

  @override
  Future<Either<Failure, ProAudience>> getProAudience({
    required DashboardRange window,
  }) =>
      _guard(() async {
        final dto = await _remote.getProAudience(window: window.wire);
        return _toProAudience(dto);
      });

  @override
  Future<Either<Failure, ProReferrals>> getProReferrals({
    required DashboardRange window,
  }) =>
      _guard(() async {
        final dto = await _remote.getProReferrals(window: window.wire);
        return _toProReferrals(dto);
      });

  @override
  Future<Either<Failure, ProContribution>> getProContribution({
    required DashboardRange window,
  }) =>
      _guard(() async {
        final dto = await _remote.getProContribution(window: window.wire);
        return _toProContribution(dto);
      });

  ProContent _toProContent(ProContentDto dto) {
    ProContentRow rowOf(ProContentRowDto r) => ProContentRow(
          uid: r.uid,
          label: r.label,
          createdAt:
              r.createdAt == null ? null : DateTime.tryParse(r.createdAt!),
          impressions: r.impressions,
          reach: r.reach,
          engagement: r.engagement,
          engagementRate: r.engagementRate.toDouble(),
          previewUrl: r.previewUrl,
          previewKind: r.previewKind,
        );
    return ProContent(
      windowDays: dto.windowDays,
      summary: dto.summary == null
          ? const ProContentSummary()
          : ProContentSummary(
              posts: dto.summary!.posts,
              videos: dto.summary!.videos,
              splits: dto.summary!.splits,
              discussions: dto.summary!.discussions,
              total: dto.summary!.total,
            ),
      topPosts: dto.topPosts.map(rowOf).toList(growable: false),
      topVideos: dto.topVideos.map(rowOf).toList(growable: false),
      topSplits: dto.topSplits.map(rowOf).toList(growable: false),
      topDiscussions:
          dto.topDiscussions.map(rowOf).toList(growable: false),
      heatmap: dto.heatmap
          .map((row) => List<int>.from(row))
          .toList(growable: false),
    );
  }

  ProAudience _toProAudience(ProAudienceDto dto) {
    return ProAudience(
      windowDays: dto.windowDays,
      totalFollowers: dto.totalFollowers,
      newFollowersWindow: dto.newFollowersWindow,
      dailyAcquisition: dto.dailyAcquisition
          .map((d) => DailyCount(date: d.date, count: d.count))
          .toList(growable: false),
      ageDistribution: dto.ageDistribution
          .map((k) => KeyLabelCount(
                key: k.key,
                label: k.label,
                count: k.count,
              ))
          .toList(growable: false),
      genderDistribution: dto.genderDistribution
          .map((k) => KeyLabelCount(
                key: k.key,
                label: k.label,
                count: k.count,
              ))
          .toList(growable: false),
      skillDistribution: dto.skillDistribution
          .map((k) => KeyLabelCount(
                key: k.key,
                label: k.label,
                count: k.count,
              ))
          .toList(growable: false),
      topCenters: dto.topCenters
          .map((c) => ProCenterCount(
                // Coerce int|str ids to string so the UI doesn't branch.
                centerId: c.centerId == null ? '' : c.centerId.toString(),
                name: c.name,
                count: c.count,
              ))
          .toList(growable: false),
    );
  }

  ProReferrals _toProReferrals(ProReferralsDto dto) {
    return ProReferrals(
      windowDays: dto.windowDays,
      clicks: dto.clicks == null
          ? const ReferralClicks()
          : ReferralClicks(
              totalClicks: dto.clicks!.totalClicks,
              windowClicks: dto.clicks!.windowClicks,
              convertedWindow: dto.clicks!.convertedWindow,
              conversionRate: dto.clicks!.conversionRate.toDouble(),
              dailyClicks: dto.clicks!.dailyClicks
                  .map((d) => DailyCount(date: d.date, count: d.count))
                  .toList(growable: false),
              topCountries: dto.clicks!.topCountries
                  .map((k) => KeyLabelCount(
                        key: k.key,
                        label: k.label,
                        count: k.count,
                      ))
                  .toList(growable: false),
              deviceMix: dto.clicks!.deviceMix
                  .map((k) => KeyLabelCount(
                        key: k.key,
                        label: k.label,
                        count: k.count,
                      ))
                  .toList(growable: false),
            ),
      referrals: dto.referrals == null
          ? const ReferralTotals()
          : ReferralTotals(
              total: dto.referrals!.total,
              inWindow: dto.referrals!.inWindow,
            ),
      proAttribution: dto.proAttribution == null
          ? null
          : ProAttribution(
              trueCount: dto.proAttribution!.trueCount,
              secondaryCount: dto.proAttribution!.secondaryCount,
              shadowCount: dto.proAttribution!.shadowCount,
              totalCount: dto.proAttribution!.totalCount,
              windowCount: dto.proAttribution!.windowCount,
              weightedScore: dto.proAttribution!.weightedScore.toDouble(),
              weightMap: _toWeights(dto.proAttribution!.weightMap),
            ),
    );
  }

  ProAttributionWeights _toWeights(Map<String, dynamic>? map) {
    if (map == null) return const ProAttributionWeights();
    double pick(String key) {
      final v = map[key];
      if (v is num) return v.toDouble();
      return 0;
    }
    return ProAttributionWeights(
      trueWeight: pick('true'),
      secondaryWeight: pick('secondary'),
      shadowWeight: pick('shadow'),
    );
  }

  ProContribution _toProContribution(ProContributionDto dto) {
    return ProContribution(
      hasData: dto.hasData,
      window: dto.window,
      date: dto.date == null ? null : DateTime.tryParse(dto.date!),
      poolSize: dto.poolSize,
      rank: dto.rank,
      poolPercentage: dto.poolPercentage.toDouble(),
      personalScore: dto.personalScore.toDouble(),
      contentScore: dto.contentScore.toDouble(),
      socialScore: dto.socialScore.toDouble(),
      growthScore: dto.growthScore.toDouble(),
      deltas: dto.deltas == null
          ? const ContributionDeltas()
          : ContributionDeltas(
              poolPercentageChange:
                  dto.deltas!.poolPercentageChange?.toDouble(),
              rankChange: dto.deltas!.rankChange,
              personalScoreChange:
                  dto.deltas!.personalScoreChange?.toDouble(),
            ),
    );
  }

  XpInsights _toXp(XpInsightsDto dto) => XpInsights(
        snapshotDate: dto.snapshotDate == null
            ? null
            : DateTime.tryParse(dto.snapshotDate!),
        overview: dto.overview == null
            ? const XpOverview()
            : XpOverview(
                totalXp: dto.overview!.totalXp,
                level: dto.overview!.level,
                rank: dto.overview!.rank,
                tier: dto.overview!.tier,
                rankDisplay: dto.overview!.rankDisplay,
                badgeIconUrl: dto.overview!.badgeIconUrl,
                progressPercentage:
                    dto.overview!.progressPercentage.toDouble(),
                xpToNextLevel: dto.overview!.xpToNextLevel,
                nextLevel: dto.overview!.nextLevel,
                nextRankDisplay: dto.overview!.nextRankDisplay,
                nextBadgeIconUrl: dto.overview!.nextBadgeIconUrl,
                dailyXp: dto.overview!.dailyXp,
                weeklyXp: dto.overview!.weeklyXp,
              ),
        velocity: dto.velocity == null
            ? const XpVelocity()
            : XpVelocity(
                earned7d: dto.velocity!.earned7d,
                earned30d: dto.velocity!.earned30d,
                lost7d: dto.velocity!.lost7d,
                lost30d: dto.velocity!.lost30d,
                avgDaily7d: dto.velocity!.avgDaily7d.toDouble(),
                avgDaily30d: dto.velocity!.avgDaily30d.toDouble(),
                activeDays7d: dto.velocity!.activeDays7d,
                activeDays30d: dto.velocity!.activeDays30d,
                net7d: dto.velocity!.net7d,
                net30d: dto.velocity!.net30d,
              ),
        categoryBreakdown: dto.categoryBreakdown
            .map((c) => XpCategoryEntry(
                  category: c.category,
                  earned: c.earned,
                  count: c.count,
                  percentage: c.percentage.toDouble(),
                ))
            .toList(growable: false),
        topActions: dto.topActions
            .map((a) => XpActionEntry(
                  action: a.action,
                  earned: a.earned,
                  count: a.count,
                ))
            .toList(growable: false),
        patterns: dto.patterns == null
            ? const XpPatterns()
            : XpPatterns(
                hourlyXp: dto.patterns!.hourlyXp
                    .map((n) => n.toDouble())
                    .toList(growable: false),
                dailyXp: dto.patterns!.dailyXp
                    .map((n) => n.toDouble())
                    .toList(growable: false),
                bestHour: dto.patterns!.bestHour,
                bestHourLabel: dto.patterns!.bestHourLabel,
                bestDay: dto.patterns!.bestDay,
                bestDayName: dto.patterns!.bestDayName,
              ),
        streak: dto.streak == null
            ? const XpStreak()
            : XpStreak(
                currentStreak: dto.streak!.currentStreak,
                longestStreak: dto.streak!.longestStreak,
                milestones: dto.streak!.milestones
                    .map((m) => XpStreakMilestone(
                          length: m.length,
                          xpAwarded: m.xpAwarded,
                          reachedAt: m.reachedAt == null
                              ? null
                              : DateTime.tryParse(m.reachedAt!),
                        ))
                    .toList(growable: false),
                nextMilestone: dto.streak!.nextMilestone == null
                    ? null
                    : XpStreakTarget(
                        target: dto.streak!.nextMilestone!.target,
                        daysAway: dto.streak!.nextMilestone!.daysAway,
                      ),
                multiplier: dto.streak!.multiplier.toDouble(),
              ),
        rank: dto.rank == null
            ? const XpRank()
            : XpRank(
                globalPosition: dto.rank!.globalPosition,
                globalTotalRanked: dto.rank!.globalTotalRanked,
                globalPercentile: dto.rank!.globalPercentile.toDouble(),
              ),
        history: dto.history == null
            ? const XpHistory()
            : XpHistory(
                labels: List<String>.from(dto.history!.labels),
                xpTotals: List<int>.from(dto.history!.xpTotals),
                xpDaily: List<int>.from(dto.history!.xpDaily),
                levels: List<int>.from(dto.history!.levels),
              ),
        projection: dto.projection == null
            ? const XpProjection()
            : XpProjection(
                daysToNextLevel: dto.projection!.daysToNextLevel,
                projectedLevel30d: dto.projection!.projectedLevel30d,
                currentVelocity: dto.projection!.currentVelocity.toDouble(),
              ),
        recommendations: List<String>.from(dto.recommendations),
      );

  GamesReport _toGamesReport(GamesReportDto dto) {
    // Milestones may come as strings or `{text: ..., ...}` objects.
    // Coerce each to a display string so the UI doesn't have to branch.
    final milestones = dto.milestones.map((m) {
      if (m is String) return m;
      if (m is Map) {
        return (m['text'] ?? m['label'] ?? m['name'] ?? '').toString();
      }
      return m.toString();
    }).where((s) => s.isNotEmpty).toList(growable: false);
    return GamesReport(
      month: dto.month == null ? null : DateTime.tryParse(dto.month!),
      gamesBowled: dto.gamesBowled,
      average: dto.average.toDouble(),
      highGame: dto.highGame,
      highSeries: dto.highSeries,
      strikePercentage: dto.strikePercentage.toDouble(),
      spareConversionRate: dto.spareConversionRate.toDouble(),
      previousMonthAverage: dto.previousMonthAverage?.toDouble(),
      strengths: List<String>.from(dto.strengths),
      improvements: List<String>.from(dto.improvements),
      practicePriorities: List<String>.from(dto.practicePriorities),
      milestones: milestones,
    );
  }

  PeriodDeltas _toDeltas(PeriodDeltasDto? dto) {
    if (dto == null) return const PeriodDeltas();
    return PeriodDeltas(
      postsPct: dto.postsPct?.toDouble(),
      engagementPct: dto.engagementPct?.toDouble(),
      followersPct: dto.followersPct?.toDouble(),
      mediaViewsPct: dto.mediaViewsPct?.toDouble(),
      discussionsPct: dto.discussionsPct?.toDouble(),
    );
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DioException catch (e) {
      final parsed = e.error;
      if (parsed is NetworkException) return const Left(NetworkFailure());
      if (parsed is ApiException) {
        if (parsed.statusCode == 401) {
          return Left(UnauthorizedFailure(messages: parsed.messages));
        }
        return Left(ServerFailure(
          messages: parsed.messages,
          statusCode: parsed.statusCode,
        ));
      }
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}

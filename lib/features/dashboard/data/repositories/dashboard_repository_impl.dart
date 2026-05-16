import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/alpha_score.dart';
import '../../domain/entities/dashboard_range.dart';
import '../../domain/entities/engagement_insights.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import '../models/engagement_dtos.dart';

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

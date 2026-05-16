import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/alpha_dtos.dart';
import '../models/engagement_dtos.dart';
import '../models/games_dtos.dart';
import '../models/pro_dtos.dart';
import '../models/xp_dtos.dart';

part 'dashboard_remote_datasource.g.dart';

/// Wire to `/api/dashboard/*` and `/api/pro/*` endpoints. All queries
/// take a single `range` (7d/30d/90d/365d) or `window` (7d/30d for pro)
/// param — backend returns zero-filled structures for users with no data.
///
/// Methods are added in tandem with their feature tabs:
///   * Batch 1 — Engagement (insights + alpha)
///   * Batch 2 — XP, Games
///   * Batch 3 — Pro (content, audience, referrals, contribution)
@injectable
@RestApi()
abstract class DashboardRemoteDatasource {
  @factoryMethod
  factory DashboardRemoteDatasource(Dio dio) = _DashboardRemoteDatasource;

  // ── Engagement (free) ─────────────────────────────────────────────────────

  @GET(Endpoints.dashboardInsights)
  Future<EngagementInsightsDto> getInsights({
    @Query('range') String? range,
  });

  @GET(Endpoints.dashboardInsightsAlpha)
  Future<AlphaScoreDto> getAlphaScore({
    @Query('range') String? range,
  });

  // ── XP tab (free) ─────────────────────────────────────────────────────────

  @GET(Endpoints.dashboardXpInsights)
  Future<XpInsightsDto> getXpInsights({
    @Query('range') String? range,
  });

  // ── Games tab (free) ──────────────────────────────────────────────────────

  /// `month` is a YYYY-MM-DD string (the 1st of any month). Omit to get
  /// the previous month — backend default.
  @GET(Endpoints.dashboardGamesReport)
  Future<GamesReportDto> getGamesReport({
    @Query('month') String? month,
  });

  @GET(Endpoints.dashboardGamesTrends)
  Future<GamesTrendsDto> getGamesTrends({
    @Query('range') String? range,
  });

  // ── Pro tabs (require Profile.isPro — backend returns 403 otherwise) ─────
  // All accept `window` of 7d or 30d. Don't call these from the bloc unless
  // you've confirmed the viewer is pro.

  @GET(Endpoints.dashboardProContent)
  Future<ProContentDto> getProContent({
    @Query('window') String? window,
  });

  @GET(Endpoints.dashboardProAudience)
  Future<ProAudienceDto> getProAudience({
    @Query('window') String? window,
  });

  @GET(Endpoints.dashboardProReferrals)
  Future<ProReferralsDto> getProReferrals({
    @Query('window') String? window,
  });

  @GET(Endpoints.dashboardProContribution)
  Future<ProContributionDto> getProContribution({
    @Query('window') String? window,
  });
}

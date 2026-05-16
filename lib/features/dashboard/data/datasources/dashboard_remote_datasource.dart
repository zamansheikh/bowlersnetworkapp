import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/alpha_dtos.dart';
import '../models/engagement_dtos.dart';

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
}

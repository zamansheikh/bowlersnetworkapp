import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/alpha_score.dart';
import '../entities/dashboard_range.dart';
import '../entities/engagement_insights.dart';

/// Domain-facing dashboard API. Each method maps 1:1 with a single
/// endpoint — composition into per-tab payloads happens in the bloc.
abstract class DashboardRepository {
  // ── Engagement tab (free) ────────────────────────────────────────────────

  Future<Either<Failure, EngagementInsights>> getEngagementInsights({
    required DashboardRange range,
  });

  Future<Either<Failure, AlphaScore>> getAlphaScore({
    required DashboardRange range,
  });
}

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/alpha_score.dart';
import '../entities/dashboard_range.dart';
import '../entities/engagement_insights.dart';
import '../entities/games_insights.dart';
import '../entities/xp_insights.dart';

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

  // ── XP tab (free) ────────────────────────────────────────────────────────

  Future<Either<Failure, XpInsights>> getXpInsights({
    required DashboardRange range,
  });

  // ── Games tab (free) ─────────────────────────────────────────────────────

  /// Pass [month] as a DateTime for the 1st of any month. Null = the
  /// previous month (backend default).
  Future<Either<Failure, GamesReport>> getGamesReport({DateTime? month});

  Future<Either<Failure, GamesTrends>> getGamesTrends({
    required DashboardRange range,
  });
}

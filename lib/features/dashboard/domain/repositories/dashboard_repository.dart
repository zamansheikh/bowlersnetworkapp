import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/alpha_score.dart';
import '../entities/dashboard_range.dart';
import '../entities/engagement_insights.dart';
import '../entities/games_insights.dart';
import '../entities/pro_audience.dart';
import '../entities/pro_content.dart';
import '../entities/pro_contribution.dart';
import '../entities/pro_referrals.dart';
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

  // ── Pro tabs (require viewer.isPro) ──────────────────────────────────────
  // [window] is restricted server-side to 7d / 30d. Use
  // [DashboardRange.proSafeFallback] before calling.

  Future<Either<Failure, ProContent>> getProContent({
    required DashboardRange window,
  });

  Future<Either<Failure, ProAudience>> getProAudience({
    required DashboardRange window,
  });

  Future<Either<Failure, ProReferrals>> getProReferrals({
    required DashboardRange window,
  });

  Future<Either<Failure, ProContribution>> getProContribution({
    required DashboardRange window,
  });
}

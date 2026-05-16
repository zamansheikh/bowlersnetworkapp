import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/equipment.dart';
import '../entities/game_detail.dart';
import '../entities/session.dart';
import '../entities/stats_detail.dart';
import '../entities/user_game_stats.dart';

abstract class GamesRepository {
  Future<Either<Failure, List<Session>>> getSessions({
    int? page,
    int pageSize = 20,
  });

  Future<Either<Failure, UserGameStats>> getStats();

  Future<Either<Failure, Session>> getSession(String uid);

  Future<Either<Failure, GameDetail>> getGame(int id);

  /// Spin up a new session. Backend fills defaults; metadata can be patched
  /// later if/when we ship the metadata editor.
  Future<Either<Failure, Session>> createSession();

  /// Submit a completed game's 10 frames to [sessionUid]. Returns the
  /// server-computed game detail (with frame breakdown + flags).
  Future<Either<Failure, GameDetail>> submitGame({
    required String sessionUid,
    required List<SubmitFramePayload> frames,
    required String handedness,
    int? totalScore,
  });

  Future<Either<Failure, Unit>> deleteSession(String uid);

  Future<Either<Failure, Unit>> deleteGame(int id);

  // ── Equipment ─────────────────────────────────────────────────────────────
  Future<Either<Failure, List<UserBall>>> getEquipment();

  Future<Either<Failure, List<BallStats>>> getEquipmentStats();

  Future<Either<Failure, UserBall>> addEquipment({
    required int ballId,
    required int weight,
  });

  Future<Either<Failure, Unit>> deleteEquipment(int userBallId);

  /// Ball-catalog search used by the picker modal.
  Future<Either<Failure, ({List<CatalogBall> balls, bool hasNext})>>
      searchBallCatalog({
    String? search,
    int page = 1,
    int pageSize = 24,
  });

  // ── Stats sub-resources ───────────────────────────────────────────────────
  Future<Either<Failure, List<PinLeaveStat>>> getPinLeaveStats();

  Future<Either<Failure, List<SpareCategoryStat>>> getSpareStats();

  Future<Either<Failure, List<TrendPoint>>> getTrendStats({int rangeDays = 30});

  Future<Either<Failure, List<CenterPerformance>>> getStatsByCenter();

  Future<Either<Failure, List<ContextPerformance>>> getStatsByContext();
}

/// Per-frame payload the bloc / repo build before submitting a game.
class SubmitFramePayload {
  const SubmitFramePayload({
    required this.frameNumber,
    required this.ball1Standing,
    this.ball2Standing,
    this.ball3Standing,
    this.ball1EquipmentId,
    this.ball2EquipmentId,
    this.ball3EquipmentId,
  });

  final int frameNumber;
  final List<int> ball1Standing;
  final List<int>? ball2Standing;
  final List<int>? ball3Standing;
  final int? ball1EquipmentId;
  final int? ball2EquipmentId;
  final int? ball3EquipmentId;

  Map<String, dynamic> toJson() => {
        'frame_number': frameNumber,
        'ball_1_pins_standing': ball1Standing,
        if (ball2Standing != null) 'ball_2_pins_standing': ball2Standing,
        if (ball3Standing != null) 'ball_3_pins_standing': ball3Standing,
        if (ball1EquipmentId != null) 'ball_1_equipment_id': ball1EquipmentId,
        if (ball2EquipmentId != null) 'ball_2_equipment_id': ball2EquipmentId,
        if (ball3EquipmentId != null) 'ball_3_equipment_id': ball3EquipmentId,
      };
}

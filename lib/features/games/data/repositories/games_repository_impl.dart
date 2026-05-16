import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/entities/game_detail.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/stats_detail.dart';
import '../../domain/entities/user_game_stats.dart';
import '../../domain/repositories/games_repository.dart';
import '../datasources/games_remote_datasource.dart';
import '../models/games_dtos.dart';

@LazySingleton(as: GamesRepository)
class GamesRepositoryImpl implements GamesRepository {
  GamesRepositoryImpl(this._remote);

  final GamesRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<Session>>> getSessions({
    int? page,
    int pageSize = 20,
  }) =>
      _guard(() async {
        final list = await _remote.getSessions(
          page: page,
          pageSize: pageSize,
        );
        return list.map(_sessionToEntity).toList(growable: false);
      });

  @override
  Future<Either<Failure, UserGameStats>> getStats() => _guard(() async {
        final dto = await _remote.getStats();
        return UserGameStats(
          totalGames: dto.totalGames,
          totalPins: dto.totalPins,
          currentAverage: dto.currentAverage,
          allTimeAverage: dto.allTimeAverage,
          highGame: dto.highGame,
          highGameDate: dto.highGameDate,
          highGameCenter: dto.highGameCenterName,
          highSeries: dto.highSeries,
          highSeriesDate: dto.highSeriesDate,
          highSeriesCenter: dto.highSeriesCenterName,
          strikePercentage: dto.strikePercentage,
          spareConversionRate: dto.spareConversionRate,
          splitFrequency: dto.splitFrequency,
          splitConversionRate: dto.splitConversionRate,
          cleanGameCount: dto.cleanGameCount,
          perfectGameCount: dto.perfectGameCount,
        );
      });

  @override
  Future<Either<Failure, Session>> getSession(String uid) =>
      _guard(() async => _sessionToEntity(await _remote.getSession(uid)));

  @override
  Future<Either<Failure, GameDetail>> getGame(int id) =>
      _guard(() async => _gameToEntity(await _remote.getGame(id)));

  @override
  Future<Either<Failure, Session>> createSession() => _guard(() async {
        // Backend accepts empty body and fills defaults — matches web's
        // `api.post('/api/games/sessions')` with no payload.
        final dto = await _remote.createSession(<String, dynamic>{});
        return _sessionToEntity(dto);
      });

  @override
  Future<Either<Failure, GameDetail>> submitGame({
    required String sessionUid,
    required List<SubmitFramePayload> frames,
    required String handedness,
    int? totalScore,
  }) =>
      _guard(() async {
        final body = <String, dynamic>{
          'handedness': handedness,
          'frames': frames.map((f) => f.toJson()).toList(growable: false),
          'total_score': ?totalScore,
        };
        return _gameToEntity(await _remote.submitGame(sessionUid, body));
      });

  @override
  Future<Either<Failure, GameDetail>> submitQuickScore({
    required String sessionUid,
    required int totalScore,
    required String handedness,
  }) =>
      _guard(() async {
        final dto = await _remote.submitQuickScore(sessionUid, {
          'total_score': totalScore,
          'handedness': handedness,
        });
        return _gameToEntity(dto);
      });

  @override
  Future<Either<Failure, Unit>> deleteSession(String uid) => _guard(() async {
        await _remote.deleteSession(uid);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> deleteGame(int id) => _guard(() async {
        await _remote.deleteGame(id);
        return unit;
      });

  @override
  Future<Either<Failure, Unit>> updateFrame({
    required int gameId,
    required SubmitFramePayload frame,
  }) =>
      _guard(() async {
        await _remote.updateFrame(gameId, frame.frameNumber, frame.toJson());
        return unit;
      });

  // ── Equipment ─────────────────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<UserBall>>> getEquipment() => _guard(() async {
        final list = await _remote.getEquipment();
        return list.map(_userBallToEntity).toList(growable: false);
      });

  @override
  Future<Either<Failure, List<BallStats>>> getEquipmentStats() =>
      _guard(() async {
        final list = await _remote.getEquipmentStats();
        return list
            .map((s) => BallStats(
                  userBallId: s.userBallId,
                  gamesPlayed: s.gamesPlayed,
                  framesThrown: s.framesThrown,
                  firstBallCount: s.firstBallCount,
                  firstBallAvg: s.firstBallAvg.toDouble(),
                  strikeRate: s.strikeRate.toDouble(),
                ))
            .toList(growable: false);
      });

  @override
  Future<Either<Failure, UserBall>> addEquipment({
    required int ballId,
    required int weight,
  }) =>
      _guard(() async {
        final dto = await _remote.addEquipment({
          'ball_id': ballId,
          'weight': weight,
        });
        return _userBallToEntity(dto);
      });

  @override
  Future<Either<Failure, Unit>> deleteEquipment(int userBallId) =>
      _guard(() async {
        await _remote.deleteEquipment(userBallId);
        return unit;
      });

  @override
  Future<Either<Failure, ({List<CatalogBall> balls, bool hasNext})>>
      searchBallCatalog({
    String? search,
    int page = 1,
    int pageSize = 24,
  }) =>
      _guard(() async {
        final dto = await _remote.searchBalls(
          search: search,
          page: page,
          pageSize: pageSize,
        );
        return (
          balls: dto.balls.map(_catalogToEntity).toList(growable: false),
          hasNext: dto.hasNext,
        );
      });

  // ── Stats sub-resources ───────────────────────────────────────────────────
  @override
  Future<Either<Failure, List<PinLeaveStat>>> getPinLeaveStats() =>
      _guard(() async {
        final list = await _remote.getStatsPinLeaves();
        return list
            .map((d) => PinLeaveStat(
                  leavePattern: d.leavePattern,
                  name: d.name,
                  occurrenceCount: d.occurrenceCount,
                  conversionCount: d.conversionCount,
                  conversionRate: d.conversionRate.toDouble(),
                ))
            .toList(growable: false);
      });

  @override
  Future<Either<Failure, List<SpareCategoryStat>>> getSpareStats() =>
      _guard(() async {
        final list = await _remote.getStatsSpares();
        return list
            .map((d) => SpareCategoryStat(
                  category: d.category,
                  total: d.total,
                  converted: d.converted,
                  conversionRate: d.conversionRate.toDouble(),
                ))
            .toList(growable: false);
      });

  @override
  Future<Either<Failure, List<TrendPoint>>> getTrendStats({
    int rangeDays = 30,
  }) =>
      _guard(() async {
        final list = await _remote.getStatsTrends(range: rangeDays);
        return list
            .map((d) => TrendPoint(
                  score: d.score,
                  rollingAverage: d.rollingAverage.toDouble(),
                  date: d.date == null ? null : DateTime.tryParse(d.date!),
                  gameContext: d.gameContext,
                ))
            .toList(growable: false);
      });

  @override
  Future<Either<Failure, List<CenterPerformance>>> getStatsByCenter() =>
      _guard(() async {
        final list = await _remote.getStatsByCenter();
        return list
            .map((d) => CenterPerformance(
                  centerId: d.centerId,
                  centerName:
                      d.centerName.isEmpty ? 'Unknown' : d.centerName,
                  avgScore: d.avgScore.toDouble(),
                  gamesCount: d.gamesCount,
                ))
            .toList(growable: false);
      });

  @override
  Future<Either<Failure, List<ContextPerformance>>> getStatsByContext() =>
      _guard(() async {
        final list = await _remote.getStatsByContext();
        return list
            .map((d) => ContextPerformance(
                  gameContext: d.gameContext,
                  avgScore: d.avgScore.toDouble(),
                  gamesCount: d.gamesCount,
                ))
            .toList(growable: false);
      });

  // ── mappers ────────────────────────────────────────────────────────────────
  UserBall _userBallToEntity(UserBallDto dto) => UserBall(
        id: dto.id,
        weight: dto.weight,
        ball: _catalogToEntity(dto.ball),
        createdAt:
            dto.createdAt == null ? null : DateTime.tryParse(dto.createdAt!),
      );

  CatalogBall _catalogToEntity(BallCatalogDto dto) => CatalogBall(
        id: dto.id,
        name: dto.name,
        brand: dto.brand == null
            ? null
            : BallBrand(
                id: dto.brand!.id,
                name: dto.brand!.name,
                logoUrl: dto.brand!.logoUrl,
              ),
        core: dto.core,
        surface: dto.surface,
        rg: dto.rg,
        diff: dto.diff,
        intDiff: dto.intDiff,
        arc: dto.arc,
        ballImage: dto.ballImage,
      );

  // ---------------------------------------------------------------------------
  GameDetail _gameToEntity(GameDetailDto dto) => GameDetail(
        id: dto.id,
        gameNumber: dto.gameNumber,
        totalScore: dto.totalScore,
        strikeCount: dto.strikeCount,
        spareCount: dto.spareCount,
        openCount: dto.openCount,
        splitCount: dto.splitCount,
        firstBallAverage: dto.firstBallAverage.toDouble(),
        isClean: dto.isClean,
        isPerfect: dto.isPerfect,
        isComplete: dto.isComplete,
        createdAt:
            dto.createdAt == null ? null : DateTime.tryParse(dto.createdAt!),
        frames: dto.frames
            .map((f) => GameFrame(
                  frameNumber: f.frameNumber,
                  isStrike: f.isStrike,
                  isSpare: f.isSpare,
                  isSplit: f.isSplit,
                  splitName: f.splitName,
                  isPocketHit: f.isPocketHit,
                  isWashout: f.isWashout,
                  pinfall: f.pinfall,
                  frameScore: f.frameScore,
                ))
            .toList(growable: false),
      );

  // ---------------------------------------------------------------------------
  Session _sessionToEntity(SessionDto dto) => Session(
        uid: dto.uid,
        name: dto.name,
        context: GameContext.fromString(dto.gameContext),
        center: dto.center == null
            ? null
            : CenterRef(id: dto.center!.id, name: dto.center!.name),
        laneNumbers: dto.laneNumbers,
        oilPatternName: dto.oilPatternName,
        oilPatternLength: dto.oilPatternLength,
        notes: dto.notes,
        games: dto.games
            .map((g) => GameSummary(
                  id: g.id,
                  gameNumber: g.gameNumber,
                  totalScore: g.totalScore,
                  strikeCount: g.strikeCount,
                  spareCount: g.spareCount,
                  isComplete: g.isComplete,
                ))
            .toList(growable: false),
        seriesTotal: dto.seriesTotal,
        createdAt:
            dto.createdAt == null ? null : DateTime.tryParse(dto.createdAt!),
      );

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

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/session.dart';
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

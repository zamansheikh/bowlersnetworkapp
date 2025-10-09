// For data layer, assume you implement GameRepositoryImpl with local storage (e.g., Hive or SharedPreferences).
// Example stub for now (add to di with @LazySingleton(as: GameRepository)):

// data/repositories/game_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/bowling_game_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_local_data_source.dart';
import '../models/bowling_game_model.dart';

@LazySingleton(as: GameRepository)
class GameRepositoryImpl implements GameRepository {
  final GameLocalDataSource _localDataSource;

  GameRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, void>> saveGame(BowlingGameEntity game) async {
    try {
      final model = BowlingGameModel.fromEntity(game);
      await _localDataSource.saveGame(model);
      return Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save game: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BowlingGameEntity>>> getAllGames() async {
    try {
      final models = await _localDataSource.getAllGames();
      final entities = models.map((m) => m.toEntity()).toList();
      // Sort by date, most recent first
      entities.sort((a, b) => b.date.compareTo(a.date));
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure('Failed to load games: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGame(String id) async {
    try {
      await _localDataSource.deleteGame(id);
      return Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete game: $e'));
    }
  }

  @override
  Future<Either<Failure, BowlingGameEntity>> getGameById(String id) async {
    try {
      final model = await _localDataSource.getGameById(id);
      if (model == null) {
        return Left(CacheFailure('Game not found'));
      }
      return Right(model.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get game: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateGame(BowlingGameEntity game) async {
    try {
      final model = BowlingGameModel.fromEntity(game);
      await _localDataSource.updateGame(model);
      return Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update game: $e'));
    }
  }
}

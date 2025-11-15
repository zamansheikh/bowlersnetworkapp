// For data layer, assume you implement GameRepositoryImpl with local storage (e.g., Hive or SharedPreferences).
// Example stub for now (add to di with @LazySingleton(as: GameRepository)):

// data/repositories/game_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/bowling_game_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_local_data_source.dart';
import '../datasources/game_remote_data_source.dart';
import '../models/bowling_game_model.dart';

@LazySingleton(as: GameRepository)
class GameRepositoryImpl implements GameRepository {
  final GameLocalDataSource _localDataSource;
  final GameRemoteDataSource _remoteDataSource;

  GameRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<Either<Failure, void>> saveGame(BowlingGameEntity game) async {
    try {
      final model = BowlingGameModel.fromEntity(game);

      // Always save to local first
      await _localDataSource.saveGame(model);

      // Try to sync if online
      try {
        final remoteGame = await _remoteDataSource.createGame(model);
        // Update with backend ID
        await _localDataSource.updateGameAfterSync(model.id, remoteGame.id);
        return Right(null);
      } catch (e) {
        // Mark for later sync if offline
        return Right(null);
      }
    } catch (e) {
      return Left(CacheFailure('Failed to save game: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BowlingGameEntity>>> getAllGames() async {
    try {
      // Try to get from backend if online
      final remoteGames = await _remoteDataSource.getAllGames();
      // Save to local cache
      for (final game in remoteGames) {
        await _localDataSource.saveGame(game);
      }
      return Right(remoteGames.map((m) => m.toEntity()).toList());
    } catch (e) {
      // Fallback to local storage if offline or error
      try {
        final localGames = await _localDataSource.getAllGames();
        return Right(localGames.map((m) => m.toEntity()).toList());
      } catch (localError) {
        return Left(CacheFailure('Failed to load games: $localError'));
      }
    }
  }

  @override
  Future<Either<Failure, void>> deleteGame(String id) async {
    try {
      await _localDataSource.deleteGame(id);

      // Try to delete from remote
      try {
        await _remoteDataSource.deleteGame(id);
      } catch (e) {
        // Ignore remote error, local delete is enough
      }

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

      // Always update local first
      await _localDataSource.updateGame(model);

      // Try to update remote if game has backend ID
      if (model.backendId != null) {
        try {
          await _remoteDataSource.updateGame(model.backendId!, model);
        } catch (e) {
          // Ignore remote error, local update is enough
        }
      }

      return Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to update game: $e'));
    }
  }
}

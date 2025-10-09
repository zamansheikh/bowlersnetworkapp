// For data layer, assume you implement GameRepositoryImpl with local storage (e.g., Hive or SharedPreferences).
// Example stub for now (add to di with @LazySingleton(as: GameRepository)):

// data/repositories/game_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/bowling_game_entity.dart';
import '../../domain/repositories/game_repository.dart';

// Assume a local data source
@LazySingleton(as: GameRepository)
class GameRepositoryImpl implements GameRepository {
  // In-memory storage for demo (replace with Hive/SharedPreferences in production)
  final List<BowlingGameEntity> _games = [];

  @override
  Future<Either<Failure, void>> saveGame(BowlingGameEntity game) async {
    try {
      // TODO: Implement actual storage, e.g., Hive.box('games').add(game.toJson());
      _games.add(game);
      return Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save game: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BowlingGameEntity>>> getAllGames() async {
    try {
      // TODO: Implement actual retrieval, e.g., Hive.box('games').values.toList();
      return Right(List.from(_games));
    } catch (e) {
      return Left(CacheFailure('Failed to load games: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGame(String id) async {
    try {
      // TODO: Implement actual deletion, e.g., Hive.box('games').delete(id);
      _games.removeWhere((game) => game.id == id);
      return Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete game: $e'));
    }
  }
}

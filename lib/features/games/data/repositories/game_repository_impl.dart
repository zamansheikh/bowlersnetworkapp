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
  @override
  Future<Either<Failure, void>> saveGame(BowlingGameEntity game) async {
    // TODO: Implement actual storage, e.g., Hive.box('games').add(game.toJson());
    return Right(null);
  }
}
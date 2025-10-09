// domain/repositories/game_repository.dart (abstract)

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bowling_game_entity.dart';

abstract class GameRepository {
  Future<Either<Failure, void>> saveGame(BowlingGameEntity game);
  Future<Either<Failure, List<BowlingGameEntity>>> getAllGames();
  Future<Either<Failure, void>> deleteGame(String id);
}

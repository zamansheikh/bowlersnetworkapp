import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pro_player.dart';

abstract class ProPlayersRepository {
  Future<Either<Failure, List<ProPlayer>>> getProPlayers();
  Future<Either<Failure, ProPlayer>> getProPlayerByUsername(String username);
  Future<Either<Failure, bool>> followPlayer(int userId);
  Future<Either<Failure, bool>> unfollowPlayer(int userId);
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/pro_player.dart';
import '../repositories/pro_players_repository.dart';

@injectable
class GetProPlayers implements UseCase<List<ProPlayer>, NoParams> {
  final ProPlayersRepository repository;

  GetProPlayers(this.repository);

  @override
  Future<Either<Failure, List<ProPlayer>>> call(NoParams params) async {
    return await repository.getProPlayers();
  }
}

@injectable
class GetProPlayerByUsername implements UseCase<ProPlayer, String> {
  final ProPlayersRepository repository;

  GetProPlayerByUsername(this.repository);

  @override
  Future<Either<Failure, ProPlayer>> call(String username) async {
    return await repository.getProPlayerByUsername(username);
  }
}

@injectable
class FollowPlayer implements UseCase<bool, int> {
  final ProPlayersRepository repository;

  FollowPlayer(this.repository);

  @override
  Future<Either<Failure, bool>> call(int userId) async {
    return await repository.followPlayer(userId);
  }
}

@injectable
class UnfollowPlayer implements UseCase<bool, int> {
  final ProPlayersRepository repository;

  UnfollowPlayer(this.repository);

  @override
  Future<Either<Failure, bool>> call(int userId) async {
    return await repository.unfollowPlayer(userId);
  }
}

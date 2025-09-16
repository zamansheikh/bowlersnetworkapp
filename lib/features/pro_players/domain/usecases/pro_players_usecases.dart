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
class GetProPlayerById implements UseCase<ProPlayer, String> {
  final ProPlayersRepository repository;

  GetProPlayerById(this.repository);

  @override
  Future<Either<Failure, ProPlayer>> call(String userId) async {
    return await repository.getProPlayerById(userId);
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

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/pro_player.dart';
import '../../domain/repositories/pro_players_repository.dart';
import '../datasources/pro_players_remote_data_source.dart';

@LazySingleton(as: ProPlayersRepository)
class ProPlayersRepositoryImpl implements ProPlayersRepository {
  final ProPlayersRemoteDataSource remoteDataSource;

  ProPlayersRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ProPlayer>>> getProPlayers() async {
    try {
      final proPlayers = await remoteDataSource.getProPlayers();
      return Right(proPlayers);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProPlayer>> getProPlayerById(String userId) async {
    try {
      final proPlayer = await remoteDataSource.getProPlayerById(userId);
      // Fetch user posts separately
      try {
        final posts = await remoteDataSource.getUserPosts(userId);
        final playerWithPosts = proPlayer.copyWith(posts: posts);
        return Right(playerWithPosts);
      } catch (postsError) {
        // If posts fail to load, still return player without posts
        return Right(proPlayer);
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> followPlayer(int userId) async {
    try {
      final result = await remoteDataSource.followPlayer(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> unfollowPlayer(int userId) async {
    try {
      final result = await remoteDataSource.unfollowPlayer(userId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

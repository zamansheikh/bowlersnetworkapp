import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/follow_user.dart';
import '../../domain/repositories/follow_repository.dart';
import '../datasources/follow_remote_datasource.dart';
import '../models/follow_dtos.dart';

@LazySingleton(as: FollowRepository)
class FollowRepositoryImpl implements FollowRepository {
  FollowRepositoryImpl(this._remote);

  final FollowRemoteDatasource _remote;

  @override
  Future<Either<Failure, FollowToggleResult>> toggleFollow(int userId) =>
      _guard(() async {
        final dto = await _remote.toggleFollow(userId);
        return FollowToggleResult(
          isFollowing: dto.isFollowing,
          followerCount: dto.followerCount,
        );
      });

  @override
  Future<Either<Failure, List<FollowUser>>> getMyFollowers() =>
      _guard(() async {
        final res = await _remote.getMyFollowers();
        return res.followers.map(_toEntity).toList(growable: false);
      });

  @override
  Future<Either<Failure, List<FollowUser>>> getMyFollowings() =>
      _guard(() async {
        final res = await _remote.getMyFollowings();
        return res.followings.map(_toEntity).toList(growable: false);
      });

  @override
  Future<Either<Failure, List<FollowUser>>> getUserFollowers(int userId) =>
      _guard(() async {
        final res = await _remote.getUserFollowers(userId);
        return res.followers.map(_toEntity).toList(growable: false);
      });

  @override
  Future<Either<Failure, List<FollowUser>>> getUserFollowings(int userId) =>
      _guard(() async {
        final res = await _remote.getUserFollowings(userId);
        return res.followings.map(_toEntity).toList(growable: false);
      });

  FollowUser _toEntity(FollowUserDto dto) => FollowUser(
        id: dto.id,
        username: dto.username,
        firstName: dto.firstName,
        lastName: dto.lastName,
        profilePictureUrl: dto.profilePictureUrl,
        isPro: dto.isPro,
        level: dto.level,
        rankDisplay: dto.rankDisplay,
        badgeIconUrl: dto.badgeIconUrl,
        isFollowing: dto.isFollowing,
        followedAt: dto.followedAt == null
            ? null
            : DateTime.tryParse(dto.followedAt!),
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

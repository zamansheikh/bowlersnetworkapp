import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_completion_dto.dart';
import '../models/profile_dto.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDatasource _remote;

  @override
  Future<Either<Failure, Profile>> getMyProfile() =>
      _guard(() async => _toEntity(await _remote.getMyProfile()));

  @override
  Future<Either<Failure, Profile>> getProfileByUsername(String username) =>
      _guard(() async => _toEntity(await _remote.getProfileByUsername(username)));

  @override
  Future<Either<Failure, ProfileCompletion>> getCompletion() => _guard(() async {
        final dto = await _remote.getCompletion();
        return _completionToEntity(dto);
      });

  Profile _toEntity(ProfileDto dto) => Profile(
        user: ProfileUser(
          id: dto.user.id,
          firstName: dto.user.firstName,
          lastName: dto.user.lastName,
          username: dto.user.username,
          isPro: dto.user.isPro,
        ),
        completionPercentage: dto.completionPercentage,
        isComplete: dto.isComplete,
        profilePictureUrl: dto.profileMedia?.profilePictureUrl,
        coverPictureUrl: dto.profileMedia?.coverPictureUrl,
        followerCount: dto.followerCount,
        followingCount: dto.followingCount,
      );

  ProfileCompletion _completionToEntity(ProfileCompletionDto dto) =>
      ProfileCompletion(
        completionPercentage: dto.completionPercentage,
        isComplete: dto.isComplete,
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

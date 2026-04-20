import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/xp_level_info.dart';
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

  @override
  Future<Either<Failure, XpLevelInfo>> getXpLevelInfo() => _guard(() async {
        final dto = await _remote.getXpLevelInfo();
        return XpLevelInfo(
          level: dto.level,
          totalXp: dto.totalXp,
          progressPercentage: dto.progressPercentage,
          rank: dto.rank,
          tier: dto.tier,
          rankDisplay: dto.rankDisplay,
          badgeIconUrl: dto.badgeIconUrl,
        );
      });

  @override
  Future<Either<Failure, List<Brand>>> getBrands() => _guard(() async {
        final list = await _remote.getBrands();
        return list
            .map((b) => Brand(
                  id: b.brandId,
                  name: b.name,
                  type: b.brandType,
                  logoUrl: b.logoUrl,
                  isFavorite: b.isFavorite,
                ))
            .toList(growable: false);
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
        introVideoUrl: dto.profileMedia?.introVideoUrl,
        bio: dto.bio?.content,
        nickname: dto.nickname?.name,
        gender: dto.gender?.value,
        birthdate: dto.birthdate?.dateStr ?? dto.birthdate?.dateOfBirth,
        age: dto.birthdate?.age,
        address: dto.address?.location?.address,
        zipCode: dto.address?.location?.zipCode,
        homeCenter: dto.homeCenter?.centerName,
        handedness: dto.ballHandlingStyle?.handedness,
        ballCarry: dto.ballHandlingStyle?.ballCarry,
        grip: dto.ballHandlingStyle?.grip,
        ballHandlingDescription: dto.ballHandlingStyle?.description,
        contactEmail: dto.contactInfo?.email,
        average: dto.officialGameStat?.average,
        highGame: dto.officialGameStat?.highGame,
        highSeries: dto.officialGameStat?.highSeries,
        experience: dto.officialGameStat?.experience,
        isCoach: dto.criticalInfo?.isCoach ?? false,
        followerCount: dto.followerCount,
        followingCount: dto.followingCount,
        isFollowing: dto.isFollowing,
        canFollow: dto.canFollow,
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

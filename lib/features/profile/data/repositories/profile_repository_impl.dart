import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/cloud_upload_service.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_models.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  final CloudUploadService _cloudUpload;

  ProfileRepositoryImpl(this._remote, this._cloudUpload);

  @override
  Future<Either<Failure, ProfileModel>> getMyProfile() async {
    try { return Right(await _remote.getMyProfile()); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, ProfileModel>> getProfileByUsername(String username) async {
    try { return Right(await _remote.getProfileByUsername(username)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, ProfileCompletionModel>> getCompletion() async {
    try { return Right(await _remote.getCompletion()); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> updateGender({required String value}) async {
    try { await _remote.updateGender(value: value); return const Right(null); }
    on ValidationException catch (e) { return Left(ValidationFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> updateBirthdate({required String dateOfBirth}) async {
    try { await _remote.updateBirthdate(dateOfBirth: dateOfBirth); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> updateAddress({
    required String address, required String zipCode,
    required double latitude, required double longitude,
  }) async {
    try {
      await _remote.updateAddress(address: address, zipCode: zipCode, latitude: latitude, longitude: longitude);
      return const Right(null);
    }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> updateHomeCenter({required int centerId, String centerName = ''}) async {
    try { await _remote.updateHomeCenter(centerId: centerId, centerName: centerName); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> updateBallHandlingStyle({String? handedness, String? ballCarry, String? grip}) async {
    try { await _remote.updateBallHandlingStyle(handedness: handedness, ballCarry: ballCarry, grip: grip); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> updateBio({required String content}) async {
    try { await _remote.updateBio(content: content); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> updateNickname({required String name}) async {
    try { await _remote.updateNickname(name: name); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture({required Uint8List fileBytes, required String fileName}) async {
    // Use shared CloudUploadService
    final result = await _cloudUpload.uploadFile(fileBytes: fileBytes, fileName: fileName, bucket: 'profiles');
    return result.fold(
      (failure) => Left(failure),
      (publicUrl) async {
        try {
          await _remote.updateProfilePicture(url: publicUrl);
          return Right(publicUrl);
        } on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
        on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
      },
    );
  }

  @override
  Future<Either<Failure, List<CenterModel>>> getCenters() async {
    try { return Right(await _remote.getCenters()); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, bool>> toggleFollow(int userId) async {
    try {
      final data = await _remote.toggleFollow(userId);
      return Right(data['is_following'] as bool? ?? false);
    }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }
}

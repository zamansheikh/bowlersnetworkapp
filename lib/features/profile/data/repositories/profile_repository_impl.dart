import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_models.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;

  ProfileRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, ProfileModel>> getMyProfile() async {
    try {
      final profile = await _remote.getMyProfile();
      return Right(profile);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProfileCompletionModel>> getCompletion() async {
    try {
      final completion = await _remote.getCompletion();
      return Right(completion);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateGender({required String value}) async {
    try {
      await _remote.updateGender(value: value);
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateBirthdate({required String dateOfBirth}) async {
    try {
      await _remote.updateBirthdate(dateOfBirth: dateOfBirth);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateAddress({
    required String address,
    required String zipCode,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _remote.updateAddress(
        address: address,
        zipCode: zipCode,
        latitude: latitude,
        longitude: longitude,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateHomeCenter({required int centerId, String centerName = ''}) async {
    try {
      await _remote.updateHomeCenter(centerId: centerId, centerName: centerName);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateBallHandlingStyle({String? handedness, String? ballCarry, String? grip}) async {
    try {
      await _remote.updateBallHandlingStyle(handedness: handedness, ballCarry: ballCarry, grip: grip);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateBio({required String content}) async {
    try {
      await _remote.updateBio(content: content);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateNickname({required String name}) async {
    try {
      await _remote.updateNickname(name: name);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture({required Uint8List fileBytes, required String fileName}) async {
    try {
      // 1. Initiate upload to get presigned URL
      final uploadInfo = await _remote.initiateUpload(fileName: fileName, bucket: 'profiles');
      // 2. Upload file to presigned URL
      final ext = fileName.split('.').last.toLowerCase();
      final contentType = _mimeType(ext);
      await _remote.uploadToPresignedUrl(
        presignedUrl: uploadInfo.presignedUrl,
        fileBytes: fileBytes,
        contentType: contentType,
      );
      // 3. Update profile picture URL
      await _remote.updateProfilePicture(url: uploadInfo.publicUrl);
      return Right(uploadInfo.publicUrl);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to upload image: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CenterModel>>> getCenters() async {
    try {
      final centers = await _remote.getCenters();
      return Right(centers);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  String _mimeType(String ext) => switch (ext) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        _ => 'application/octet-stream',
      };
}

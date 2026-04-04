import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/profile_models.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> getMyProfile();
  Future<Either<Failure, ProfileModel>> getProfileByUsername(String username);
  Future<Either<Failure, ProfileCompletionModel>> getCompletion();
  Future<Either<Failure, void>> updateGender({required String value});
  Future<Either<Failure, void>> updateBirthdate({required String dateOfBirth});
  Future<Either<Failure, void>> updateAddress({
    required String address, required String zipCode,
    required double latitude, required double longitude,
  });
  Future<Either<Failure, void>> updateHomeCenter({required int centerId, String centerName = ''});
  Future<Either<Failure, void>> updateBallHandlingStyle({String? handedness, String? ballCarry, String? grip});
  Future<Either<Failure, void>> updateBio({required String content});
  Future<Either<Failure, void>> updateNickname({required String name});
  Future<Either<Failure, String>> uploadProfilePicture({required Uint8List fileBytes, required String fileName});
  Future<Either<Failure, List<CenterModel>>> getCenters();
  Future<Either<Failure, bool>> toggleFollow(int userId);
}

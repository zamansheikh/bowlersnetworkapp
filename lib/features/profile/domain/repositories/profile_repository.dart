import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getMyProfile();
  Future<Either<Failure, ProfileCompletion>> getCompletion();
  Future<Either<Failure, Profile>> getProfileByUsername(String username);
}

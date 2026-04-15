import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

@lazySingleton
class GetMyProfileUseCase implements UseCase<Profile, NoParams> {
  const GetMyProfileUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Either<Failure, Profile>> call(NoParams params) =>
      _repository.getMyProfile();
}

@lazySingleton
class CheckProfileCompletionUseCase
    implements UseCase<ProfileCompletion, NoParams> {
  const CheckProfileCompletionUseCase(this._repository);
  final ProfileRepository _repository;

  @override
  Future<Either<Failure, ProfileCompletion>> call(NoParams params) =>
      _repository.getCompletion();
}

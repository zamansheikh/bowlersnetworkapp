import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/auth_dtos.dart';
import '../repositories/auth_repository.dart';

/// Step-1 pre-signup check. Sends the registration payload to the backend
/// to verify username/email uniqueness + data validity. On success the app
/// advances to the OTP step; on failure the backend's `{"errors": [...]}`
/// messages drive the error banner.
@lazySingleton
class ValidateRegistrationUseCase implements UseCase<Unit, SignupData> {
  const ValidateRegistrationUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SignupData data) =>
      _repository.validateRegistration(data);
}

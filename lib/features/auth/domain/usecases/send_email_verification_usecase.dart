import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/auth_dtos.dart';
import '../repositories/auth_repository.dart';

/// Kicks off signup: backend caches the registration and emails an OTP.
/// Maps to `POST /api/auth/signup/submit`.
///
/// Filename is legacy ("send email verification") from when this was a
/// single-step `/verify-email` call. The repository method is now
/// `submitSignup` to match the 4-step flow the backend & web use.
@lazySingleton
class SubmitSignupUseCase implements UseCase<Unit, SignupData> {
  const SubmitSignupUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SignupData data) =>
      _repository.submitSignup(data);
}

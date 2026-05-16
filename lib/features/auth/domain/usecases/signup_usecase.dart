import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/auth_dtos.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class SignupParams extends Equatable {
  const SignupParams({
    required this.data,
    required this.verificationCode,
    this.favoriteBrandIds = const [],
    this.referrerUsername,
  });

  final SignupData data;
  final String verificationCode;
  final List<int> favoriteBrandIds;
  final String? referrerUsername;

  @override
  List<Object?> get props =>
      [data, verificationCode, favoriteBrandIds, referrerUsername];
}

/// Step 3 of signup: verify the OTP + finalise the account. Maps to
/// `POST /api/auth/signup/complete`.
@lazySingleton
class CompleteSignupUseCase implements UseCase<AuthSession, SignupParams> {
  const CompleteSignupUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthSession>> call(SignupParams params) {
    return _repository.completeSignup(
      data: params.data,
      verificationCode: params.verificationCode,
      favoriteBrandIds: params.favoriteBrandIds,
      referrerUsername: params.referrerUsername,
    );
  }
}

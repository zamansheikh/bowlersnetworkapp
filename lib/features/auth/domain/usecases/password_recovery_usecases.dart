import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class InitiateRecoveryOtpUseCase implements UseCase<Unit, String> {
  const InitiateRecoveryOtpUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String email) =>
      _repository.initiateRecoveryOtp(email);
}

class ValidateOtpParams extends Equatable {
  const ValidateOtpParams({required this.email, required this.otp});
  final String email;
  final String otp;
  @override
  List<Object?> get props => [email, otp];
}

@lazySingleton
class ValidateRecoveryOtpUseCase implements UseCase<String, ValidateOtpParams> {
  const ValidateRecoveryOtpUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, String>> call(ValidateOtpParams params) =>
      _repository.validateRecoveryOtp(email: params.email, otp: params.otp);
}

class ResetPasswordParams extends Equatable {
  const ResetPasswordParams({
    required this.recoveryToken,
    required this.newPassword,
  });
  final String recoveryToken;
  final String newPassword;
  @override
  List<Object?> get props => [recoveryToken, newPassword];
}

@lazySingleton
class ResetPasswordUseCase implements UseCase<Unit, ResetPasswordParams> {
  const ResetPasswordUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ResetPasswordParams params) =>
      _repository.resetPassword(
        recoveryToken: params.recoveryToken,
        newPassword: params.newPassword,
      );
}

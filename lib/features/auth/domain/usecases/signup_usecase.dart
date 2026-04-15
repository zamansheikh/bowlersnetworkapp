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
    this.referrerUsername,
  });

  final SignupData data;
  final String verificationCode;
  final String? referrerUsername;

  @override
  List<Object?> get props => [data, verificationCode, referrerUsername];
}

@lazySingleton
class SignupUseCase implements UseCase<AuthSession, SignupParams> {
  const SignupUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthSession>> call(SignupParams params) {
    return _repository.signup(
      data: params.data,
      verificationCode: params.verificationCode,
      referrerUsername: params.referrerUsername,
    );
  }
}

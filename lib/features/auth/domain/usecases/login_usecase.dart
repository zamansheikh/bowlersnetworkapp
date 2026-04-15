import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginParams extends Equatable {
  const LoginParams({required this.credential, required this.password});

  final String credential;
  final String password;

  @override
  List<Object?> get props => [credential, password];
}

@lazySingleton
class LoginUseCase implements UseCase<AuthSession, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthSession>> call(LoginParams params) {
    return _repository.login(
      credential: params.credential,
      password: params.password,
    );
  }
}

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String username;
  final String password;
  const LoginParams({required this.username, required this.password});
}

@injectable
class Login extends UseCase<AuthToken, LoginParams> {
  final AuthRepository repository;
  Login(this.repository);

  @override
  Future<Either<Failure, AuthToken>> call(LoginParams params) {
    return repository.login(
      username: params.username,
      password: params.password,
    );
  }
}

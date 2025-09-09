import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_token.dart';
import '../../../home/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthToken>> login({required String username, required String password});
  Future<Either<Failure, User>> getProfile();
  Future<void> logout();
  Future<AuthToken?> getPersistedToken();
}

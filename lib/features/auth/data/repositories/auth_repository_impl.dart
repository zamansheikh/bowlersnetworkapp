import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../home/domain/entities/user.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_token_model.dart';
import '../../../home/data/models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final SharedPreferences prefs;

  AuthRepositoryImpl({required this.remote, required this.prefs});

  @override
  Future<Either<Failure, AuthToken>> login({
    required String username,
    required String password,
  }) async {
    try {
      final token = await remote.login(username, password);
      await prefs.setString(AppConstants.tokenKey, token.accessToken);
      return Right(token);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final token = prefs.getString(AppConstants.tokenKey);
      if (token == null || token.isEmpty) {
        return Left(NetworkFailure('Missing token'));
      }
      final user = await remote.getProfile(token);
      await prefs.setString(
        AppConstants.userKey,
        jsonEncode((user as UserModel).toJson()),
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  @override
  Future<AuthToken?> getPersistedToken() async {
    final token = prefs.getString(AppConstants.tokenKey);
    if (token == null) return null;
    return AuthTokenModel(accessToken: token);
  }
}

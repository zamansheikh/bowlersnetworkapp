import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_dtos.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._secure, this._local);

  final AuthRemoteDatasource _remote;
  final SecureStorageService _secure;
  final LocalStorageService _local;

  @override
  Future<Either<Failure, Unit>> sendEmailVerification(String email) async {
    return _guard(() async {
      await _remote.verifyEmail(VerifyEmailRequest(email: email));
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> validateRegistration(SignupData data) async {
    return _guard(() async {
      await _remote.validateRegistration(
        ValidateRegistrationRequest(
          firstName: data.firstName,
          lastName: data.lastName,
          email: data.email,
          username: data.username,
          password: data.password,
          dateOfBirth: data.dateOfBirth,
          parentEmail: data.parentEmail,
        ),
      );
      return unit;
    });
  }

  @override
  Future<Either<Failure, AuthSession>> signup({
    required SignupData data,
    required String verificationCode,
    String? referrerUsername,
  }) async {
    return _guard(() async {
      final res = await _remote.signup(
        SignupRequest(
          signupData: data,
          verificationCode: verificationCode,
          referrerUsername: referrerUsername,
        ),
      );
      return _persistSession(res);
    });
  }

  @override
  Future<Either<Failure, AuthSession>> login({
    required String credential,
    required String password,
  }) async {
    return _guard(() async {
      final res = await _remote.login(
        LoginRequest(credential: credential, password: password),
      );
      return _persistSession(res);
    });
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    await _secure.clearAll();
    await _local.remove(StorageKeys.isPro);
    return const Right(unit);
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final token = await _secure.getToken();
    if (token == null || token.isEmpty) return null;
    final userId = await _secure.getUserId();
    final consent = await _local.getBool(
      StorageKeys.requiresConsent,
      defaultValue: false,
    );
    return AuthSession(
      token: token,
      userId: int.tryParse(userId ?? ''),
      requiresConsent: consent,
    );
  }

  @override
  Future<Either<Failure, Unit>> initiateRecoveryOtp(String email) async {
    return _guard(() async {
      await _remote.initiateRecoveryOtp(EmailRequest(email: email));
      return unit;
    });
  }

  @override
  Future<Either<Failure, String>> validateRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    return _guard(() async {
      final res = await _remote.validateRecoveryOtp(
        ValidateOtpRequest(email: email, otp: otp),
      );
      return res.token;
    });
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String recoveryToken,
    required String newPassword,
  }) async {
    return _guard(() async {
      // The backend reads the recovery JWT from the Authorization header — the
      // shared Dio already pulls from secure storage, so we temporarily save
      // the recovery token, call reset, then clear it.
      await _secure.saveToken(recoveryToken);
      try {
        await _remote.resetPassword(
          ResetPasswordRequest(newPassword: newPassword),
        );
      } finally {
        await _secure.deleteToken();
      }
      return unit;
    });
  }

  Future<AuthSession> _persistSession(AuthTokenResponse res) async {
    await _secure.saveToken(res.token);
    await _local.setBool(StorageKeys.requiresConsent, res.requiresConsent);
    return AuthSession(token: res.token, requiresConsent: res.requiresConsent);
  }

  /// Uniform error translation: turns Dio + API exceptions into typed Failures.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      final value = await action();
      return Right(value);
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } on ApiException catch (e) {
      return Left(ServerFailure(messages: e.messages, statusCode: e.statusCode));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  Failure _mapDioError(DioException e) {
    final parsed = e.error;
    if (parsed is NetworkException) return const NetworkFailure();
    if (parsed is ApiException) {
      if (parsed.statusCode == 401) {
        return UnauthorizedFailure(messages: parsed.messages);
      }
      return ServerFailure(
        messages: parsed.messages,
        statusCode: parsed.statusCode,
      );
    }
    return const ServerFailure();
  }
}

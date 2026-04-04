import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/recovery_request_models.dart';
import '../models/signup_request_model.dart';
import '../models/verify_email_request_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._remote, this._secureStorage);

  @override
  Future<Either<Failure, void>> verifyEmail(String email) async {
    try {
      await _remote.verifyEmail(VerifyEmailRequestModel(email: email));
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, fieldErrors: e.fieldErrors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> signup({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required String verificationCode,
    required String dateOfBirth,
    String? parentEmail,
    bool? isCoach,
    String? referrerUsername,
  }) async {
    try {
      final response = await _remote.signup(SignupRequestModel(
        signupData: SignupData(
          firstName: firstName,
          lastName: lastName,
          username: username,
          email: email,
          password: password,
          dateOfBirth: dateOfBirth,
          parentEmail: parentEmail,
          isCoach: isCoach,
        ),
        verificationCode: verificationCode,
        referrerUsername: referrerUsername,
      ));
      await _secureStorage.saveToken(response.token);
      return Right(AuthToken(
        token: response.token,
        requiresConsent: response.requiresConsent,
      ));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, fieldErrors: e.fieldErrors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> login({
    required String credential,
    required String password,
  }) async {
    try {
      final response = await _remote.login(LoginRequestModel(
        credential: credential,
        password: password,
      ));
      await _secureStorage.saveToken(response.token);
      return Right(AuthToken(
        token: response.token,
        requiresConsent: response.requiresConsent,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> initiateOtpRecovery(String email) async {
    try {
      await _remote.initiateOtpRecovery(OtpInitiateModel(email: email));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> validateOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _remote.validateOtp(
        OtpValidateModel(email: email, otp: otp),
      );
      return Right(AuthToken(token: response.token));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> initiateMagicLink(String email) async {
    try {
      await _remote.initiateMagicLink(MagicLinkInitiateModel(email: email));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> validateMagicKey(String magicKey) async {
    try {
      final response = await _remote.validateMagicKey(
        MagicKeyValidateModel(magicKey: magicKey),
      );
      return Right(AuthToken(token: response.token));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String newPassword,
    required String token,
  }) async {
    try {
      await _remote.resetPassword(
        PasswordResetModel(newPassword: newPassword),
        token,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resendConsent() async {
    try {
      await _remote.resendConsent();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<bool> isAuthenticated() => _secureStorage.hasToken();

  @override
  Future<void> logout() => _secureStorage.clearAll();
}

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/auth_dtos.dart';
import '../entities/auth_session.dart';

/// Abstract contract for the auth feature. Implemented by
/// [AuthRepositoryImpl] in the data layer. Use cases depend on this only.
abstract class AuthRepository {
  Future<Either<Failure, Unit>> sendEmailVerification(String email);

  /// Validate registration fields server-side (username taken, email used,
  /// age rules) before collecting an OTP. Matches web's step-1 check.
  Future<Either<Failure, Unit>> validateRegistration(SignupData data);

  Future<Either<Failure, AuthSession>> signup({
    required SignupData data,
    required String verificationCode,
    String? referrerUsername,
  });

  Future<Either<Failure, AuthSession>> login({
    required String credential,
    required String password,
  });

  Future<Either<Failure, Unit>> logout();

  /// Read any persisted session from secure storage. Returns null if the user
  /// has never logged in (or has logged out).
  Future<AuthSession?> restoreSession();

  Future<Either<Failure, Unit>> initiateRecoveryOtp(String email);

  /// Returns the recovery-scoped JWT to be used against reset-password.
  Future<Either<Failure, String>> validateRecoveryOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, Unit>> resetPassword({
    required String recoveryToken,
    required String newPassword,
  });
}

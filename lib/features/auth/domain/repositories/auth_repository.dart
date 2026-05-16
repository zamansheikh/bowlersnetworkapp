import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/auth_dtos.dart';
import '../entities/auth_session.dart';

/// Abstract contract for the auth feature. Implemented by
/// [AuthRepositoryImpl] in the data layer. Use cases depend on this only.
abstract class AuthRepository {
  /// Step 1 — validate registration fields server-side (username taken,
  /// email used, age rules) before asking for an OTP. Matches web's
  /// `signup/validate/registration`.
  Future<Either<Failure, Unit>> validateRegistration(SignupData data);

  /// Step 2 — kick off the signup flow: emails an OTP and caches the
  /// registration server-side. Matches web's `signup/submit`.
  Future<Either<Failure, Unit>> submitSignup(SignupData data);

  /// Step 3 — verify OTP and finalise the account. Returns the auth session.
  /// Matches web's `signup/complete`.
  Future<Either<Failure, AuthSession>> completeSignup({
    required SignupData data,
    required String verificationCode,
    List<int> favoriteBrandIds = const [],
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

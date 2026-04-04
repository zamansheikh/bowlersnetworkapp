import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_token.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> verifyEmail(String email);

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
  });

  Future<Either<Failure, AuthToken>> login({
    required String credential,
    required String password,
  });

  Future<Either<Failure, void>> initiateOtpRecovery(String email);

  Future<Either<Failure, AuthToken>> validateOtp({
    required String email,
    required String otp,
  });

  Future<Either<Failure, void>> initiateMagicLink(String email);

  Future<Either<Failure, AuthToken>> validateMagicKey(String magicKey);

  Future<Either<Failure, void>> resetPassword({
    required String newPassword,
    required String token,
  });

  Future<Either<Failure, void>> resendConsent();

  Future<bool> isAuthenticated();

  Future<void> logout();
}

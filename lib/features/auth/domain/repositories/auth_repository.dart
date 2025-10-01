import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/auth_token.dart';
import '../../../home/domain/entities/user.dart';
import '../../data/models/validate_signup_data_request.dart';
import '../../data/models/validate_signup_data_response.dart';
import '../../data/models/send_verification_code_request.dart';
import '../../data/models/send_verification_code_response.dart';
import '../../data/models/verify_email_request.dart';
import '../../data/models/verify_email_response.dart';
import '../../data/models/create_user_request.dart';
import '../../data/models/create_user_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthToken>> login({
    required String username,
    required String password,
  });
  Future<Either<Failure, User>> getProfile();
  Future<void> logout();
  Future<AuthToken?> getPersistedToken();

  // Signup flow methods
  Future<Either<Failure, ValidateSignupDataResponse>> validateSignupData(
    ValidateSignupDataRequest request,
  );
  Future<Either<Failure, SendVerificationCodeResponse>> sendVerificationCode(
    SendVerificationCodeRequest request,
  );
  Future<Either<Failure, VerifyEmailResponse>> verifyEmail(
    VerifyEmailRequest request,
  );
  Future<Either<Failure, CreateUserResponse>> createUser(
    CreateUserRequest request,
  );

  // Account deletion
  Future<Either<Failure, void>> deleteAccount();
}

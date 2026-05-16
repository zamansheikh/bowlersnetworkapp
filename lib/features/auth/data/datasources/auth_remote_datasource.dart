import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/auth_dtos.dart';

part 'auth_remote_datasource.g.dart';

@injectable
@RestApi()
abstract class AuthRemoteDatasource {
  @factoryMethod
  factory AuthRemoteDatasource(Dio dio) = _AuthRemoteDatasource;

  @POST(Endpoints.signupValidateRegistration)
  Future<MessageResponse> validateRegistration(
    @Body() ValidateRegistrationRequest body,
  );

  /// Sends the OTP email and stashes registration server-side.
  @POST(Endpoints.signupSubmit)
  Future<MessageResponse> submitSignup(@Body() SignupSubmitRequest body);

  /// Verifies the OTP and finalises the account. Returns auth token.
  @POST(Endpoints.signupComplete)
  Future<AuthTokenResponse> completeSignup(@Body() SignupCompleteRequest body);

  @POST(Endpoints.login)
  Future<AuthTokenResponse> login(@Body() LoginRequest body);

  @POST(Endpoints.recoveryInitiateOtp)
  Future<MessageResponse> initiateRecoveryOtp(@Body() EmailRequest body);

  @POST(Endpoints.recoveryValidateOtp)
  Future<AuthTokenResponse> validateRecoveryOtp(
    @Body() ValidateOtpRequest body,
  );

  @POST(Endpoints.recoveryInitiateMagicLink)
  Future<MessageResponse> initiateMagicLink(@Body() EmailRequest body);

  @POST(Endpoints.recoveryValidateMagicKey)
  Future<AuthTokenResponse> validateMagicKey(
    @Body() ValidateMagicKeyRequest body,
  );

  @POST(Endpoints.recoveryResetPassword)
  Future<MessageResponse> resetPassword(@Body() ResetPasswordRequest body);
}

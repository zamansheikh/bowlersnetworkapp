import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/recovery_request_models.dart';
import '../models/signup_request_model.dart';
import '../models/verify_email_request_model.dart';

@lazySingleton
class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource(this._dio);

  Future<void> verifyEmail(VerifyEmailRequestModel model) async {
    await _dio.post(Endpoints.verifyEmail, data: model.toJson());
  }

  Future<AuthResponseModel> signup(SignupRequestModel model) async {
    final response = await _dio.post(Endpoints.signup, data: model.toJson());
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponseModel> login(LoginRequestModel model) async {
    final response = await _dio.post(Endpoints.login, data: model.toJson());
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> initiateOtpRecovery(OtpInitiateModel model) async {
    await _dio.post(Endpoints.recoveryInitiateOtp, data: model.toJson());
  }

  Future<AuthResponseModel> validateOtp(OtpValidateModel model) async {
    final response = await _dio.post(Endpoints.recoveryValidateOtp, data: model.toJson());
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> initiateMagicLink(MagicLinkInitiateModel model) async {
    await _dio.post(Endpoints.recoveryInitiateMagicLink, data: model.toJson());
  }

  Future<AuthResponseModel> validateMagicKey(MagicKeyValidateModel model) async {
    final response = await _dio.post(Endpoints.recoveryValidateMagicKey, data: model.toJson());
    return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> resetPassword(PasswordResetModel model, String token) async {
    await _dio.post(
      Endpoints.recoveryResetPassword,
      data: model.toJson(),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> resendConsent() async {
    await _dio.post(Endpoints.consentResend);
  }
}

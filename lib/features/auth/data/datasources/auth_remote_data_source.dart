import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';
import '../../../home/data/models/user_model.dart';
import '../models/auth_token_model.dart';
import '../models/validate_signup_data_request.dart';
import '../models/validate_signup_data_response.dart';
import '../models/send_verification_code_request.dart';
import '../models/send_verification_code_response.dart';
import '../models/verify_email_request.dart';
import '../models/verify_email_response.dart';
import '../models/create_user_request.dart';
import '../models/create_user_response.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> login(String username, String password);
  Future<UserModel> getProfile(String accessToken);
  Future<ValidateSignupDataResponse> validateSignupData(
    ValidateSignupDataRequest request,
  );
  Future<SendVerificationCodeResponse> sendVerificationCode(
    SendVerificationCodeRequest request,
  );
  Future<VerifyEmailResponse> verifyEmail(VerifyEmailRequest request);
  Future<CreateUserResponse> createUser(CreateUserRequest request);
  Future<void> deleteAccount(String accessToken);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthTokenModel> login(String username, String password) async {
    final response = await dio.post(
      AppConstants.loginEndpoint,
      data: {'username': username, 'password': password},
    );

    return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getProfile(String accessToken) async {
    final response = await dio.get(
      AppConstants.userProfileEndpoint,
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ValidateSignupDataResponse> validateSignupData(
    ValidateSignupDataRequest request,
  ) async {
    final response = await dio.post(
      AppConstants.validateSignupDataEndpoint,
      data: request.toJson(),
    );
    return ValidateSignupDataResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<SendVerificationCodeResponse> sendVerificationCode(
    SendVerificationCodeRequest request,
  ) async {
    final response = await dio.post(
      AppConstants.sendVerificationCodeEndpoint,
      data: request.toJson(),
    );
    return SendVerificationCodeResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<VerifyEmailResponse> verifyEmail(VerifyEmailRequest request) async {
    final response = await dio.post(
      AppConstants.verifyEmailEndpoint,
      data: request.toJson(),
    );
    return VerifyEmailResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<CreateUserResponse> createUser(CreateUserRequest request) async {
    final response = await dio.post(
      AppConstants.createUserEndpoint,
      data: request.toJson(),
    );
    return CreateUserResponse.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAccount(String accessToken) async {
    // Get the stored username
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';

    await dio.delete(
      '/delete-account',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      data: {'username': username},
    );
  }
}

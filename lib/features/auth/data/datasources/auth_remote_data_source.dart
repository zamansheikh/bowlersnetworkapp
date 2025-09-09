import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/constants.dart';
import '../../../home/data/models/user_model.dart';
import '../models/auth_token_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> login(String username, String password);
  Future<UserModel> getProfile(String accessToken);
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
}

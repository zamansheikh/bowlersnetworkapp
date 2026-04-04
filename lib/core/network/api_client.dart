import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio dio(SecureStorageService secureStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(secureStorage),
      ErrorInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
      ),
    ]);

    return dio;
  }

  /// A Dio instance without auth headers, used for uploading to presigned URLs
  @Named('uploadDio')
  @lazySingleton
  Dio uploadDio() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );
  }
}

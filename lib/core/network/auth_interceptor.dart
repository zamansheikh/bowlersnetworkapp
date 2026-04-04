import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _secureStorage.clearAll();
    }
    handler.next(err);
  }
}

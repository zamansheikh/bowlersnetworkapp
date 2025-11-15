import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';

@module
abstract class NetworkModule {
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      LogInterceptor(
        // requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );

    // Add Bearer token auth interceptor using QueuedInterceptorsWrapper for proper async handling
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Get token from SharedPreferences using the correct key from AppConstants
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString(AppConstants.tokenKey);

            print(
              '✅ Auth token from prefs: ${token != null ? 'FOUND' : 'NOT FOUND'}',
            );

            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              print('✅ Authorization header set: Bearer $token');
            } else {
              print(
                '⚠️ No auth token found in SharedPreferences with key: ${AppConstants.tokenKey}',
              );
            }
          } catch (e) {
            print('❌ Error getting auth token: $e');
          }

          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 errors
          if (error.response?.statusCode == 401) {
            print('❌ Authentication failed - 401 response');
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}

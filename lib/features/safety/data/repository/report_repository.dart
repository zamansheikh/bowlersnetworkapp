import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';

abstract class ReportRepository {
  Future<void> reportPost({
    required String postId,
    required String reportedUserId,
    required String reason,
    String? description,
  });

  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
    String? description,
  });

  Future<void> reportMessage({
    required String messageId,
    required String reportedUserId,
    required String reason,
    String? description,
  });
}

@Injectable(as: ReportRepository)
class ReportRepositoryImpl implements ReportRepository {
  late final Dio _dio;
  final SharedPreferences _prefs;

  ReportRepositoryImpl(this._prefs) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  String? _getAuthToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  void _handleUnauthorized() {
    _prefs.remove(AppConstants.tokenKey);
    _prefs.remove(AppConstants.userKey);
  }

  @override
  Future<void> reportPost({
    required String postId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/api/reports/post',
        data: {
          'post_id': postId,
          'reported_user_id': reportedUserId,
          'reason': reason,
          'description': description,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to report post');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
          'Invalid report data: ${e.response?.data['message'] ?? 'Bad request'}',
        );
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Post not found');
      } else if (e.response?.statusCode == 409) {
        throw Exception('You have already reported this post');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to report post: $e');
    }
  }

  @override
  Future<void> reportUser({
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/api/reports/user',
        data: {
          'reported_user_id': reportedUserId,
          'reason': reason,
          'description': description,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to report user');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
          'Invalid report data: ${e.response?.data['message'] ?? 'Bad request'}',
        );
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (e.response?.statusCode == 404) {
        throw Exception('User not found');
      } else if (e.response?.statusCode == 409) {
        throw Exception('You have already reported this user');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to report user: $e');
    }
  }

  @override
  Future<void> reportMessage({
    required String messageId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        '/api/reports/message',
        data: {
          'message_id': messageId,
          'reported_user_id': reportedUserId,
          'reason': reason,
          'description': description,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to report message');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
          'Invalid report data: ${e.response?.data['message'] ?? 'Bad request'}',
        );
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Message not found');
      } else if (e.response?.statusCode == 409) {
        throw Exception('You have already reported this message');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to report message: $e');
    }
  }
}

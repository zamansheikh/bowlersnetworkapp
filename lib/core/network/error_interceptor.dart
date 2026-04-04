import 'dart:io';

import 'package:dio/dio.dart';

import '../error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const NetworkException('Connection timed out. Please try again.');
      case DioExceptionType.connectionError:
        throw const NetworkException('No internet connection.');
      case DioExceptionType.badResponse:
        _handleBadResponse(err);
      default:
        if (err.error is SocketException) {
          throw const NetworkException();
        }
        throw ServerException(
          err.message ?? 'An unexpected error occurred',
          statusCode: err.response?.statusCode,
        );
    }
    handler.next(err);
  }

  void _handleBadResponse(DioException err) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    String message = _extractMessage(data);

    switch (statusCode) {
      case 400:
        throw ValidationException(message, fieldErrors: _extractFieldErrors(data));
      case 401:
        throw AuthException(message, statusCode: statusCode);
      case 403:
        if (_isProfileIncomplete(data)) {
          throw const ServerException('Profile incomplete', statusCode: 403);
        }
        throw AuthException(message, statusCode: statusCode);
      case 404:
        throw ServerException('Not found', statusCode: statusCode);
      case 429:
        throw const ServerException('Too many requests. Please wait a moment.');
      default:
        throw ServerException(message, statusCode: statusCode);
    }
  }

  /// Backend returns errors as: ["message"] or {"message": "..."} or {"detail": "..."} or {"field": ["error"]}
  String _extractMessage(dynamic data) {
    if (data is List && data.isNotEmpty) {
      return data[0].toString();
    }
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) return data['message'].toString();
      if (data.containsKey('detail')) return data['detail'].toString();
      if (data.containsKey('errors') && data['errors'] is List) {
        final errors = data['errors'] as List;
        if (errors.isNotEmpty) return errors[0].toString();
      }
      // Try first field error
      for (final value in data.values) {
        if (value is List && value.isNotEmpty) {
          return value[0].toString();
        }
      }
    }
    return 'Something went wrong';
  }

  bool _isProfileIncomplete(dynamic data) {
    final msg = _extractMessage(data).toLowerCase();
    return msg.contains('profile') && msg.contains('incomplete');
  }

  Map<String, List<String>>? _extractFieldErrors(dynamic data) {
    if (data is Map<String, dynamic>) {
      final Map<String, List<String>> fieldErrors = {};
      data.forEach((key, value) {
        if (key != 'errors' && key != 'message' && key != 'detail') {
          if (value is List) {
            fieldErrors[key] = value.map((e) => e.toString()).toList();
          }
        }
      });
      return fieldErrors.isEmpty ? null : fieldErrors;
    }
    return null;
  }
}

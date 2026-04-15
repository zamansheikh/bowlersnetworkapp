import 'dart:io';

import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Parses the backend's `{"errors": [...]}` shape into an [ApiException] and
/// attaches it to the [DioException.error] field so repositories can read the
/// structured messages without re-parsing JSON.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final parsed = _parse(err);
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: parsed,
        stackTrace: err.stackTrace,
        message: err.message,
      ),
    );
  }

  Object _parse(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return const NetworkException('Connection timed out.');
    }
    if (err.type == DioExceptionType.connectionError ||
        err.error is SocketException) {
      return const NetworkException();
    }

    final data = err.response?.data;
    final messages = _extractMessages(data);
    return ApiException(
      messages: messages,
      statusCode: err.response?.statusCode,
    );
  }

  /// Backend contract: `{"errors": ["msg1", "msg2"]}`.
  List<String> _extractMessages(dynamic data) {
    if (data is Map && data['errors'] is List) {
      return (data['errors'] as List).map((e) => e.toString()).toList();
    }
    if (data is Map && data['detail'] is String) {
      return [data['detail'] as String];
    }
    if (data is Map && data['message'] is String) {
      return [data['message'] as String];
    }
    if (data is List && data.isNotEmpty) {
      return data.map((e) => e.toString()).toList();
    }
    return const ['Something went wrong.'];
  }
}

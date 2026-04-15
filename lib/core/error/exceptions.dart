/// Thrown by the error interceptor when the backend returns `{errors: [...]}`.
class ApiException implements Exception {
  const ApiException({required this.messages, this.statusCode});

  final List<String> messages;
  final int? statusCode;

  @override
  String toString() => 'ApiException(${statusCode ?? '?'}): ${messages.join(' ')}';
}

class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache error']);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  const AuthException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  const ValidationException(this.message, {this.fieldErrors});

  final String message;
  final Map<String, List<String>>? fieldErrors;

  @override
  String toString() => 'ValidationException: $message';
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ServerException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache error']);

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException(this.message, {this.statusCode});

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  const ValidationException(this.message, {this.fieldErrors});

  @override
  String toString() => 'ValidationException: $message';
}

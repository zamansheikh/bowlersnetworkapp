class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://backend.bowlersnetwork.com';
  static const String wsBaseUrl = 'wss://backend.bowlersnetwork.com';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int defaultPageSize = 20;
}

class Endpoints {
  Endpoints._();

  // Cloud / file upload
  static const String uploadSinglepart =
      '/api/cloud/upload/singlepart/requests/initiate';
  static const String uploadMultipartInitiate =
      '/api/cloud/upload/multipart/requests/initiate';
  static const String uploadMultipartComplete =
      '/api/cloud/upload/multipart/requests/complete';

  // Auth (populated in Phase 1)
}

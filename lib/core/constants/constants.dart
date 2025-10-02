import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API
  static const String baseUrl = 'https://test.bowlersnetwork.com';
  static const String loginEndpoint = '/api/amateur-login';
  static const String userProfileEndpoint = '/api/user/profile';
  static const String validateSignupDataEndpoint = '/api/validate-signup-data';
  static const String sendVerificationCodeEndpoint =
      '/api/send-verification-code';
  static const String verifyEmailEndpoint = '/api/verify-email';
  static const String createUserEndpoint = '/api/create-user';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Preferences Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  static const String themeKey = 'theme';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Mapbox
  static String mapboxAccessToken = dotenv.get('ACCESS_TOKEN', fallback: 'pk.your_mapbox_access_token');
}

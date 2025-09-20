import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';
import '../models/tournament_model.dart';
import 'events_remote_data_source.dart';

@LazySingleton(as: EventsRemoteDataSource)
class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  late final Dio _dio;
  final SharedPreferences _prefs;

  EventsRemoteDataSourceImpl(this._prefs) {
    _configureDio();
  }

  void _configureDio() {
    _dio = Dio(
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

    // Add interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _getAuthToken();
          print(
            '🏆 Interceptor: Token retrieved: ${token != null ? 'Token exists (${token.length} chars)' : 'No token found'}',
          );
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print(
              '🏆 Interceptor: Added Authorization header: Bearer ${token.substring(0, 10)}...',
            );
          } else {
            print(
              '🏆 Interceptor: No token found, skipping Authorization header',
            );
          }
          print('🏆 Interceptor: Final headers: ${options.headers}');
          handler.next(options);
        },
        onError: (error, handler) {
          print('🏆 Events API Error: ${error.message}');
          print('🏆 Events API Error Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[Events API] $object'),
      ),
    );
  }

  String? _getAuthToken() {
    final token = _prefs.getString(AppConstants.tokenKey);
    print(
      '🏆 Auth token retrieved: ${token != null ? 'Token exists (${token.length} chars)' : 'No token found'}',
    );
    return token;
  }

  @override
  Future<List<TournamentModel>> getTournaments() async {
    try {
      print('🏆 EventsDataSource: Fetching tournaments from /api/tournaments');

      final response = await _dio.get('/api/tournaments');

      print('🏆 EventsDataSource: Response status: ${response.statusCode}');
      print('🏆 EventsDataSource: Response data: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data
            .map(
              (json) => TournamentModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception('Failed to load tournaments: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 EventsDataSource: Dio error: ${e.message}');
      if (e.response != null) {
        print('🏆 EventsDataSource: Error response: ${e.response?.data}');
        throw Exception(
          'Failed to load tournaments: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🏆 EventsDataSource: Unexpected error: $e');
      throw Exception('Failed to load tournaments: $e');
    }
  }

  @override
  Future<void> registerForTournament(int tournamentId) async {
    try {
      print('🏆 EventsDataSource: Registering for tournament $tournamentId');

      final response = await _dio.post(
        '/api/tournaments/$tournamentId/register',
      );

      print(
        '🏆 EventsDataSource: Registration response: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 EventsDataSource: Registration error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Registration failed: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  @override
  Future<void> unregisterFromTournament(int tournamentId) async {
    try {
      print('🏆 EventsDataSource: Unregistering from tournament $tournamentId');

      final response = await _dio.delete(
        '/api/tournaments/$tournamentId/register',
      );

      print(
        '🏆 EventsDataSource: Unregistration response: ${response.statusCode}',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to unregister: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏆 EventsDataSource: Unregistration error: ${e.message}');
      if (e.response != null) {
        throw Exception(
          'Unregistration failed: ${e.response?.statusCode} - ${e.response?.data}',
        );
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}

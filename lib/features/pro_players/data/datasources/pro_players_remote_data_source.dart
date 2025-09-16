import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';
import '../models/pro_player_model.dart';
import '../../../home/data/models/feed_post.dart';

abstract class ProPlayersRemoteDataSource {
  Future<List<ProPlayerModel>> getProPlayers();
  Future<ProPlayerModel> getProPlayerById(String userId);
  Future<List<FeedPost>> getUserPosts(String userId);
  Future<bool> followPlayer(int userId);
  Future<bool> unfollowPlayer(int userId);
}

@LazySingleton(as: ProPlayersRemoteDataSource)
class ProPlayersRemoteDataSourceImpl implements ProPlayersRemoteDataSource {
  late final Dio _dio;
  final SharedPreferences _prefs;

  ProPlayersRemoteDataSourceImpl(this._prefs) {
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

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add token if available
          final token = _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized access
            _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  String? _getAuthToken() {
    // Get token from SharedPreferences
    return _prefs.getString(AppConstants.tokenKey);
  }

  void _handleUnauthorized() {
    // Clear token on unauthorized access
    _prefs.remove(AppConstants.tokenKey);
    _prefs.remove(AppConstants.userKey);
    // Note: Navigation should be handled by AuthCubit listening to this error
  }

  @override
  Future<List<ProPlayerModel>> getProPlayers() async {
    try {
      final response = await _dio.get('/api/user/pro-player-public-profile');

      if (response.data is List) {
        return (response.data as List<dynamic>)
            .map((e) => ProPlayerModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid response format: expected List');
      }
    } catch (e) {
      throw Exception('Failed to fetch pro players: $e');
    }
  }

  @override
  Future<ProPlayerModel> getProPlayerById(String userId) async {
    try {
      final response = await _dio.get('/api/user/profile/$userId');
      return ProPlayerModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch pro player $userId: $e');
    }
  }

  @override
  Future<List<FeedPost>> getUserPosts(String userId) async {
    try {
      final response = await _dio.get('/api/user/$userId/posts');

      if (response.data is List) {
        return (response.data as List<dynamic>)
            .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Invalid response format: expected List');
      }
    } catch (e) {
      throw Exception('Failed to fetch user posts: $e');
    }
  }

  @override
  Future<bool> followPlayer(int userId) async {
    try {
      final response = await _dio.post(
        '/api/user/follow',
        data: {'user_id': userId},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to follow player: $e');
    }
  }

  @override
  Future<bool> unfollowPlayer(int userId) async {
    try {
      final response = await _dio.post(
        '/api/user/follow',
        data: {'user_id': userId},
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to unfollow player: $e');
    }
  }
}

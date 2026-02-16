import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../home/data/models/feed_post.dart';
import '../../../../core/constants/constants.dart';

part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  late final Dio _dio;
  final SharedPreferences _prefs;

  ProfileCubit(this._prefs) : super(ProfileInitial()) {
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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString(AppConstants.tokenKey);
          debugPrint(
            '👤 Profile Interceptor: Token retrieved: ${token != null ? 'Token exists (${token.length} chars)' : 'No token found'}',
          );
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint(
              '👤 Profile Interceptor: Added Authorization header: Bearer ${token.substring(0, 10)}...',
            );
          } else {
            debugPrint(
              '👤 Profile Interceptor: No token found, skipping Authorization header',
            );
          }
          debugPrint(
            '👤 Profile Interceptor: Final headers: ${options.headers}',
          );
          handler.next(options);
        },
        onError: (error, handler) {
          debugPrint('👤 Profile API Error: ${error.message}');
          debugPrint('👤 Profile API Error Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        // requestBody: true,
        // responseBody: true,
        logPrint: (object) => debugPrint('[Profile API] $object'),
        // requestHeader: true,
        error: true,
      ),
    );
  }

  Future<void> loadUserPosts() async {
    debugPrint('👤 ProfileCubit: Starting to load user posts');
    emit(ProfileLoaded(isLoadingPosts: true));

    try {
      debugPrint('👤 ProfileCubit: Making request to /api/posts/v2');
      final response = await _dio.get('/api/posts/v2');
      debugPrint(
        '👤 ProfileCubit: Response received - Status: ${response.statusCode}',
      );

      List<FeedPost> posts = [];

      if (response.data is List) {
        posts = (response.data as List<dynamic>)
            .map((e) {
              try {
                return FeedPost.fromJson(e as Map<String, dynamic>);
              } catch (e) {
                debugPrint('👤 ProfileCubit: Error parsing post: $e');
                return null;
              }
            })
            .whereType<FeedPost>()
            .toList();
      } else if (response.data is Map<String, dynamic> &&
          response.data['data'] is List) {
        posts = (response.data['data'] as List<dynamic>)
            .map((e) {
              try {
                return FeedPost.fromJson(e as Map<String, dynamic>);
              } catch (e) {
                debugPrint('👤 ProfileCubit: Error parsing post: $e');
                return null;
              }
            })
            .whereType<FeedPost>()
            .toList();
      } else if (response.data is Map<String, dynamic> &&
          response.data['posts'] is List) {
        // Fallback for old structure if needed, though v2 should be list or data: []
        posts = (response.data['posts'] as List<dynamic>)
            .map((e) {
              try {
                return FeedPost.fromJson(e as Map<String, dynamic>);
              } catch (e) {
                debugPrint('👤 ProfileCubit: Error parsing post: $e');
                return null;
              }
            })
            .whereType<FeedPost>()
            .toList();
      } else {
        debugPrint(
          '👤 ProfileCubit: Unexpected response format: ${response.data}',
        );
        // Handle empty or unexpected/error response gracefully if needed, or throw
        // For now, assume empty list if structure doesn't match known patterns but is successful
        if (response.statusCode == 200) {
          posts = [];
        } else {
          throw Exception('Invalid response format');
        }
      }

      debugPrint('👤 ProfileCubit: Successfully parsed ${posts.length} posts');
      emit(ProfileLoaded(posts: posts, isLoadingPosts: false));
    } catch (e) {
      debugPrint('👤 ProfileCubit: Error loading posts: $e');
      emit(
        ProfileLoaded(
          posts: [],
          isLoadingPosts: false,
          postsError: 'Failed to load posts: $e',
        ),
      );
    }
  }

  Future<void> refreshPosts() async {
    await loadUserPosts();
  }
}

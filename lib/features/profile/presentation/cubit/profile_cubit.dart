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
        requestBody: true,
        responseBody: true,
        logPrint: (object) => debugPrint('[Profile API] $object'),
      ),
    );
  }

  Future<void> loadUserPosts() async {
    debugPrint('👤 ProfileCubit: Starting to load user posts');
    emit(ProfileLoaded(isLoadingPosts: true));

    try {
      debugPrint('👤 ProfileCubit: Making request to /api/user/posts');
      final response = await _dio.get('/api/user/posts');
      debugPrint(
        '👤 ProfileCubit: Response received - Status: ${response.statusCode}',
      );

      if (response.data is Map<String, dynamic> &&
          response.data['posts'] is List) {
        final posts = (response.data['posts'] as List<dynamic>)
            .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
            .toList();

        debugPrint(
          '👤 ProfileCubit: Successfully parsed ${posts.length} posts',
        );
        emit(ProfileLoaded(posts: posts, isLoadingPosts: false));
      } else {
        throw Exception(
          'Invalid response format: expected Map with posts array',
        );
      }
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

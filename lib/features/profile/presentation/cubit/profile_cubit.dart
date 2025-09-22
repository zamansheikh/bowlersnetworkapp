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
          print(
            '👤 Profile Interceptor: Token retrieved: ${token != null ? 'Token exists (${token.length} chars)' : 'No token found'}',
          );
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            print(
              '👤 Profile Interceptor: Added Authorization header: Bearer ${token.substring(0, 10)}...',
            );
          } else {
            print(
              '👤 Profile Interceptor: No token found, skipping Authorization header',
            );
          }
          print('👤 Profile Interceptor: Final headers: ${options.headers}');
          handler.next(options);
        },
        onError: (error, handler) {
          print('👤 Profile API Error: ${error.message}');
          print('👤 Profile API Error Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[Profile API] $object'),
      ),
    );
  }

  Future<void> loadUserPosts() async {
    print('👤 ProfileCubit: Starting to load user posts');
    emit(ProfileLoaded(isLoadingPosts: true));

    try {
      print('👤 ProfileCubit: Making request to /api/user/posts');
      final response = await _dio.get('/api/user/posts');
      print('👤 ProfileCubit: Response received - Status: ${response.statusCode}');

      if (response.data is List) {
        final posts = (response.data as List<dynamic>)
            .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
            .toList();

        print('👤 ProfileCubit: Successfully parsed ${posts.length} posts');
        emit(ProfileLoaded(posts: posts, isLoadingPosts: false));
      } else {
        throw Exception('Invalid response format: expected List');
      }
    } catch (e) {
      print('👤 ProfileCubit: Error loading posts: $e');
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

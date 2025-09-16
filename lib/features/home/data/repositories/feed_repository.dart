import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';
import '../models/feed_post.dart';

@injectable
class FeedRepository {
  static const String _baseUrl = 'https://test.bowlersnetwork.com';
  late final Dio _dio;
  final SharedPreferences _prefs;

  FeedRepository(this._prefs) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add token if available
          // You'll need to get this from your auth service
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

  /// Fetch feed posts
  Future<List<FeedPost>> getFeed() async {
    try {
      final response = await _dio.get('/api/feed');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FeedPost.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load feed');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create a text/media post
  Future<void> createPost({
    required String caption,
    List<File>? mediaFiles,
    List<String>? tags,
  }) async {
    try {
      final formData = FormData();

      // Add caption
      formData.fields.add(MapEntry('caption', caption));

      // Add tags
      if (tags != null) {
        for (final tag in tags) {
          formData.fields.add(MapEntry('tags', tag));
        }
      }

      // Add media files
      if (mediaFiles != null) {
        for (final file in mediaFiles) {
          final fileName = file.path.split('/').last;
          formData.files.add(
            MapEntry(
              'media',
              await MultipartFile.fromFile(file.path, filename: fileName),
            ),
          );
        }
      }

      final response = await _dio.post(
        '/api/user/posts',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create post');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Create a poll post
  Future<void> createPollPost({
    required String caption,
    required String pollTitle,
    required String pollType, // 'Single' or 'Multiple'
    required List<String> pollOptions,
    List<String>? tags,
  }) async {
    try {
      final pollPayload = {
        'caption': caption,
        'tags': tags ?? [],
        'poll': {
          'title': pollTitle,
          'poll_type': pollType,
          'options': pollOptions,
        },
      };

      final response = await _dio.post(
        '/api/user/posts',
        data: pollPayload,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create poll');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Toggle like on a post
  Future<void> toggleLike(int postId) async {
    try {
      final response = await _dio.get('/api/user/post/click-like/$postId');

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle like');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Vote on a poll option
  Future<void> voteOnPoll(int optionId) async {
    try {
      final response = await _dio.get('/api/user/post/vote/$optionId');

      if (response.statusCode != 200) {
        throw Exception('Failed to vote on poll');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Follow a user
  Future<void> followUser(int userId) async {
    try {
      final response = await _dio.post(
        '/api/user/follow',
        data: {'user_id': userId},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to follow user');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Add comment to a post
  Future<PostComment> addComment(int postId, String text) async {
    try {
      final response = await _dio.post(
        '/api/user/post/add-comment/$postId',
        data: {'text': text},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add comment');
      }

      return PostComment.fromJson(response.data['comment']);
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get post details with comments
  Future<FeedPost> getPostDetails(int postId) async {
    try {
      final response = await _dio.get('/api/post/$postId');

      if (response.statusCode == 200) {
        return FeedPost.fromJson(response.data);
      } else {
        throw Exception('Failed to load post details');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Add reply to a comment
  Future<Map<String, dynamic>> addReply(int commentId, String text) async {
    try {
      final response = await _dio.post(
        '/api/user/post/add-reply/$commentId',
        data: {'text': text},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to add reply');
      }

      return response.data;
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

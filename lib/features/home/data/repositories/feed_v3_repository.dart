import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/feed_v3_post.dart';

/// Repository for FeedV3 API endpoints
/// Uses the injected Dio instance (which already has auth interceptor)
@lazySingleton
class FeedV3Repository {
  final Dio _dio;

  FeedV3Repository(this._dio);

  /// Fetch paginated feed
  /// GET /api/newsfeed/v1/feed/?page={page}&page_size={pageSize}
  Future<PaginatedFeedResponse> getFeed({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/api/newsfeed/v1/feed/',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return PaginatedFeedResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load feed: ${e.message}');
    }
  }

  /// Fetch single post by numeric id
  /// GET /api/newsfeed/v1/{id}
  Future<FeedV3Post> getPost(int id) async {
    try {
      final response = await _dio.get('/api/newsfeed/v1/$id');
      return FeedV3Post.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load post: ${e.message}');
    }
  }

  /// Toggle like on a post
  /// POST /api/newsfeed/v1/{id}/like/
  Future<Map<String, dynamic>> toggleLike(int postId) async {
    try {
      final response = await _dio.post('/api/newsfeed/v1/$postId/like/');
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to toggle like: ${e.message}');
    }
  }

  /// Get paginated comments for a post
  /// GET /api/newsfeed/v1/{id}/comments/?page={page}&page_size={pageSize}
  Future<PaginatedCommentsResponse> getComments(
    int postId, {
    int page = 1,
    int pageSize = 15,
  }) async {
    try {
      final response = await _dio.get(
        '/api/newsfeed/v1/$postId/comments/',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return PaginatedCommentsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load comments: ${e.message}');
    }
  }

  /// Add a comment to a post (or reply to a comment)
  /// POST /api/newsfeed/v1/{id}/comments/
  Future<FeedV3Comment> addComment(
    int postId, {
    required String text,
    int? parentId,
  }) async {
    try {
      final data = <String, dynamic>{'text': text};
      if (parentId != null) data['parent_id'] = parentId;

      final response = await _dio.post(
        '/api/newsfeed/v1/$postId/comments/',
        data: data,
      );
      return FeedV3Comment.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to add comment: ${e.message}');
    }
  }

  /// Like a comment
  /// POST /api/newsfeed/v1/comments/{commentId}/like/
  Future<Map<String, dynamic>> likeComment(int commentId) async {
    try {
      final response = await _dio.post(
        '/api/newsfeed/v1/comments/$commentId/like/',
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to like comment: ${e.message}');
    }
  }

  /// Delete a comment
  /// DELETE /api/newsfeed/v1/comments/{commentId}/
  Future<void> deleteComment(int commentId) async {
    try {
      await _dio.delete('/api/newsfeed/v1/comments/$commentId/');
    } on DioException catch (e) {
      throw Exception('Failed to delete comment: ${e.message}');
    }
  }

  /// Vote on a poll
  /// POST /api/newsfeed/v1/{id}/vote/
  Future<Map<String, dynamic>> vote(int postId, List<int> optionIds) async {
    try {
      final response = await _dio.post(
        '/api/newsfeed/v1/$postId/vote/',
        data: {'option_ids': optionIds},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to vote: ${e.message}');
    }
  }

  /// Unvote on a poll
  /// DELETE /api/newsfeed/v1/{id}/vote/
  Future<void> unvote(int postId) async {
    try {
      await _dio.delete('/api/newsfeed/v1/$postId/vote/');
    } on DioException catch (e) {
      throw Exception('Failed to unvote: ${e.message}');
    }
  }
}

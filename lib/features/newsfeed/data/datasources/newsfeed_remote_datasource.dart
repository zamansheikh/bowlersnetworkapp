import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/post_models.dart';

@lazySingleton
class NewsfeedRemoteDataSource {
  final Dio _dio;

  NewsfeedRemoteDataSource(this._dio);

  // ── Feed ─────────────────────────────────────────────

  Future<List<PostModel>> getFeed({int? cursor, int pageSize = 20, String? filter}) async {
    final params = <String, dynamic>{'page_size': pageSize};
    if (cursor != null) params['cursor'] = cursor;
    if (filter != null) params['filter'] = filter;
    final response = await _dio.get(Endpoints.feed, queryParameters: params);
    final posts = (response.data['posts'] as List?) ?? [];
    return posts.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Post Creation ────────────────────────────────────

  Future<PostModel> createTextPost({required String caption, String audience = 'public'}) async {
    final response = await _dio.post(Endpoints.createTextPost, data: {
      'caption': caption, 'audience': audience,
    });
    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PostModel> createPhotoPost({
    required List<String> mediaUrls,
    String caption = '',
    String audience = 'public',
  }) async {
    final response = await _dio.post(Endpoints.createPhotoPost, data: {
      'media_urls': mediaUrls, 'caption': caption, 'audience': audience,
    });
    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PostModel> createVideoPost({
    required String videoUrl,
    String? thumbnailUrl,
    String caption = '',
    String audience = 'public',
  }) async {
    final response = await _dio.post(Endpoints.createVideoPost, data: {
      'video_url': videoUrl,
      'thumbnail_url': ?thumbnailUrl,
      'caption': caption, 'audience': audience,
    });
    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PostModel> createScorePost({
    required int totalScore,
    required String gameType,
    String? mediaUrl,
    double? strikePercentage,
    int? splitCount,
    String templateStyle = 'minimal',
    String caption = '',
    String audience = 'public',
  }) async {
    final response = await _dio.post(Endpoints.createScorePost, data: {
      'total_score': totalScore,
      'game_type': gameType,
      'media_url': ?mediaUrl,
      'strike_percentage': ?strikePercentage,
      'split_count': ?splitCount,
      'template_style': templateStyle,
      'caption': caption,
      'audience': audience,
    });
    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PostModel> createPollPost({
    required String question,
    required List<Map<String, dynamic>> options,
    String pollType = 'single',
    int expiryHours = 24,
    String caption = '',
    String audience = 'public',
  }) async {
    final response = await _dio.post(Endpoints.createPollPost, data: {
      'question': question,
      'options': options,
      'poll_type': pollType,
      'expiry_hours': expiryHours,
      'caption': caption,
      'audience': audience,
    });
    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ── Interactions ─────────────────────────────────────

  Future<Map<String, dynamic>> react(int postId, String reactionType) async {
    final response = await _dio.post(Endpoints.postReact('$postId'), data: {'reaction_type': reactionType});
    return response.data as Map<String, dynamic>;
  }

  Future<bool> toggleSave(int postId) async {
    final response = await _dio.post(Endpoints.postSave('$postId'));
    return response.data['saved'] as bool? ?? false;
  }

  Future<PostModel> sharePost(int postId, {String caption = ''}) async {
    final response = await _dio.post(Endpoints.postShare('$postId'), data: {'caption': caption});
    return PostModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> hidePost(int postId) async {
    await _dio.post(Endpoints.postHide('$postId'));
  }

  Future<void> deletePost(int postId) async {
    await _dio.delete(Endpoints.post('$postId'));
  }

  // ── Comments ─────────────────────────────────────────

  Future<List<CommentModel>> getComments(int postId, {int page = 1, int pageSize = 20}) async {
    final response = await _dio.get(Endpoints.postComments('$postId'), queryParameters: {
      'page': page, 'page_size': pageSize,
    });
    final comments = (response.data['comments'] as List?) ?? [];
    return comments.map((e) => CommentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CommentModel> createComment(int postId, {required String text, int? parentId, String? mediaUrl}) async {
    final response = await _dio.post(Endpoints.postComments('$postId'), data: {
      'text': text,
      'parent_id': ?parentId,
      'media_url': ?mediaUrl,
    });
    return CommentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<bool> toggleCommentLike(int commentId) async {
    final response = await _dio.post(Endpoints.likeComment('$commentId'));
    return response.data['liked'] as bool? ?? false;
  }

  // ── Poll ─────────────────────────────────────────────

  Future<void> votePoll(int postId, int optionId) async {
    await _dio.post(Endpoints.postVote('$postId'), data: {'option_id': optionId});
  }

  // ── User Posts ───────────────────────────────────────

  Future<List<PostModel>> getMyPosts({int page = 1, int pageSize = 20}) async {
    final response = await _dio.get(Endpoints.myPosts, queryParameters: {'page': page, 'page_size': pageSize});
    final posts = (response.data['posts'] as List?) ?? [];
    return posts.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PostModel>> getUserPosts(int userId, {int page = 1, int pageSize = 20}) async {
    final response = await _dio.get(Endpoints.userPosts(userId), queryParameters: {'page': page, 'page_size': pageSize});
    final posts = (response.data['posts'] as List?) ?? [];
    return posts.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

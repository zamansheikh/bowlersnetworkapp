import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/comment_dto.dart';
import '../models/post_dto.dart';

part 'newsfeed_remote_datasource.g.dart';

@injectable
@RestApi()
abstract class NewsfeedRemoteDatasource {
  @factoryMethod
  factory NewsfeedRemoteDatasource(Dio dio) = _NewsfeedRemoteDatasource;

  @GET(Endpoints.feed)
  Future<FeedResponseDto> getFeed({
    @Query('filter') String? filter,
    @Query('cursor') int? cursor,
    @Query('page_size') int? pageSize,
  });

  @GET('/api/newsfeed/{id}')
  Future<PostDto> getPost(@Path('id') String id);

  /// Logged-in user's own posts — paginated. Page-based (NOT cursor) to
  /// match the backend endpoint shape.
  @GET(Endpoints.myPosts)
  Future<FeedResponseDto> getMyPosts({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  /// Another user's public posts.
  @GET('/api/newsfeed/users/{userId}/posts')
  Future<FeedResponseDto> getUserPosts(
    @Path('userId') int userId, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @POST('/api/newsfeed/{id}/react')
  Future<ReactionResponseDto> react(
    @Path('id') String id,
    @Body() ReactionRequestDto body,
  );

  @POST('/api/newsfeed/{id}/save')
  Future<SaveResponseDto> toggleSave(@Path('id') String id);

  @POST('/api/newsfeed/{id}/hide')
  Future<void> hidePost(@Path('id') String id);

  @POST('/api/newsfeed/{id}/pin')
  Future<PinResponseDto> pinPost(@Path('id') String id);

  @PATCH('/api/newsfeed/{id}/comments-toggle')
  Future<CommentsToggleResponseDto> togglePostComments(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  // ── Create endpoints ──
  // All return the newly-created post's full payload (same shape as feed).

  @POST(Endpoints.createTextPost)
  Future<PostDto> createTextPost(@Body() Map<String, dynamic> body);

  @POST(Endpoints.createPhotoPost)
  Future<PostDto> createPhotoPost(@Body() Map<String, dynamic> body);

  @POST(Endpoints.createVideoPost)
  Future<PostDto> createVideoPost(@Body() Map<String, dynamic> body);

  @POST(Endpoints.createScorePost)
  Future<PostDto> createScorePost(@Body() Map<String, dynamic> body);

  @POST(Endpoints.createPollPost)
  Future<PostDto> createPollPost(@Body() Map<String, dynamic> body);

  // ── Comments ────────────────────────────────────────────────────────────────
  @GET('/api/newsfeed/{uid}/comments')
  Future<CommentsPageDto> listComments(
    @Path('uid') String postUid, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @POST('/api/newsfeed/{uid}/comments')
  Future<CommentDto> createComment(
    @Path('uid') String postUid,
    @Body() Map<String, dynamic> body,
  );

  @PATCH('/api/newsfeed/comments/{id}')
  Future<CommentDto> editComment(
    @Path('id') int commentId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/newsfeed/comments/{id}')
  Future<void> deleteComment(@Path('id') int commentId);

  @POST('/api/newsfeed/comments/{id}/like')
  Future<FlagToggleResponseDto> likeComment(@Path('id') int commentId);

  @POST('/api/newsfeed/comments/{id}/pin')
  Future<FlagToggleResponseDto> pinComment(@Path('id') int commentId);

  @POST('/api/newsfeed/comments/{id}/hide')
  Future<FlagToggleResponseDto> hideComment(@Path('id') int commentId);

  @GET('/api/newsfeed/comments/{id}/replies')
  Future<RepliesPageDto> listReplies(
    @Path('id') int commentId, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  // ── Share / Report ─────────────────────────────────────────────────────────
  @POST('/api/newsfeed/{uid}/share')
  Future<PostDto> sharePost(
    @Path('uid') String postUid,
    @Body() Map<String, dynamic> body,
  );

  @POST(Endpoints.report)
  Future<void> submitReport(@Body() Map<String, dynamic> body);
}

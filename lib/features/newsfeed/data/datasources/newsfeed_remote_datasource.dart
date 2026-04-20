import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
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

  @POST('/api/newsfeed/{id}/react')
  Future<ReactionResponseDto> react(
    @Path('id') String id,
    @Body() ReactionRequestDto body,
  );

  @POST('/api/newsfeed/{id}/save')
  Future<SaveResponseDto> toggleSave(@Path('id') String id);

  @POST('/api/newsfeed/{id}/hide')
  Future<void> hidePost(@Path('id') String id);

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
}

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/live_dtos.dart';

part 'live_remote_datasource.g.dart';

@injectable
@RestApi()
abstract class LiveRemoteDatasource {
  @factoryMethod
  factory LiveRemoteDatasource(Dio dio) = _LiveRemoteDatasource;

  @POST(Endpoints.liveStart)
  Future<LiveBroadcastDto> start(@Body() Map<String, dynamic> body);

  @POST('/api/games/lives/{id}/end')
  Future<void> end(@Path('id') int id);

  @GET(Endpoints.liveMyActive)
  Future<LiveMyActiveDto> myActive();

  // ── Viewer side ──────────────────────────────────────────────────────────

  @GET(Endpoints.livesList)
  Future<LiveBroadcastListDto> list({
    @Query('scope') String? scope,
    @Query('cursor_id') int? cursorId,
  });

  @GET('/api/games/lives/by-uid/{uid}')
  Future<LiveBroadcastDetailDto> getDetailByUid(@Path('uid') String uid);

  @GET('/api/games/lives/{id}')
  Future<LiveBroadcastDetailDto> getDetailById(@Path('id') int id);

  @GET('/api/games/lives/{id}/comments')
  Future<LiveCommentsPageDto> getComments(
    @Path('id') int id, {
    @Query('cursor_id') int? cursorId,
  });

  @POST('/api/games/lives/{id}/comments')
  Future<LiveCommentDto> postComment(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/games/lives/{liveId}/comments/{commentId}')
  Future<void> deleteComment(
    @Path('liveId') int liveId,
    @Path('commentId') int commentId,
  );

  @POST('/api/games/lives/{id}/react')
  Future<LiveReactionAckDto> react(
    @Path('id') int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/games/lives/{id}/react')
  Future<void> removeReaction(@Path('id') int id);
}

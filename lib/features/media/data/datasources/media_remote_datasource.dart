import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/media_dtos.dart';

part 'media_remote_datasource.g.dart';

/// Video + split endpoints. Per-user lists are keyed on `username`
/// (the singular `/channel/<int:user_id>/` route is misconfigured
/// server-side and 500s — the plural `/channels/<str:username>/` is
/// what works). Global feeds use the bare `/api/media/videos` and
/// `/splits` paths. Responses are wrapped: `{videos|splits: [...],
/// page, page_size}`, sorted pinned-first, then newest.
@injectable
@RestApi()
abstract class MediaRemoteDatasource {
  @factoryMethod
  factory MediaRemoteDatasource(Dio dio) = _MediaRemoteDatasource;

  @GET('/api/media/channels/{username}/videos')
  Future<VideosPageDto> getUserVideos(
    @Path('username') String username, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/api/media/channels/{username}/splits')
  Future<SplitsPageDto> getUserSplits(
    @Path('username') String username, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET(Endpoints.mediaVideos)
  Future<VideosPageDto> getGlobalVideos({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET(Endpoints.mediaSplits)
  Future<SplitsPageDto> getGlobalSplits({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });
}

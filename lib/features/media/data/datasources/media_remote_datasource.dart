import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/media_dtos.dart';

part 'media_remote_datasource.g.dart';

/// Per-user video / split lists. Keyed on `username` (the singular
/// `/channel/<int:user_id>/` route is misconfigured server-side and
/// 500s — the plural `/channels/<str:username>/` is what works).
/// Responses are wrapped: `{videos|splits: [...], page, page_size}`,
/// sorted pinned-first, then newest.
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
}

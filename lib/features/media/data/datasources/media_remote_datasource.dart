import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/media_dtos.dart';

part 'media_remote_datasource.g.dart';

/// Per-user video / split lists. Endpoints return bare arrays sorted
/// pinned-first, then newest. Page-based pagination.
@injectable
@RestApi()
abstract class MediaRemoteDatasource {
  @factoryMethod
  factory MediaRemoteDatasource(Dio dio) = _MediaRemoteDatasource;

  @GET('/api/media/channel/{userId}/videos')
  Future<List<VideoDto>> getUserVideos(
    @Path('userId') int userId, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/api/media/channel/{userId}/splits')
  Future<List<SplitDto>> getUserSplits(
    @Path('userId') int userId, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });
}

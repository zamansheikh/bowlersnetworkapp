import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/home_preview_dtos.dart';

part 'home_preview_datasource.g.dart';

/// One datasource for everything the home screen previews. The full
/// chatter / events / media / live features each get their own modules
/// when they're built out; this class only fetches what the home shows.
@injectable
@RestApi()
abstract class HomePreviewDatasource {
  @factoryMethod
  factory HomePreviewDatasource(Dio dio) = _HomePreviewDatasource;

  @GET(Endpoints.chatterDiscussions)
  Future<DiscussionsPageDto> getDiscussions({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET(Endpoints.mediaVideos)
  Future<VideosPageDto> getVideos({
    @Query('page_size') int? pageSize,
  });

  @GET(Endpoints.mediaSplits)
  Future<SplitsPageDto> getSplits({
    @Query('page_size') int? pageSize,
  });

  @GET(Endpoints.eventsFeed)
  Future<EventsPageDto> getEvents({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
    @Query('scope') String? scope,
  });

  @GET(Endpoints.gamesLives)
  Future<LiveBroadcastsPageDto> getLiveBroadcasts({
    @Query('scope') String? scope,
  });
}

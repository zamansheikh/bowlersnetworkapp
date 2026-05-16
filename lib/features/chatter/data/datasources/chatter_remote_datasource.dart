import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/chatter_dtos.dart';

part 'chatter_remote_datasource.g.dart';

/// Wire to /api/chatter/*. Detail GET is keyed by the discussion's UID
/// string; every mutating endpoint below uses the numeric DB id returned
/// in the detail payload.
@injectable
@RestApi()
abstract class ChatterRemoteDatasource {
  @factoryMethod
  factory ChatterRemoteDatasource(Dio dio) = _ChatterRemoteDatasource;

  @GET(Endpoints.chatterTopics)
  Future<TopicsResponseDto> getTopics();

  @GET(Endpoints.chatterDiscussions)
  Future<DiscussionsPageDto> getDiscussions({
    @Query('topic') int? topicId,
    @Query('sort') String? sort,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/api/chatter/discussions/{uid}')
  Future<DiscussionFullDto> getDiscussion(@Path('uid') String uid);

  @POST('/api/chatter/discussions/{id}/upvote')
  Future<VoteToggleDto> upvoteDiscussion(@Path('id') int id);

  @GET('/api/chatter/discussions/{id}/opinions')
  Future<OpinionsPageDto> getOpinions(
    @Path('id') int discussionId, {
    @Query('sort') String? sort,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @POST('/api/chatter/discussions/{id}/opinions')
  Future<OpinionDto> postOpinion(
    @Path('id') int discussionId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/api/chatter/opinions/{id}/upvote')
  Future<VoteToggleDto> upvoteOpinion(@Path('id') int id);
}

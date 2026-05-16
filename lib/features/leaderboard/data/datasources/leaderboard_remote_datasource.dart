import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/leaderboard_dtos.dart';

part 'leaderboard_remote_datasource.g.dart';

@injectable
@RestApi()
abstract class LeaderboardRemoteDatasource {
  @factoryMethod
  factory LeaderboardRemoteDatasource(Dio dio) = _LeaderboardRemoteDatasource;

  @GET('/api/xp/leaderboard/{boardType}')
  Future<LeaderboardPageDto> getLeaderboard(
    @Path('boardType') String boardType, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/api/xp/ranks')
  Future<List<RankGroupDto>> getRanks();

  @GET('/api/xp/dashboard')
  Future<XpDashboardDto> getDashboard();
}

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/games_dtos.dart';

part 'games_remote_datasource.g.dart';

@injectable
@RestApi()
abstract class GamesRemoteDatasource {
  @factoryMethod
  factory GamesRemoteDatasource(Dio dio) = _GamesRemoteDatasource;

  @GET(Endpoints.gamesSessionsList)
  Future<List<SessionDto>> getSessions({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET(Endpoints.gamesStats)
  Future<UserGameStatsDto> getStats();

  @GET(Endpoints.gamesEquipment)
  Future<List<BallDto>> getEquipment();

  @GET('/api/games/sessions/{uid}')
  Future<SessionDto> getSession(@Path('uid') String uid);

  @GET('/api/games/{id}')
  Future<GameDetailDto> getGame(@Path('id') int id);
}

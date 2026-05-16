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
  Future<List<UserBallDto>> getEquipment();

  @GET(Endpoints.gamesEquipmentStats)
  Future<List<BallStatsDto>> getEquipmentStats();

  @POST(Endpoints.gamesEquipmentAdd)
  Future<UserBallDto> addEquipment(@Body() Map<String, dynamic> body);

  @DELETE('/api/games/equipment/{ballId}/delete')
  Future<void> deleteEquipment(@Path('ballId') int ballId);

  /// Catalog search — used by the ball picker modal. Backend returns
  /// `{balls: [...], has_next: bool}`.
  @GET(Endpoints.ballsCatalog)
  Future<BallCatalogPageDto> searchBalls({
    @Query('search') String? search,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  // ── Stats sub-resources ──
  @GET(Endpoints.gamesStatsPinLeaves)
  Future<List<PinLeaveStatDto>> getStatsPinLeaves();

  @GET(Endpoints.gamesStatsSpares)
  Future<List<SpareCategoryStatDto>> getStatsSpares();

  @GET(Endpoints.gamesStatsTrends)
  Future<List<TrendPointDto>> getStatsTrends({
    @Query('range') int? range,
    @Query('rolling') int? rolling,
  });

  @GET(Endpoints.gamesStatsByCenter)
  Future<List<CenterPerformanceDto>> getStatsByCenter();

  @GET(Endpoints.gamesStatsByContext)
  Future<List<ContextPerformanceDto>> getStatsByContext();

  @GET('/api/games/sessions/{uid}')
  Future<SessionDto> getSession(@Path('uid') String uid);

  @GET('/api/games/{id}')
  Future<GameDetailDto> getGame(@Path('id') int id);

  /// Create a new session. Backend accepts an empty body and fills defaults;
  /// metadata (center/lanes/oil pattern/notes) can be patched later.
  @POST(Endpoints.gamesSessionsCreate)
  Future<SessionDto> createSession(@Body() Map<String, dynamic> body);

  /// Submit a completed game to a session. Body shape mirrors web's
  /// `buildSubmitPayload` in `lib/bowlingScorer.ts`.
  @POST('/api/games/sessions/{uid}/submit-game')
  Future<GameDetailDto> submitGame(
    @Path('uid') String uid,
    @Body() Map<String, dynamic> body,
  );

  /// Quick-score: single total + handedness, no per-frame detail. Backend
  /// creates a synthetic completed game record.
  @POST('/api/games/sessions/{uid}/submit-quick')
  Future<GameDetailDto> submitQuickScore(
    @Path('uid') String uid,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/games/sessions/{uid}/delete')
  Future<void> deleteSession(@Path('uid') String uid);

  @DELETE('/api/games/{id}/delete')
  Future<void> deleteGame(@Path('id') int id);

  /// PUT /api/games/{game_id}/frames/{frame_number} — per-frame sync used
  /// while broadcasting. Body shape matches one entry from
  /// [SubmitFramePayload.toJson].
  @PUT('/api/games/{gameId}/frames/{frameNumber}')
  Future<void> updateFrame(
    @Path('gameId') int gameId,
    @Path('frameNumber') int frameNumber,
    @Body() Map<String, dynamic> body,
  );
}

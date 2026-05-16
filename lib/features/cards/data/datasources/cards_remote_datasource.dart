import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/card_dtos.dart';

part 'cards_remote_datasource.g.dart';

/// Cards endpoints. Three list flavors: viewer's own cards, viewer's
/// collections, and another user's cards. Plus toggle endpoints for
/// like + collect that return authoritative counts.
@injectable
@RestApi()
abstract class CardsRemoteDatasource {
  @factoryMethod
  factory CardsRemoteDatasource(Dio dio) = _CardsRemoteDatasource;

  @GET(Endpoints.myCards)
  Future<CardsPageDto> getMyCards({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET(Endpoints.myCardCollections)
  Future<CardsPageDto> getMyCollections({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/api/cards/user/{userId}')
  Future<CardsPageDto> getUserCards(
    @Path('userId') int userId, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  /// Global feed — everyone's cards, newest first. Same envelope shape
  /// as /my, /collections, and /user/{id}.
  @GET(Endpoints.cardsFeed)
  Future<CardsPageDto> getCardsFeed({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @POST('/api/cards/{cardId}/like')
  Future<CardLikeToggleDto> toggleLike(@Path('cardId') int cardId);

  @POST('/api/cards/{cardId}/collect')
  Future<CardCollectToggleDto> toggleCollect(@Path('cardId') int cardId);
}

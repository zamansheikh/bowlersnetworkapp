import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/search_dtos.dart';

part 'search_remote_datasource.g.dart';

/// Wire to backend search endpoints. CPS (central predictive search) hits
/// `/api/search` with an optional comma-separated `types` filter; the
/// response is a `results` object grouped by content type.
@injectable
@RestApi()
abstract class SearchRemoteDatasource {
  @factoryMethod
  factory SearchRemoteDatasource(Dio dio) = _SearchRemoteDatasource;

  @GET(Endpoints.search)
  Future<SearchResponseDto> search({
    @Query('q') required String query,
    @Query('types') String? types,
  });
}

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/live_dtos.dart';

part 'live_remote_datasource.g.dart';

@injectable
@RestApi()
abstract class LiveRemoteDatasource {
  @factoryMethod
  factory LiveRemoteDatasource(Dio dio) = _LiveRemoteDatasource;

  @POST(Endpoints.liveStart)
  Future<LiveBroadcastDto> start(@Body() Map<String, dynamic> body);

  @POST('/api/games/lives/{id}/end')
  Future<void> end(@Path('id') int id);

  @GET(Endpoints.liveMyActive)
  Future<LiveMyActiveDto> myActive();
}

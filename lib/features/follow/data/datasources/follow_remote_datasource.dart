import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../models/follow_dtos.dart';

part 'follow_remote_datasource.g.dart';

@injectable
@RestApi()
abstract class FollowRemoteDatasource {
  @factoryMethod
  factory FollowRemoteDatasource(Dio dio) = _FollowRemoteDatasource;

  /// Toggle follow — backend uses GET on purpose (POST returns 405).
  @GET('/api/follow/{userId}')
  Future<FollowToggleResponseDto> toggleFollow(@Path('userId') int userId);

  @GET('/api/followers')
  Future<FollowersPageDto> getMyFollowers();

  @GET('/api/followings')
  Future<FollowingsPageDto> getMyFollowings();

  @GET('/api/users/{userId}/followers')
  Future<FollowersPageDto> getUserFollowers(@Path('userId') int userId);

  @GET('/api/users/{userId}/followings')
  Future<FollowingsPageDto> getUserFollowings(@Path('userId') int userId);
}

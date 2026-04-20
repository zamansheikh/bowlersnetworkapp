import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/brand_dto.dart';
import '../models/profile_completion_dto.dart';
import '../models/profile_dto.dart';
import '../models/xp_level_info_dto.dart';

part 'profile_remote_datasource.g.dart';

@injectable
@RestApi()
abstract class ProfileRemoteDatasource {
  @factoryMethod
  factory ProfileRemoteDatasource(Dio dio) = _ProfileRemoteDatasource;

  @GET(Endpoints.myProfile)
  Future<ProfileDto> getMyProfile();

  @GET(Endpoints.profileCompletion)
  Future<ProfileCompletionDto> getCompletion();

  @GET('/api/profile/{username}')
  Future<ProfileDto> getProfileByUsername(@Path('username') String username);

  @GET(Endpoints.xpLevelInfo)
  Future<XpLevelInfoDto> getXpLevelInfo();

  @GET(Endpoints.brands)
  Future<List<BrandDto>> getBrands();

  /// Step 2 of the avatar upload flow — after bytes are pushed to R2, we
  /// save the resulting `public_url` on the profile.
  @POST(Endpoints.profilePicture)
  Future<void> updateProfilePicture(@Body() Map<String, dynamic> body);

  @POST(Endpoints.coverPicture)
  Future<void> updateCoverPicture(@Body() Map<String, dynamic> body);
}

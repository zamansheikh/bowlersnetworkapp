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

  /// Toggles the viewer's favorite status on a brand. Backend echoes
  /// the new boolean back so we don't have to assume.
  @POST('/api/brands/{brandId}/favorite')
  Future<BrandFavoriteToggleDto> toggleBrandFavorite(
    @Path('brandId') int brandId,
  );

  /// Step 2 of the avatar upload flow — after bytes are pushed to R2, we
  /// save the resulting `public_url` on the profile.
  @POST(Endpoints.profilePicture)
  Future<void> updateProfilePicture(@Body() Map<String, dynamic> body);

  @POST(Endpoints.coverPicture)
  Future<void> updateCoverPicture(@Body() Map<String, dynamic> body);

  // ── Field editors ─────────────────────────────────────────────────────────
  // Each endpoint accepts its own narrow body shape. Visibility is per-field
  // via `is_public`. Validation errors come back as `{"errors": [...]}`.

  @POST(Endpoints.profileBio)
  Future<void> updateBio(@Body() Map<String, dynamic> body);

  @POST(Endpoints.profileNickname)
  Future<void> updateNickname(@Body() Map<String, dynamic> body);

  @POST(Endpoints.profileGender)
  Future<void> updateGender(@Body() Map<String, dynamic> body);

  @POST(Endpoints.profileBirthdate)
  Future<void> updateBirthdate(@Body() Map<String, dynamic> body);

  @POST(Endpoints.profileAddress)
  Future<void> updateAddress(@Body() Map<String, dynamic> body);

  @POST(Endpoints.profileHomeCenter)
  Future<void> updateHomeCenter(@Body() Map<String, dynamic> body);

  @POST(Endpoints.profileBallHandlingStyle)
  Future<void> updateBallHandlingStyle(@Body() Map<String, dynamic> body);

  @POST(Endpoints.profileOfficialGameStat)
  Future<void> updateOfficialGameStat(@Body() Map<String, dynamic> body);
}

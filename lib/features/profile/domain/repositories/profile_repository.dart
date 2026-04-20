import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/brand.dart';
import '../entities/profile.dart';
import '../entities/xp_level_info.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getMyProfile();
  Future<Either<Failure, ProfileCompletion>> getCompletion();
  Future<Either<Failure, Profile>> getProfileByUsername(String username);

  /// Lightweight XP snapshot for the profile rank card.
  Future<Either<Failure, XpLevelInfo>> getXpLevelInfo();

  /// Every brand with an `is_favorite` flag — the profile screen filters
  /// to favorites for display.
  Future<Either<Failure, List<Brand>>> getBrands();

  /// Sets the user's profile picture to a pre-uploaded `publicUrl` (from
  /// [CloudUploadService.uploadFile] into the `profiles` bucket).
  Future<Either<Failure, Unit>> updateProfilePicture(String publicUrl);

  /// Same shape, but for the cover image.
  Future<Either<Failure, Unit>> updateCoverPicture(String publicUrl);
}

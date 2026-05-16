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

  /// Toggles the viewer's favorite on a brand. Returns the authoritative
  /// new boolean so the caller can correct an optimistic update.
  Future<Either<Failure, bool>> toggleBrandFavorite(int brandId);

  /// Sets the user's profile picture to a pre-uploaded `publicUrl` (from
  /// [CloudUploadService.uploadFile] into the `profiles` bucket).
  Future<Either<Failure, Unit>> updateProfilePicture(String publicUrl);

  /// Same shape, but for the cover image.
  Future<Either<Failure, Unit>> updateCoverPicture(String publicUrl);

  // ── Per-field editors (used by the edit-profile screen) ──────────────────

  Future<Either<Failure, Unit>> updateBio({
    required String content,
    bool isPublic = true,
  });

  Future<Either<Failure, Unit>> updateNickname({
    required String name,
    bool isPublic = true,
  });

  /// [value] must be `'Male'` or `'Female'` — backend rejects other strings.
  Future<Either<Failure, Unit>> updateGender({
    required String value,
    bool isPublic = true,
  });

  /// [dateOfBirth] in `YYYY-MM-DD`. [parentEmail] is required by the backend
  /// when the date implies the user is under 13.
  Future<Either<Failure, Unit>> updateBirthdate({
    required String dateOfBirth,
    bool isPublic = true,
    String? parentEmail,
  });

  Future<Either<Failure, Unit>> updateAddress({
    required String address,
    required String zipCode,
    required double latitude,
    required double longitude,
    bool isPublic = true,
  });

  Future<Either<Failure, Unit>> updateHomeCenter({
    required int centerId,
    required String centerName,
    bool isPublic = true,
  });

  /// All three fields are required by the backend. Enums:
  ///   * [handedness] — `'Righty'` | `'Lefty'`
  ///   * [ballCarry] — `'One handed'` | `'Two handed'`
  ///   * [grip] — `'With Thumb'` | `'With No Thumb'`
  Future<Either<Failure, Unit>> updateBallHandlingStyle({
    required String handedness,
    required String ballCarry,
    required String grip,
    bool isPublic = true,
  });

  /// Self-reported stats. All fields are optional and only sent when
  /// non-null so partial updates work.
  Future<Either<Failure, Unit>> updateOfficialGameStat({
    num? average,
    int? highGame,
    int? highSeries,
    int? experience,
    bool isPublic = true,
  });
}

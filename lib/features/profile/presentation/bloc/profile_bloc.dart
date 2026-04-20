import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/cloud_upload_service.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/xp_level_info.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Drives the profile screen: profile + XP level info + favorite brands +
/// avatar/cover uploads.
///
/// All three read calls fire in parallel when [ProfileLoadRequested] comes
/// in. Avatar/cover uploads run the two-step pipeline: bytes → R2 →
/// backend PATCH — and optimistically update the in-memory profile so the
/// hero flips to the new URL instantly, before the next full refetch.
@lazySingleton
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._repository, this._upload) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileCompletionRefreshed>(_onCompletionRefreshed);
    on<ProfileCleared>((_, emit) => emit(const ProfileState()));
    on<ProfileAvatarUploadRequested>(_onAvatarUpload);
    on<ProfileCoverUploadRequested>(_onCoverUpload);
  }

  final ProfileRepository _repository;
  final CloudUploadService _upload;

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, errors: const []));

    // Fire all three in parallel. Only a profile failure is fatal — XP and
    // brands are decorative and may legitimately be empty.
    final results = await Future.wait<dynamic>([
      _repository.getMyProfile(),
      _repository.getXpLevelInfo(),
      _repository.getBrands(),
    ], eagerError: false);

    final profileResult = results[0] as Either<Failure, Profile>;
    final xpResult = results[1] as Either<Failure, XpLevelInfo>;
    final brandsResult = results[2] as Either<Failure, List<Brand>>;

    profileResult.fold(
      (failure) => emit(state.copyWith(
        loading: false,
        errors: failure.messages,
      )),
      (profile) {
        final xp = xpResult.fold<XpLevelInfo?>(
          (_) => null,
          (info) => info.hasRecord ? info : null,
        );
        final brands = brandsResult.fold<List<Brand>>(
          (_) => const <Brand>[],
          (all) => all.where((b) => b.isFavorite).toList(growable: false),
        );
        emit(state.copyWith(
          loading: false,
          profile: profile,
          completionPercentage: profile.completionPercentage,
          isComplete: profile.isComplete,
          xp: xp,
          favoriteBrands: brands,
        ));
      },
    );
  }

  Future<void> _onCompletionRefreshed(
    ProfileCompletionRefreshed event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _repository.getCompletion();
    result.fold(
      (_) {}, // silent — completion check is a background probe
      (c) => emit(state.copyWith(
        completionPercentage: c.completionPercentage,
        isComplete: c.isComplete,
      )),
    );
  }

  Future<void> _onAvatarUpload(
    ProfileAvatarUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(uploadingAvatar: true, errors: const []));
    final url = await _uploadAndPatch(
      bytes: event.bytes,
      fileName: event.fileName,
      patch: _repository.updateProfilePicture,
    );
    url.fold(
      (f) => emit(state.copyWith(
        uploadingAvatar: false,
        errors: f.messages,
      )),
      (publicUrl) => emit(state.copyWith(
        uploadingAvatar: false,
        profile: state.profile?._withAvatar(publicUrl),
      )),
    );
  }

  Future<void> _onCoverUpload(
    ProfileCoverUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(uploadingCover: true, errors: const []));
    final url = await _uploadAndPatch(
      bytes: event.bytes,
      fileName: event.fileName,
      patch: _repository.updateCoverPicture,
    );
    url.fold(
      (f) => emit(state.copyWith(
        uploadingCover: false,
        errors: f.messages,
      )),
      (publicUrl) => emit(state.copyWith(
        uploadingCover: false,
        profile: state.profile?._withCover(publicUrl),
      )),
    );
  }

  /// Shared helper: push bytes to R2, then call [patch] with the resulting
  /// public URL. Returns the URL on end-to-end success so the caller can
  /// apply an optimistic state update.
  Future<Either<Failure, String>> _uploadAndPatch({
    required Uint8List bytes,
    required String fileName,
    required Future<Either<Failure, Unit>> Function(String publicUrl) patch,
  }) async {
    final upload = await _upload.uploadFile(
      fileBytes: bytes,
      fileName: fileName,
      bucket: 'profiles',
    );
    return upload.fold(
      (f) async => Left<Failure, String>(f),
      (publicUrl) async {
        final patched = await patch(publicUrl);
        return patched.fold(
          (f) => Left<Failure, String>(f),
          (_) => Right<Failure, String>(publicUrl),
        );
      },
    );
  }
}

extension _ProfileMediaPatch on Profile {
  Profile _withAvatar(String url) => Profile(
        user: user,
        completionPercentage: completionPercentage,
        isComplete: isComplete,
        profilePictureUrl: url,
        coverPictureUrl: coverPictureUrl,
        introVideoUrl: introVideoUrl,
        bio: bio,
        nickname: nickname,
        gender: gender,
        birthdate: birthdate,
        age: age,
        address: address,
        zipCode: zipCode,
        homeCenter: homeCenter,
        handedness: handedness,
        ballCarry: ballCarry,
        grip: grip,
        ballHandlingDescription: ballHandlingDescription,
        contactEmail: contactEmail,
        average: average,
        highGame: highGame,
        highSeries: highSeries,
        experience: experience,
        isCoach: isCoach,
        followerCount: followerCount,
        followingCount: followingCount,
        isFollowing: isFollowing,
        canFollow: canFollow,
      );

  Profile _withCover(String url) => Profile(
        user: user,
        completionPercentage: completionPercentage,
        isComplete: isComplete,
        profilePictureUrl: profilePictureUrl,
        coverPictureUrl: url,
        introVideoUrl: introVideoUrl,
        bio: bio,
        nickname: nickname,
        gender: gender,
        birthdate: birthdate,
        age: age,
        address: address,
        zipCode: zipCode,
        homeCenter: homeCenter,
        handedness: handedness,
        ballCarry: ballCarry,
        grip: grip,
        ballHandlingDescription: ballHandlingDescription,
        contactEmail: contactEmail,
        average: average,
        highGame: highGame,
        highSeries: highSeries,
        experience: experience,
        isCoach: isCoach,
        followerCount: followerCount,
        followingCount: followingCount,
        isFollowing: isFollowing,
        canFollow: canFollow,
      );
}

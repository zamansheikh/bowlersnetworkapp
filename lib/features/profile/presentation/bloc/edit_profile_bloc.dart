import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

/// Drives the edit-profile screen. Each section saves independently via
/// its own POST endpoint; the bloc tracks which fields are currently
/// saving so the rest of the form stays interactive.
///
/// Not a `@lazySingleton` — created per screen instance so its lifecycle
/// matches the route. After each successful save the in-memory profile
/// is patched in place (cheaper than a full re-fetch) and a "saved"
/// signal is emitted so the screen can show a confirmation toast.
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc({
    required ProfileRepository repository,
    required Profile initialProfile,
  })  : _repository = repository,
        super(EditProfileState(profile: initialProfile)) {
    on<EditProfileNicknameSubmitted>(_onNickname);
    on<EditProfileBioSubmitted>(_onBio);
    on<EditProfileGenderSubmitted>(_onGender);
    on<EditProfileBirthdateSubmitted>(_onBirthdate);
    on<EditProfileBallHandlingSubmitted>(_onBallHandling);
    on<EditProfileGameStatsSubmitted>(_onGameStats);
    on<EditProfileAddressSubmitted>(_onAddress);
    on<EditProfileHomeCenterSubmitted>(_onHomeCenter);
  }

  final ProfileRepository _repository;

  Future<void> _onNickname(
    EditProfileNicknameSubmitted event,
    Emitter<EditProfileState> emit,
  ) =>
      _runSave(
        emit: emit,
        field: EditableField.nickname,
        action: () => _repository.updateNickname(name: event.name.trim()),
        patch: (p) => _replace(p, nickname: event.name.trim()),
      );

  Future<void> _onBio(
    EditProfileBioSubmitted event,
    Emitter<EditProfileState> emit,
  ) =>
      _runSave(
        emit: emit,
        field: EditableField.bio,
        action: () => _repository.updateBio(content: event.content.trim()),
        patch: (p) => _replace(p, bio: event.content.trim()),
      );

  Future<void> _onGender(
    EditProfileGenderSubmitted event,
    Emitter<EditProfileState> emit,
  ) =>
      _runSave(
        emit: emit,
        field: EditableField.gender,
        action: () => _repository.updateGender(value: event.value),
        patch: (p) => _replace(p, gender: event.value),
      );

  Future<void> _onBirthdate(
    EditProfileBirthdateSubmitted event,
    Emitter<EditProfileState> emit,
  ) =>
      _runSave(
        emit: emit,
        field: EditableField.birthdate,
        action: () => _repository.updateBirthdate(
          dateOfBirth: event.isoDate,
          parentEmail: event.parentEmail,
        ),
        patch: (p) => _replace(p, birthdate: event.isoDate),
      );

  Future<void> _onBallHandling(
    EditProfileBallHandlingSubmitted event,
    Emitter<EditProfileState> emit,
  ) =>
      _runSave(
        emit: emit,
        field: EditableField.ballHandling,
        action: () => _repository.updateBallHandlingStyle(
          handedness: event.handedness,
          ballCarry: event.ballCarry,
          grip: event.grip,
        ),
        patch: (p) => _replace(
          p,
          handedness: event.handedness,
          ballCarry: event.ballCarry,
          grip: event.grip,
        ),
      );

  Future<void> _onGameStats(
    EditProfileGameStatsSubmitted event,
    Emitter<EditProfileState> emit,
  ) =>
      _runSave(
        emit: emit,
        field: EditableField.gameStats,
        action: () => _repository.updateOfficialGameStat(
          average: event.average,
          highGame: event.highGame,
          highSeries: event.highSeries,
          experience: event.experience,
        ),
        patch: (p) => _replace(
          p,
          average: event.average,
          highGame: event.highGame,
          highSeries: event.highSeries,
          experience: event.experience,
        ),
      );

  Future<void> _onAddress(
    EditProfileAddressSubmitted event,
    Emitter<EditProfileState> emit,
  ) =>
      _runSave(
        emit: emit,
        field: EditableField.address,
        action: () => _repository.updateAddress(
          address: event.address,
          zipCode: event.zipCode,
          latitude: event.latitude,
          longitude: event.longitude,
        ),
        patch: (p) => _replace(
          p,
          address: event.address,
          zipCode: event.zipCode,
        ),
      );

  Future<void> _onHomeCenter(
    EditProfileHomeCenterSubmitted event,
    Emitter<EditProfileState> emit,
  ) =>
      _runSave(
        emit: emit,
        field: EditableField.homeCenter,
        action: () => _repository.updateHomeCenter(
          centerId: event.centerId,
          centerName: event.centerName,
        ),
        patch: (p) => _replace(p, homeCenter: event.centerName),
      );

  /// Shared save plumbing — marks the field as busy, runs the [action],
  /// and on success applies [patch] to the in-memory profile and bumps
  /// the saved-token so the screen can react.
  Future<void> _runSave({
    required Emitter<EditProfileState> emit,
    required EditableField field,
    required Future<dynamic> Function() action,
    required Profile Function(Profile) patch,
  }) async {
    if (state.profile == null) return;
    if (state.busyFields.contains(field)) return;
    emit(state.copyWith(
      busyFields: {...state.busyFields, field},
      errors: const [],
    ));
    final result = await action();
    final asEither = result as dynamic;
    asEither.fold(
      (f) => emit(state.copyWith(
        busyFields: state.busyFields.where((x) => x != field).toSet(),
        errors: f.messages as List<String>,
      )),
      (_) {
        final next = patch(state.profile!);
        emit(state.copyWith(
          profile: next,
          busyFields: state.busyFields.where((x) => x != field).toSet(),
          lastSavedField: field,
          savedToken: state.savedToken + 1,
        ));
      },
    );
  }

  /// Profile has no `copyWith`; this rebuilds it field-by-field while
  /// preserving everything not explicitly overridden.
  Profile _replace(
    Profile base, {
    String? nickname,
    String? bio,
    String? gender,
    String? birthdate,
    String? address,
    String? zipCode,
    String? homeCenter,
    String? handedness,
    String? ballCarry,
    String? grip,
    num? average,
    int? highGame,
    int? highSeries,
    int? experience,
  }) =>
      Profile(
        user: base.user,
        completionPercentage: base.completionPercentage,
        isComplete: base.isComplete,
        profilePictureUrl: base.profilePictureUrl,
        coverPictureUrl: base.coverPictureUrl,
        introVideoUrl: base.introVideoUrl,
        bio: bio ?? base.bio,
        nickname: nickname ?? base.nickname,
        gender: gender ?? base.gender,
        birthdate: birthdate ?? base.birthdate,
        age: base.age,
        address: address ?? base.address,
        zipCode: zipCode ?? base.zipCode,
        homeCenter: homeCenter ?? base.homeCenter,
        handedness: handedness ?? base.handedness,
        ballCarry: ballCarry ?? base.ballCarry,
        grip: grip ?? base.grip,
        ballHandlingDescription: base.ballHandlingDescription,
        contactEmail: base.contactEmail,
        average: average ?? base.average,
        highGame: highGame ?? base.highGame,
        highSeries: highSeries ?? base.highSeries,
        experience: experience ?? base.experience,
        isCoach: base.isCoach,
        followerCount: base.followerCount,
        followingCount: base.followingCount,
        isFollowing: base.isFollowing,
        canFollow: base.canFollow,
      );
}

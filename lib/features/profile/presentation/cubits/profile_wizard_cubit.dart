import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_models.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_wizard_state.dart';

/// Steps the wizard can show. Each maps to a required profile field.
enum WizardStep {
  profilePicture,  // optional but encouraged (not required for completion)
  gender,          // required
  birthdate,       // required
  address,         // required
  homeCenter,      // required
  ballHandling,    // required
  nicknameBio,     // required (nickname required, bio optional)
  completion,      // final celebration
}

@injectable
class ProfileWizardCubit extends Cubit<ProfileWizardState> {
  final ProfileRepository _repository;

  ProfileWizardCubit(this._repository) : super(const ProfileWizardState());

  /// Loads profile from backend, determines which steps to show.
  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true));
    final result = await _repository.getMyProfile();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (profile) {
        // Build the list of steps that still need to be completed
        final steps = <WizardStep>[];

        // Profile picture is always shown first (optional but encouraged)
        final picUrl = profile.profileMedia?.profilePictureUrl;
        final hasCustomPic = picUrl != null && !picUrl.contains('defaults/');
        if (!hasCustomPic) {
          steps.add(WizardStep.profilePicture);
        }

        // Required fields — only show if NOT already added
        if (profile.gender?.isAdded != true) steps.add(WizardStep.gender);
        if (profile.birthdate?.isAdded != true) steps.add(WizardStep.birthdate);
        if (profile.address?.isAdded != true) steps.add(WizardStep.address);
        if (profile.homeCenter?.isAdded != true) steps.add(WizardStep.homeCenter);
        if (profile.ballHandlingStyle?.isAdded != true) steps.add(WizardStep.ballHandling);
        if (profile.nickname?.isAdded != true || profile.bio?.isAdded != true) {
          steps.add(WizardStep.nicknameBio);
        }

        // Always end with completion step
        steps.add(WizardStep.completion);

        emit(state.copyWith(
          isLoading: false,
          profile: profile,
          steps: steps,
          completionPercentage: profile.completionPercentage ?? 0,
          profilePictureUrl: hasCustomPic ? picUrl : null,
          allComplete: steps.length == 1, // only completion step
        ));
      },
    );
  }

  Future<void> loadCenters() async {
    final result = await _repository.getCenters();
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (centers) => emit(state.copyWith(centers: centers)),
    );
  }

  Future<void> uploadProfilePicture({required Uint8List fileBytes, required String fileName}) async {
    emit(state.copyWith(isUploading: true, error: null));
    final result = await _repository.uploadProfilePicture(fileBytes: fileBytes, fileName: fileName);
    result.fold(
      (failure) => emit(state.copyWith(isUploading: false, error: failure.message)),
      (url) => emit(state.copyWith(isUploading: false, profilePictureUrl: url)),
    );
  }

  Future<bool> updateGender(String value) async {
    emit(state.copyWith(isSaving: true, error: null));
    final result = await _repository.updateGender(value: value);
    return result.fold(
      (failure) { emit(state.copyWith(isSaving: false, error: failure.message)); return false; },
      (_) { emit(state.copyWith(isSaving: false)); return true; },
    );
  }

  Future<bool> updateBirthdate(String dateOfBirth) async {
    emit(state.copyWith(isSaving: true, error: null));
    final result = await _repository.updateBirthdate(dateOfBirth: dateOfBirth);
    return result.fold(
      (failure) { emit(state.copyWith(isSaving: false, error: failure.message)); return false; },
      (_) { emit(state.copyWith(isSaving: false)); return true; },
    );
  }

  Future<bool> updateAddress({
    required String address, required String zipCode,
    required double latitude, required double longitude,
  }) async {
    emit(state.copyWith(isSaving: true, error: null));
    final result = await _repository.updateAddress(
      address: address, zipCode: zipCode, latitude: latitude, longitude: longitude,
    );
    return result.fold(
      (failure) { emit(state.copyWith(isSaving: false, error: failure.message)); return false; },
      (_) { emit(state.copyWith(isSaving: false)); return true; },
    );
  }

  Future<bool> updateHomeCenter(int centerId, {String centerName = ''}) async {
    emit(state.copyWith(isSaving: true, error: null));
    final result = await _repository.updateHomeCenter(centerId: centerId, centerName: centerName);
    return result.fold(
      (failure) { emit(state.copyWith(isSaving: false, error: failure.message)); return false; },
      (_) { emit(state.copyWith(isSaving: false)); return true; },
    );
  }

  Future<bool> updateBallHandlingStyle({String? handedness, String? ballCarry, String? grip}) async {
    emit(state.copyWith(isSaving: true, error: null));
    final result = await _repository.updateBallHandlingStyle(
      handedness: handedness, ballCarry: ballCarry, grip: grip,
    );
    return result.fold(
      (failure) { emit(state.copyWith(isSaving: false, error: failure.message)); return false; },
      (_) { emit(state.copyWith(isSaving: false)); return true; },
    );
  }

  Future<bool> updateBio(String content) async {
    emit(state.copyWith(isSaving: true, error: null));
    final result = await _repository.updateBio(content: content);
    return result.fold(
      (failure) { emit(state.copyWith(isSaving: false, error: failure.message)); return false; },
      (_) { emit(state.copyWith(isSaving: false)); return true; },
    );
  }

  Future<bool> updateNickname(String name) async {
    emit(state.copyWith(isSaving: true, error: null));
    final result = await _repository.updateNickname(name: name);
    return result.fold(
      (failure) { emit(state.copyWith(isSaving: false, error: failure.message)); return false; },
      (_) { emit(state.copyWith(isSaving: false)); return true; },
    );
  }

  void clearError() => emit(state.copyWith(error: null));
}

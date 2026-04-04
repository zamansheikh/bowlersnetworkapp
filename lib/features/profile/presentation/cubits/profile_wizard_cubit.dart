import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_models.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_wizard_state.dart';

@injectable
class ProfileWizardCubit extends Cubit<ProfileWizardState> {
  final ProfileRepository _repository;

  ProfileWizardCubit(this._repository) : super(const ProfileWizardState());

  Future<void> loadProfile() async {
    emit(state.copyWith(isLoading: true));
    final result = await _repository.getMyProfile();
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (profile) => emit(state.copyWith(
        isLoading: false,
        profile: profile,
        completionPercentage: profile.completionPercentage ?? 0,
      )),
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
    required String address,
    required String zipCode,
    required double latitude,
    required double longitude,
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

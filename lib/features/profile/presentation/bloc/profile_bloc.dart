import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_my_profile_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Holds the current user's profile + completion data. Emits changes so the
/// router guard can lift the profile gate when [Profile.isComplete] flips true.
@lazySingleton
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._getMyProfile, this._checkCompletion)
      : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileCompletionRefreshed>(_onCompletionRefreshed);
    on<ProfileCleared>((_, emit) => emit(const ProfileState()));
  }

  final GetMyProfileUseCase _getMyProfile;
  final CheckProfileCompletionUseCase _checkCompletion;

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, errors: const []));
    final result = await _getMyProfile(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        loading: false,
        errors: failure.messages,
      )),
      (profile) => emit(state.copyWith(
        loading: false,
        profile: profile,
        completionPercentage: profile.completionPercentage,
        isComplete: profile.isComplete,
      )),
    );
  }

  Future<void> _onCompletionRefreshed(
    ProfileCompletionRefreshed event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _checkCompletion(const NoParams());
    result.fold(
      (_) {}, // silent — completion check is a background probe
      (c) => emit(state.copyWith(
        completionPercentage: c.completionPercentage,
        isComplete: c.isComplete,
      )),
    );
  }
}

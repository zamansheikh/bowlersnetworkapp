import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/profile_models.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

@injectable
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repository;

  ProfileBloc(this._repository) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileFollowToggled>(_onToggleFollow);
  }

  Future<void> _onLoad(ProfileLoadRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = event.username != null
        ? await _repository.getProfileByUsername(event.username!)
        : await _repository.getMyProfile();
    result.fold(
      (f) => emit(state.copyWith(status: ProfileStatus.error, errorMessage: f.message)),
      (profile) => emit(state.copyWith(status: ProfileStatus.loaded, profile: profile)),
    );
  }

  Future<void> _onToggleFollow(ProfileFollowToggled event, Emitter<ProfileState> emit) async {
    final result = await _repository.toggleFollow(event.userId);
    result.fold((_) {}, (isFollowing) {
      if (state.profile != null) {
        emit(state.copyWith(isFollowing: isFollowing));
      }
    });
  }
}

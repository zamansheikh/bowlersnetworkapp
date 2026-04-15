part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => const [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileCompletionRefreshed extends ProfileEvent {
  const ProfileCompletionRefreshed();
}

class ProfileCleared extends ProfileEvent {
  const ProfileCleared();
}

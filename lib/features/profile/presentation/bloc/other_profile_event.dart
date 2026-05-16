part of 'other_profile_bloc.dart';

sealed class OtherProfileEvent extends Equatable {
  const OtherProfileEvent();
  @override
  List<Object?> get props => const [];
}

/// Fire on screen mount (and on pull-to-refresh) to load the profile.
class OtherProfileLoadRequested extends OtherProfileEvent {
  const OtherProfileLoadRequested();
}

/// User tapped the Follow / Following button in the hero. Optimistically
/// flips the bool + nudges the count; the backend's response overwrites.
class OtherProfileFollowToggled extends OtherProfileEvent {
  const OtherProfileFollowToggled();
}

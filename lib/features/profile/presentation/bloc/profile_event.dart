part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  final String? username;
  const ProfileLoadRequested({this.username});
  @override
  List<Object?> get props => [username];
}

class ProfileFollowToggled extends ProfileEvent {
  final int userId;
  const ProfileFollowToggled({required this.userId});
  @override
  List<Object?> get props => [userId];
}

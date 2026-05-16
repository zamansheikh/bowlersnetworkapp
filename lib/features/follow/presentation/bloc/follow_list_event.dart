part of 'follow_list_bloc.dart';

sealed class FollowListEvent extends Equatable {
  const FollowListEvent();
  @override
  List<Object?> get props => const [];
}

class FollowListLoadRequested extends FollowListEvent {
  const FollowListLoadRequested();
}

class FollowListRefreshRequested extends FollowListEvent {
  const FollowListRefreshRequested();
}

class FollowListFollowToggled extends FollowListEvent {
  const FollowListFollowToggled({required this.userId});
  final int userId;
  @override
  List<Object?> get props => [userId];
}

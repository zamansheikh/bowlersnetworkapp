part of 'live_list_bloc.dart';

sealed class LiveListEvent extends Equatable {
  const LiveListEvent();
  @override
  List<Object?> get props => const [];
}

class LiveListLoadRequested extends LiveListEvent {
  const LiveListLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class LiveListRefreshRequested extends LiveListEvent {
  const LiveListRefreshRequested();
}

class LiveListScopeChanged extends LiveListEvent {
  const LiveListScopeChanged(this.scope);
  final LiveListScope scope;
  @override
  List<Object?> get props => [scope];
}

class LiveListNextPageRequested extends LiveListEvent {
  const LiveListNextPageRequested();
}

part of 'user_media_bloc.dart';

sealed class UserMediaEvent extends Equatable {
  const UserMediaEvent();
  @override
  List<Object?> get props => const [];
}

class UserMediaLoadRequested extends UserMediaEvent {
  const UserMediaLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class UserMediaRefreshRequested extends UserMediaEvent {
  const UserMediaRefreshRequested();
}

class UserMediaNextPageRequested extends UserMediaEvent {
  const UserMediaNextPageRequested();
}

class UserMediaSubTabChanged extends UserMediaEvent {
  const UserMediaSubTabChanged(this.kind);
  final MediaKind kind;
  @override
  List<Object?> get props => [kind];
}

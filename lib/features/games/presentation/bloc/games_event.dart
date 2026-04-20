part of 'games_bloc.dart';

sealed class GamesEvent extends Equatable {
  const GamesEvent();
  @override
  List<Object?> get props => const [];
}

class GamesLoadRequested extends GamesEvent {
  const GamesLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class GamesRefreshRequested extends GamesEvent {
  const GamesRefreshRequested();
}

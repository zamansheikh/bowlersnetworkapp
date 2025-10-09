// presentation/bloc/games_list_event.dart

import 'package:equatable/equatable.dart';

abstract class GamesListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadGames extends GamesListEvent {}

class DeleteGame extends GamesListEvent {
  final String gameId;

  DeleteGame(this.gameId);

  @override
  List<Object> get props => [gameId];
}

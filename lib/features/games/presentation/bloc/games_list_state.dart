// presentation/bloc/games_list_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/bowling_game_entity.dart';

abstract class GamesListState extends Equatable {
  @override
  List<Object> get props => [];
}

class GamesListInitial extends GamesListState {}

class GamesListLoading extends GamesListState {}

class GamesListLoaded extends GamesListState {
  final List<BowlingGameEntity> games;

  GamesListLoaded(this.games);

  @override
  List<Object> get props => [games];
}

class GamesListError extends GamesListState {
  final String message;

  GamesListError(this.message);

  @override
  List<Object> get props => [message];
}

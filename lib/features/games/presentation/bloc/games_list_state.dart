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
  final bool isSyncing;
  final String? syncError;

  GamesListLoaded(this.games, {this.isSyncing = false, this.syncError});

  GamesListLoaded copyWith({
    List<BowlingGameEntity>? games,
    bool? isSyncing,
    String? syncError,
  }) {
    return GamesListLoaded(
      games ?? this.games,
      isSyncing: isSyncing ?? this.isSyncing,
      syncError: syncError ?? this.syncError,
    );
  }

  @override
  List<Object> get props => [games, isSyncing, syncError ?? ''];
}

class GamesListError extends GamesListState {
  final String message;

  GamesListError(this.message);

  @override
  List<Object> get props => [message];
}

// presentation/bloc/games_list_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/game_sync_manager.dart';
import '../../domain/repositories/game_repository.dart';
import 'games_list_event.dart';
import 'games_list_state.dart';

@injectable
class GamesListBloc extends Bloc<GamesListEvent, GamesListState> {
  final GameRepository _gameRepository;
  final GameSyncManager _syncManager;

  GamesListBloc(this._gameRepository, this._syncManager)
    : super(GamesListInitial()) {
    on<LoadGames>(_onLoadGames);
    on<DeleteGame>(_onDeleteGame);
    on<SyncGames>(_onSyncGames);
  }

  Future<void> _onLoadGames(
    LoadGames event,
    Emitter<GamesListState> emit,
  ) async {
    emit(GamesListLoading());

    final result = await _gameRepository.getAllGames();

    result.fold(
      (failure) => emit(GamesListError(_getFailureMessage(failure))),
      (games) => emit(GamesListLoaded(games)),
    );
  }

  Future<void> _onDeleteGame(
    DeleteGame event,
    Emitter<GamesListState> emit,
  ) async {
    if (state is GamesListLoaded) {
      final currentGames = (state as GamesListLoaded).games;

      final result = await _gameRepository.deleteGame(event.gameId);

      result.fold(
        (failure) => emit(GamesListError(_getFailureMessage(failure))),
        (_) {
          final updatedGames = currentGames
              .where((game) => game.id != event.gameId)
              .toList();
          emit(GamesListLoaded(updatedGames));
        },
      );
    }
  }

  Future<void> _onSyncGames(
    SyncGames event,
    Emitter<GamesListState> emit,
  ) async {
    if (state is GamesListLoaded) {
      final currentState = state as GamesListLoaded;
      emit(currentState.copyWith(isSyncing: true));
      await _syncManager.syncPendingGames();

      // Reload games after sync
      final result = await _gameRepository.getAllGames();
      result.fold(
        (failure) => emit(currentState.copyWith(isSyncing: false)),
        (games) => emit(
          GamesListLoaded(
            games,
            isSyncing: false,
            syncError: _syncManager.lastSyncError,
          ),
        ),
      );
    }
  }

  String _getFailureMessage(failure) {
    if (failure is CacheFailure) {
      return failure.message;
    } else if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    } else {
      return 'An unexpected error occurred';
    }
  }

  @override
  Future<void> close() {
    _syncManager.removeListener(() {});
    return super.close();
  }
}

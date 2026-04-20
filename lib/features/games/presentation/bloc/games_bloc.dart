import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/user_game_stats.dart';
import '../../domain/repositories/games_repository.dart';

part 'games_event.dart';
part 'games_state.dart';

/// Drives the Games tab: aggregated stats + recent sessions list.
///
/// Both are fetched in parallel on [GamesLoadRequested] (matches the web
/// pattern). Either failing alone keeps the other rendered — we only surface
/// an error when both fail.
@injectable
class GamesBloc extends Bloc<GamesEvent, GamesState> {
  GamesBloc(this._repository) : super(const GamesState()) {
    on<GamesLoadRequested>(_onLoad);
    on<GamesRefreshRequested>(_onRefresh);
  }

  final GamesRepository _repository;

  Future<void> _onLoad(
    GamesLoadRequested event,
    Emitter<GamesState> emit,
  ) async {
    if (state.sessions.isNotEmpty && !event.force) return;
    emit(state.copyWith(loading: true, errors: const []));
    await _fetch(emit, refreshing: false);
  }

  Future<void> _onRefresh(
    GamesRefreshRequested event,
    Emitter<GamesState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    await _fetch(emit, refreshing: true);
  }

  Future<void> _fetch(Emitter<GamesState> emit, {required bool refreshing}) async {
    final results = await Future.wait<dynamic>([
      _repository.getStats(),
      _repository.getSessions(),
    ], eagerError: false);

    final statsResult = results[0] as Either<Failure, UserGameStats>;
    final sessionsResult = results[1] as Either<Failure, List<Session>>;

    final stats = statsResult.fold<UserGameStats?>(
      (_) => null,
      (s) => s.hasRecord ? s : null,
    );
    final sessions = sessionsResult.fold<List<Session>?>(
      (_) => null,
      (s) => s,
    );

    if (sessions == null && stats == null) {
      emit(state.copyWith(
        loading: false,
        refreshing: false,
        errors: sessionsResult.fold((f) => f.messages, (_) => const []),
      ));
      return;
    }

    emit(state.copyWith(
      loading: false,
      refreshing: false,
      stats: stats,
      sessions: sessions ?? state.sessions,
      errors: const [],
    ));
  }
}

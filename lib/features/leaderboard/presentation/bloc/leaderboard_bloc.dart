import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/leaderboard.dart';
import '../../domain/repositories/leaderboard_repository.dart';

part 'leaderboard_event.dart';
part 'leaderboard_state.dart';

/// Tab key that includes the presentation-only "Ranks" tab. The 3
/// real scopes route through `LeaderboardBoardType`; "ranks" loads
/// `/api/xp/ranks` instead.
enum LeaderboardTab { weekly, monthly, global, ranks }

@injectable
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc(this._repository) : super(const LeaderboardState()) {
    on<LeaderboardTabChanged>(_onTabChanged);
    on<LeaderboardRefreshRequested>(_onRefresh);
    on<LeaderboardNextPageRequested>(_onNextPage);
    on<LeaderboardRanksLoadRequested>(_onLoadRanks);
  }

  final LeaderboardRepository _repository;

  Future<void> _onTabChanged(
    LeaderboardTabChanged event,
    Emitter<LeaderboardState> emit,
  ) async {
    if (event.tab == state.tab && state.entries.isNotEmpty) return;
    emit(state.copyWith(
      tab: event.tab,
      entries: const [],
      page: 1,
      hasMore: false,
      errors: const [],
    ));
    if (event.tab == LeaderboardTab.ranks) {
      // Ranks-tab pulls from a different endpoint; only fetch once.
      if (state.ranks.isEmpty) {
        await _fetchRanks(emit);
      }
      return;
    }
    await _fetchPage(emit, page: 1, replace: true);
  }

  Future<void> _onRefresh(
    LeaderboardRefreshRequested event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    if (state.tab == LeaderboardTab.ranks) {
      await _fetchRanks(emit);
    } else {
      await _fetchPage(emit, page: 1, replace: true);
    }
    emit(state.copyWith(refreshing: false));
  }

  Future<void> _onNextPage(
    LeaderboardNextPageRequested event,
    Emitter<LeaderboardState> emit,
  ) async {
    if (state.tab == LeaderboardTab.ranks) return;
    if (!state.hasMore || state.loadingMore) return;
    emit(state.copyWith(loadingMore: true));
    await _fetchPage(emit, page: state.page + 1, replace: false);
    emit(state.copyWith(loadingMore: false));
  }

  Future<void> _onLoadRanks(
    LeaderboardRanksLoadRequested event,
    Emitter<LeaderboardState> emit,
  ) async {
    if (state.ranks.isNotEmpty) return;
    await _fetchRanks(emit);
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  LeaderboardBoardType _boardFor(LeaderboardTab tab) => switch (tab) {
        LeaderboardTab.weekly => LeaderboardBoardType.weekly,
        LeaderboardTab.monthly => LeaderboardBoardType.monthly,
        LeaderboardTab.global => LeaderboardBoardType.global,
        LeaderboardTab.ranks => LeaderboardBoardType.weekly, // unused
      };

  Future<void> _fetchPage(
    Emitter<LeaderboardState> emit, {
    required int page,
    required bool replace,
  }) async {
    if (replace) emit(state.copyWith(loading: true, errors: const []));
    final res = await _repository.getLeaderboard(
      boardType: _boardFor(state.tab),
      page: page,
    );
    res.fold(
      (f) => emit(state.copyWith(
        loading: false,
        loadingMore: false,
        errors: f.messages,
      )),
      (data) => emit(state.copyWith(
        loading: false,
        loadingMore: false,
        entries: replace ? data.entries : [...state.entries, ...data.entries],
        myPosition: data.myPosition,
        totalEntries: data.totalEntries,
        hasMore: data.hasNext,
        page: page,
        errors: const [],
      )),
    );
  }

  Future<void> _fetchRanks(Emitter<LeaderboardState> emit) async {
    emit(state.copyWith(ranksLoading: true, errors: const []));
    final res = await _repository.getRanks();
    res.fold(
      (f) => emit(state.copyWith(
        ranksLoading: false,
        errors: f.messages,
      )),
      (list) => emit(state.copyWith(ranksLoading: false, ranks: list)),
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/stats_detail.dart';
import '../../domain/entities/user_game_stats.dart';
import '../../domain/repositories/games_repository.dart';

part 'stats_event.dart';
part 'stats_state.dart';

/// Drives the analytics dashboard. Fetches the core stats card + pin
/// leaves + spare conversion + trends + center/context breakdowns in
/// parallel. Trend range is reactive (re-fetches trends only).
@injectable
class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc(this._repository) : super(const StatsState()) {
    on<StatsLoadRequested>(_onLoad);
    on<StatsRefreshRequested>(_onRefresh);
    on<StatsTrendRangeChanged>(_onTrendRangeChanged);
  }

  final GamesRepository _repository;

  Future<void> _onLoad(
    StatsLoadRequested event,
    Emitter<StatsState> emit,
  ) async {
    if (state.stats != null) return;
    emit(state.copyWith(loading: true, errors: const []));
    await _fetchAll(emit);
  }

  Future<void> _onRefresh(
    StatsRefreshRequested event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    await _fetchAll(emit);
  }

  Future<void> _onTrendRangeChanged(
    StatsTrendRangeChanged event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(trendRangeDays: event.days));
    final res = await _repository.getTrendStats(rangeDays: event.days);
    res.fold(
      (_) {/* keep old trends on failure */},
      (list) => emit(state.copyWith(trends: list)),
    );
  }

  Future<void> _fetchAll(Emitter<StatsState> emit) async {
    final results = await Future.wait([
      _repository.getStats(),
      _repository.getPinLeaveStats(),
      _repository.getSpareStats(),
      _repository.getTrendStats(rangeDays: state.trendRangeDays),
      _repository.getStatsByCenter(),
      _repository.getStatsByContext(),
    ]);
    final stats = (results[0] as dynamic).fold<UserGameStats?>(
      (_) => state.stats,
      (s) => (s as UserGameStats).hasRecord ? s : null,
    );
    final pinLeaves = (results[1] as dynamic).fold<List<PinLeaveStat>>(
      (_) => const [],
      (l) => l as List<PinLeaveStat>,
    );
    final spares = (results[2] as dynamic).fold<List<SpareCategoryStat>>(
      (_) => const [],
      (l) => l as List<SpareCategoryStat>,
    );
    final trends = (results[3] as dynamic).fold<List<TrendPoint>>(
      (_) => const [],
      (l) => l as List<TrendPoint>,
    );
    final byCenter = (results[4] as dynamic).fold<List<CenterPerformance>>(
      (_) => const [],
      (l) => l as List<CenterPerformance>,
    );
    final byContext = (results[5] as dynamic).fold<List<ContextPerformance>>(
      (_) => const [],
      (l) => l as List<ContextPerformance>,
    );

    emit(state.copyWith(
      loading: false,
      refreshing: false,
      stats: stats,
      pinLeaves: pinLeaves,
      spares: spares,
      trends: trends,
      byCenter: byCenter,
      byContext: byContext,
      errors: const [],
    ));
  }
}

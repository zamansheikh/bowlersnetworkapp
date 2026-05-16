import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
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
    // Fan-out fetches in parallel. Each result keeps its own Either<L, R>
    // type — earlier versions used `Future.wait([...])` then `as dynamic`,
    // which compiled but blew up at runtime because the closure types in
    // `.fold(...)` couldn't be enforced through `dynamic` dispatch.
    final futures = await Future.wait<dynamic>([
      _repository.getStats(),
      _repository.getPinLeaveStats(),
      _repository.getSpareStats(),
      _repository.getTrendStats(rangeDays: state.trendRangeDays),
      _repository.getStatsByCenter(),
      _repository.getStatsByContext(),
    ]);

    final statsRes = futures[0] as Either<Failure, UserGameStats>;
    final pinLeavesRes = futures[1] as Either<Failure, List<PinLeaveStat>>;
    final sparesRes = futures[2] as Either<Failure, List<SpareCategoryStat>>;
    final trendsRes = futures[3] as Either<Failure, List<TrendPoint>>;
    final byCenterRes = futures[4] as Either<Failure, List<CenterPerformance>>;
    final byContextRes =
        futures[5] as Either<Failure, List<ContextPerformance>>;

    final stats = statsRes.fold<UserGameStats?>(
      (_) => state.stats,
      (s) => s.hasRecord ? s : null,
    );
    final pinLeaves = pinLeavesRes.fold<List<PinLeaveStat>>(
      (_) => const <PinLeaveStat>[],
      (l) => l,
    );
    final spares = sparesRes.fold<List<SpareCategoryStat>>(
      (_) => const <SpareCategoryStat>[],
      (l) => l,
    );
    final trends = trendsRes.fold<List<TrendPoint>>(
      (_) => const <TrendPoint>[],
      (l) => l,
    );
    final byCenter = byCenterRes.fold<List<CenterPerformance>>(
      (_) => const <CenterPerformance>[],
      (l) => l,
    );
    final byContext = byContextRes.fold<List<ContextPerformance>>(
      (_) => const <ContextPerformance>[],
      (l) => l,
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

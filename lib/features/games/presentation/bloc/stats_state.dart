part of 'stats_bloc.dart';

class StatsState extends Equatable {
  const StatsState({
    this.stats,
    this.pinLeaves = const [],
    this.spares = const [],
    this.trends = const [],
    this.byCenter = const [],
    this.byContext = const [],
    this.trendRangeDays = 30,
    this.loading = false,
    this.refreshing = false,
    this.errors = const [],
  });

  final UserGameStats? stats;
  final List<PinLeaveStat> pinLeaves;
  final List<SpareCategoryStat> spares;
  final List<TrendPoint> trends;
  final List<CenterPerformance> byCenter;
  final List<ContextPerformance> byContext;
  final int trendRangeDays;
  final bool loading;
  final bool refreshing;
  final List<String> errors;

  StatsState copyWith({
    UserGameStats? stats,
    List<PinLeaveStat>? pinLeaves,
    List<SpareCategoryStat>? spares,
    List<TrendPoint>? trends,
    List<CenterPerformance>? byCenter,
    List<ContextPerformance>? byContext,
    int? trendRangeDays,
    bool? loading,
    bool? refreshing,
    List<String>? errors,
  }) {
    return StatsState(
      stats: stats ?? this.stats,
      pinLeaves: pinLeaves ?? this.pinLeaves,
      spares: spares ?? this.spares,
      trends: trends ?? this.trends,
      byCenter: byCenter ?? this.byCenter,
      byContext: byContext ?? this.byContext,
      trendRangeDays: trendRangeDays ?? this.trendRangeDays,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        stats,
        pinLeaves,
        spares,
        trends,
        byCenter,
        byContext,
        trendRangeDays,
        loading,
        refreshing,
        errors,
      ];
}

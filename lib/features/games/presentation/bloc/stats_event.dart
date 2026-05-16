part of 'stats_bloc.dart';

sealed class StatsEvent extends Equatable {
  const StatsEvent();
  @override
  List<Object?> get props => const [];
}

class StatsLoadRequested extends StatsEvent {
  const StatsLoadRequested();
}

class StatsRefreshRequested extends StatsEvent {
  const StatsRefreshRequested();
}

/// User changed the rolling-window for the trends chart (7/30/90 days).
class StatsTrendRangeChanged extends StatsEvent {
  const StatsTrendRangeChanged(this.days);
  final int days;
  @override
  List<Object?> get props => [days];
}

part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => const [];
}

/// Fired once when the screen mounts. Tells the bloc whether the
/// viewer is a pro user (so it knows whether to hide pro tabs + skip
/// pro endpoint calls that would 403).
class DashboardInitRequested extends DashboardEvent {
  const DashboardInitRequested({required this.isPro});
  final bool isPro;
  @override
  List<Object?> get props => [isPro];
}

class DashboardTabChanged extends DashboardEvent {
  const DashboardTabChanged(this.tab);
  final DashboardTab tab;
  @override
  List<Object?> get props => [tab];
}

class DashboardRangeChanged extends DashboardEvent {
  const DashboardRangeChanged(this.range);
  final DashboardRange range;
  @override
  List<Object?> get props => [range];
}

class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}

/// Per-tab load triggers. Batches 2 + 3 add `DashboardXpLoadRequested`,
/// `DashboardGamesLoadRequested`, `DashboardProContentLoadRequested`,
/// etc. — they share the same `force` knob so a tab-change can
/// re-fetch without going through Refresh.

class DashboardEngagementLoadRequested extends DashboardEvent {
  const DashboardEngagementLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class DashboardXpLoadRequested extends DashboardEvent {
  const DashboardXpLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class DashboardGamesLoadRequested extends DashboardEvent {
  const DashboardGamesLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

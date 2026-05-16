part of 'leaderboard_bloc.dart';

sealed class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();
  @override
  List<Object?> get props => const [];
}

class LeaderboardTabChanged extends LeaderboardEvent {
  const LeaderboardTabChanged(this.tab);
  final LeaderboardTab tab;
  @override
  List<Object?> get props => [tab];
}

class LeaderboardRefreshRequested extends LeaderboardEvent {
  const LeaderboardRefreshRequested();
}

class LeaderboardNextPageRequested extends LeaderboardEvent {
  const LeaderboardNextPageRequested();
}

class LeaderboardRanksLoadRequested extends LeaderboardEvent {
  const LeaderboardRanksLoadRequested();
}

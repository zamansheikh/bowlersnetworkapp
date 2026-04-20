part of 'games_bloc.dart';

class GamesState extends Equatable {
  const GamesState({
    this.loading = false,
    this.refreshing = false,
    this.stats,
    this.sessions = const [],
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;
  final UserGameStats? stats;
  final List<Session> sessions;
  final List<String> errors;

  GamesState copyWith({
    bool? loading,
    bool? refreshing,
    UserGameStats? stats,
    List<Session>? sessions,
    List<String>? errors,
    bool clearStats = false,
  }) {
    return GamesState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      stats: clearStats ? null : (stats ?? this.stats),
      sessions: sessions ?? this.sessions,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props =>
      [loading, refreshing, stats, sessions, errors];
}

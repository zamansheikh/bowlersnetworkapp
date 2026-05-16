part of 'equipment_bloc.dart';

class EquipmentState extends Equatable {
  const EquipmentState({
    this.balls = const [],
    this.stats = const {},
    this.loading = false,
    this.refreshing = false,
    this.errors = const [],
  });

  final List<UserBall> balls;
  final Map<int, BallStats> stats;
  final bool loading;
  final bool refreshing;
  final List<String> errors;

  EquipmentState copyWith({
    List<UserBall>? balls,
    Map<int, BallStats>? stats,
    bool? loading,
    bool? refreshing,
    List<String>? errors,
  }) {
    return EquipmentState(
      balls: balls ?? this.balls,
      stats: stats ?? this.stats,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [balls, stats, loading, refreshing, errors];
}

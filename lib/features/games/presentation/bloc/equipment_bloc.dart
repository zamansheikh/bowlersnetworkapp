import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/equipment.dart';
import '../../domain/repositories/games_repository.dart';

part 'equipment_event.dart';
part 'equipment_state.dart';

/// Drives the equipment / loadout screen. Loads balls + per-ball stats in
/// parallel; handles add (after picker modal) and delete with optimistic
/// removal + rollback on failure.
@injectable
class EquipmentBloc extends Bloc<EquipmentEvent, EquipmentState> {
  EquipmentBloc(this._repository) : super(const EquipmentState()) {
    on<EquipmentLoadRequested>(_onLoad);
    on<EquipmentRefreshRequested>(_onRefresh);
    on<EquipmentAdded>(_onAdded);
    on<EquipmentDeleteRequested>(_onDelete);
  }

  final GamesRepository _repository;

  Future<void> _onLoad(
    EquipmentLoadRequested event,
    Emitter<EquipmentState> emit,
  ) async {
    if (state.balls.isNotEmpty) return;
    emit(state.copyWith(loading: true, errors: const []));
    await _fetch(emit);
  }

  Future<void> _onRefresh(
    EquipmentRefreshRequested event,
    Emitter<EquipmentState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    await _fetch(emit);
  }

  void _onAdded(EquipmentAdded event, Emitter<EquipmentState> emit) {
    // Newly-added ball comes back without stats — prepend it.
    emit(state.copyWith(balls: [event.ball, ...state.balls]));
  }

  Future<void> _onDelete(
    EquipmentDeleteRequested event,
    Emitter<EquipmentState> emit,
  ) async {
    final snapshot = state.balls;
    emit(state.copyWith(
      balls: snapshot.where((b) => b.id != event.userBallId).toList(
            growable: false,
          ),
    ));
    final res = await _repository.deleteEquipment(event.userBallId);
    res.fold(
      (f) => emit(state.copyWith(balls: snapshot, errors: f.messages)),
      (_) {},
    );
  }

  Future<void> _fetch(Emitter<EquipmentState> emit) async {
    // Parallel fetch with typed casts — `as dynamic` would compile but blow
    // up at runtime because closure types can't flow through dynamic.
    final futures = await Future.wait<dynamic>([
      _repository.getEquipment(),
      _repository.getEquipmentStats(),
    ]);
    final ballsRes = futures[0] as Either<Failure, List<UserBall>>;
    final statsRes = futures[1] as Either<Failure, List<BallStats>>;

    final balls = ballsRes.fold<List<UserBall>>(
      (_) => state.balls,
      (list) => list,
    );
    final statsList = statsRes.fold<List<BallStats>>(
      (_) => const <BallStats>[],
      (list) => list,
    );
    final statsByBall = <int, BallStats>{
      for (final s in statsList) s.userBallId: s,
    };

    emit(state.copyWith(
      loading: false,
      refreshing: false,
      balls: balls,
      stats: statsByBall,
      errors: const [],
    ));
  }
}

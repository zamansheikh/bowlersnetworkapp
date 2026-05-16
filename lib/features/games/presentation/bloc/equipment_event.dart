part of 'equipment_bloc.dart';

sealed class EquipmentEvent extends Equatable {
  const EquipmentEvent();
  @override
  List<Object?> get props => const [];
}

class EquipmentLoadRequested extends EquipmentEvent {
  const EquipmentLoadRequested();
}

class EquipmentRefreshRequested extends EquipmentEvent {
  const EquipmentRefreshRequested();
}

/// Fired by the picker modal after a successful add — bloc just prepends.
class EquipmentAdded extends EquipmentEvent {
  const EquipmentAdded(this.ball);
  final UserBall ball;
  @override
  List<Object?> get props => [ball];
}

class EquipmentDeleteRequested extends EquipmentEvent {
  const EquipmentDeleteRequested(this.userBallId);
  final int userBallId;
  @override
  List<Object?> get props => [userBallId];
}

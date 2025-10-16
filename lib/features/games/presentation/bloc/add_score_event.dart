// presentation/bloc/add_score_event.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/bowling_game_entity.dart';
import '../../domain/entities/game_type.dart';
import '../../domain/entities/lane_condition.dart';
import '../../domain/entities/oil_pattern.dart';

abstract class AddScoreEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartNewGame extends AddScoreEvent {
  final OilPattern? oilPattern;
  final LaneCondition? laneCondition;
  final GameType? gameType;
  final String? laneNumber;

  StartNewGame({
    this.oilPattern,
    this.laneCondition,
    this.gameType,
    this.laneNumber,
  });

  @override
  List<Object?> get props => [oilPattern, laneCondition, gameType, laneNumber];
}

class LoadExistingGame extends AddScoreEvent {
  final BowlingGameEntity game;

  LoadExistingGame(this.game);

  @override
  List<Object> get props => [game];
}

class SelectPin extends AddScoreEvent {
  final int pin;

  SelectPin(this.pin);

  @override
  List<Object> get props => [pin];
}

class ToggleFoul extends AddScoreEvent {} // Not used, but if needed

class PressShortcut extends AddScoreEvent {
  final ShortcutType type;

  PressShortcut(this.type);

  @override
  List<Object> get props => [type];
}

enum ShortcutType { foul, miss, strikeOrSpare }

class ConfirmThrow extends AddScoreEvent {}

class PreviousThrow extends AddScoreEvent {}

class NextThrow extends AddScoreEvent {}

class SaveGame extends AddScoreEvent {}

class DismissCompletionDialog extends AddScoreEvent {}

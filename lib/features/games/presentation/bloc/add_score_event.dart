// presentation/bloc/add_score_event.dart

import 'package:equatable/equatable.dart';

abstract class AddScoreEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class StartNewGame extends AddScoreEvent {}

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

class SaveGame extends AddScoreEvent {}
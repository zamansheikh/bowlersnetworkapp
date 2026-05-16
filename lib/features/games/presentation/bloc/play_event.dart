part of 'play_bloc.dart';

sealed class PlayEvent extends Equatable {
  const PlayEvent();
  @override
  List<Object?> get props => const [];
}

class PlayPinToggled extends PlayEvent {
  const PlayPinToggled(this.pin);
  final int pin;
  @override
  List<Object?> get props => [pin];
}

enum PlayQuickActionType { strike, spare, miss, clear }

/// "Strike all" / "Spare clear" / "Miss" / "Clear current input".
class PlayQuickAction extends PlayEvent {
  const PlayQuickAction(this.action);
  final PlayQuickActionType action;
  @override
  List<Object?> get props => [action];
}

class PlayFrameJumped extends PlayEvent {
  const PlayFrameJumped(this.frameIndex);
  final int frameIndex;
  @override
  List<Object?> get props => [frameIndex];
}

class PlayDeliveryUndone extends PlayEvent {
  const PlayDeliveryUndone();
}

class PlayHandednessChanged extends PlayEvent {
  const PlayHandednessChanged(this.handedness);
  final String handedness;
  @override
  List<Object?> get props => [handedness];
}

class PlayGameSubmitted extends PlayEvent {
  const PlayGameSubmitted();
}

class PlayGameReset extends PlayEvent {
  const PlayGameReset();
}

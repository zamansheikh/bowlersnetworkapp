part of 'play_bloc.dart';

sealed class PlayEvent extends Equatable {
  const PlayEvent();
  @override
  List<Object?> get props => const [];
}

/// Single-pin tap (used by the legacy tap-only flow). The new
/// drag-aware PinDeck uses [PlayStandingChanged] to push the whole set.
class PlayPinToggled extends PlayEvent {
  const PlayPinToggled(this.pin);
  final int pin;
  @override
  List<Object?> get props => [pin];
}

/// Drag-aware setter: the deck hands us the new standing-pins set after
/// each pointer move. We re-derive the active delivery's pinsStanding
/// from it. Does NOT advance the cursor — user taps "Next" or a quick
/// action to commit.
class PlayStandingChanged extends PlayEvent {
  const PlayStandingChanged(this.standing);
  final List<int> standing;
  @override
  List<Object?> get props => [standing];
}

enum PlayQuickActionType { strike, spare, miss, clear, next }

/// "Strike" / "Spare" / "Miss" / "Clear current input" / "Next" (commit).
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

/// Flip the pin-default-state preference: when 'standing', the active
/// delivery starts with all pins UP and the user taps the ones they
/// knocked down. When 'knocked', it starts with all available pins DOWN
/// and the user un-taps the survivors.
class PlayPinDefaultToggled extends PlayEvent {
  const PlayPinDefaultToggled();
}

/// The user picked a different ball in the loadout sheet. `null` means
/// "Don't link this delivery to any equipment".
class PlaySelectedBallChanged extends PlayEvent {
  const PlaySelectedBallChanged(this.userBallId);
  final int? userBallId;
  @override
  List<Object?> get props => [userBallId];
}

class PlayGameSubmitted extends PlayEvent {
  const PlayGameSubmitted();
}

class PlayGameReset extends PlayEvent {
  const PlayGameReset();
}

/// Flip between full frame-by-frame entry and quick total-score entry.
class PlayEntryModeChanged extends PlayEvent {
  const PlayEntryModeChanged(this.mode);
  final PlayEntryMode mode;
  @override
  List<Object?> get props => [mode];
}

/// Submit a quick-score game (single total, 0–300). Backend creates the
/// game record without per-frame detail.
class PlayQuickScoreSubmitted extends PlayEvent {
  const PlayQuickScoreSubmitted(this.totalScore);
  final int totalScore;
  @override
  List<Object?> get props => [totalScore];
}

/// User updated the quick-score draft (the text-field value). Stored in
/// state so the field is bloc-driven and survives mode toggles.
class PlayQuickScoreDraftChanged extends PlayEvent {
  const PlayQuickScoreDraftChanged(this.value);
  final String value;
  @override
  List<Object?> get props => [value];
}

/// "Another Game" on the celebration screen — reset frames + score +
/// cursor, bump gameNumber, keep handedness / pin-default / selected
/// ball.
class PlayAnotherGameRequested extends PlayEvent {
  const PlayAnotherGameRequested();
}

/// Start broadcasting the current session — POSTs /api/games/lives/start.
/// On success, [PlayState.live] is set and every subsequent committed
/// frame fires a per-frame PUT to keep viewers in sync.
class PlayGoLiveRequested extends PlayEvent {
  const PlayGoLiveRequested();
}

/// End the active broadcast. POSTs /api/games/lives/{id}/end and clears
/// [PlayState.live] regardless of the response (best-effort).
class PlayEndLiveRequested extends PlayEvent {
  const PlayEndLiveRequested();
}

/// Fire-on-mount: GET /api/games/lives/me/active and adopt the broadcast
/// if it exists. Handles the case where the user reopens the app
/// mid-broadcast.
class PlayLiveRehydrateRequested extends PlayEvent {
  const PlayLiveRehydrateRequested();
}

/// Fire-on-mount: read any saved local play state for this session out of
/// SharedPreferences and adopt it. Lets the user resume a force-closed
/// in-progress game.
class PlayLocalStateRehydrateRequested extends PlayEvent {
  const PlayLocalStateRehydrateRequested();
}

/// Internal — funnels [LiveSocket] inbound events through the bloc's
/// event pipeline so all state writes stay single-threaded.
class _PlayLiveSocketEvent extends PlayEvent {
  const _PlayLiveSocketEvent(this.event);
  final LiveSocketEvent event;
  @override
  List<Object?> get props => [event];
}

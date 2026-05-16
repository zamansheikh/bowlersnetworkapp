part of 'play_bloc.dart';

class PlayCursor extends Equatable {
  const PlayCursor({required this.frameIndex, required this.deliveryIndex});

  const PlayCursor.gameOver()
      : frameIndex = 10,
        deliveryIndex = 0;

  final int frameIndex;
  final int deliveryIndex;

  bool get isGameOver => frameIndex >= 10;

  @override
  List<Object?> get props => [frameIndex, deliveryIndex];
}

/// User preference for the pin-deck starting state on a fresh delivery:
///   • [standing] — all pins UP, user taps the ones they knocked down.
///   • [knocked]  — all available pins DOWN (visualised as fallen), user
///     un-taps the survivors that are still standing after their throw.
enum PinDefaultState { standing, knocked }

/// Top-level entry mode — frame-by-frame ([full]) or just-the-total
/// ([quick]). Matches web's `entryMode` state.
enum PlayEntryMode { full, quick }

class PlayState extends Equatable {
  const PlayState({
    required this.frames,
    required this.cursor,
    required this.score,
    this.handedness = 'Righty',
    this.submitting = false,
    this.submittedGame,
    this.errors = const [],
    this.pinDefault = PinDefaultState.standing,
    this.selectedBallId,
    this.entryMode = PlayEntryMode.full,
    this.gameNumber = 1,
    this.quickScoreDraft = '',
    this.live,
    this.liveBusy = false,
  });

  factory PlayState.initial() {
    final frames = List<FrameInput>.generate(
      10,
      (_) => const FrameInput(),
      growable: false,
    );
    return PlayState(
      frames: frames,
      cursor: const PlayCursor(frameIndex: 0, deliveryIndex: 0),
      score: computeGame(frames),
    );
  }

  final List<FrameInput> frames;
  final PlayCursor cursor;
  final GameScoreResult score;
  final String handedness;
  final bool submitting;
  final GameDetail? submittedGame;
  final List<String> errors;
  final PinDefaultState pinDefault;

  /// User-ball id selected in the loadout picker. Threaded into each
  /// delivery's payload as `ball_N_equipment_id` on submit.
  final int? selectedBallId;

  /// Frame-by-frame vs total-score-only mode.
  final PlayEntryMode entryMode;

  /// Counter incremented after each submitted game (so the celebration
  /// screen can show "Game N" and "Another Game" can label the next one).
  final int gameNumber;

  /// Current value of the quick-score text field. Lives on state so it
  /// survives mode toggles and rebuilds.
  final String quickScoreDraft;

  /// Active broadcast, if any. When non-null the screen shows the live
  /// pill and every committed frame fires a per-frame PUT.
  final LiveBroadcast? live;

  /// True while a start/end RPC is in flight — disables the Go-Live /
  /// End button to prevent double-taps.
  final bool liveBusy;

  bool get isLive => live != null;

  int get currentFrameNumber => cursor.isGameOver ? 10 : cursor.frameIndex + 1;
  int get currentDeliveryNumber => cursor.deliveryIndex + 1;
  bool get isGameOver => cursor.isGameOver;

  /// What pins are still standing right now (i.e., active-delivery view).
  /// Honors [pinDefault]: when 'knocked' and the user hasn't started this
  /// delivery yet, the answer is "none" (everything starts down).
  List<int> get activeStanding {
    if (cursor.isGameOver) return const [];
    final frame = frames[cursor.frameIndex];

    // A delivery committed/in-progress at the cursor — use the stored value.
    if (cursor.deliveryIndex < frame.deliveries.length) {
      return frame.deliveries[cursor.deliveryIndex].pinsStanding;
    }

    // Cursor sits on a not-yet-thrown delivery. Decide the starting set.
    final rack = _rackForCursor(frame, cursor);
    return pinDefault == PinDefaultState.knocked ? const [] : rack;
  }

  /// Pins available to be toggled this delivery — i.e. the rack just
  /// before the throw. Used by the deck to fade out pins that aren't
  /// part of this delivery (e.g. ones the user already knocked on ball 1).
  List<int> get availablePins {
    if (cursor.isGameOver) return const [];
    final frame = frames[cursor.frameIndex];
    return _rackForCursor(frame, cursor);
  }

  static List<int> _rackForCursor(FrameInput frame, PlayCursor cursor) {
    if (cursor.deliveryIndex == 0) return const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    final prev = frame.deliveries[cursor.deliveryIndex - 1].pinsStanding;
    final isTenth = cursor.frameIndex == 9;
    if (isTenth && prev.isEmpty) {
      // Strike or spare → rack reset for next delivery.
      return const [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    }
    return prev;
  }

  PlayState copyWith({
    List<FrameInput>? frames,
    PlayCursor? cursor,
    GameScoreResult? score,
    String? handedness,
    bool? submitting,
    GameDetail? submittedGame,
    bool clearSubmittedGame = false,
    List<String>? errors,
    PinDefaultState? pinDefault,
    int? selectedBallId,
    bool clearSelectedBall = false,
    PlayEntryMode? entryMode,
    int? gameNumber,
    String? quickScoreDraft,
    LiveBroadcast? live,
    bool clearLive = false,
    bool? liveBusy,
  }) {
    return PlayState(
      frames: frames ?? this.frames,
      cursor: cursor ?? this.cursor,
      score: score ?? this.score,
      handedness: handedness ?? this.handedness,
      submitting: submitting ?? this.submitting,
      submittedGame: clearSubmittedGame
          ? null
          : (submittedGame ?? this.submittedGame),
      errors: errors ?? this.errors,
      pinDefault: pinDefault ?? this.pinDefault,
      selectedBallId:
          clearSelectedBall ? null : (selectedBallId ?? this.selectedBallId),
      entryMode: entryMode ?? this.entryMode,
      gameNumber: gameNumber ?? this.gameNumber,
      quickScoreDraft: quickScoreDraft ?? this.quickScoreDraft,
      live: clearLive ? null : (live ?? this.live),
      liveBusy: liveBusy ?? this.liveBusy,
    );
  }

  /// "Another Game" reset — wipes frames + cursor + submitted-game
  /// notification, bumps [gameNumber], but preserves prefs the user
  /// chose (handedness, pin default, selected ball, entry mode) AND the
  /// live broadcast if one is active (mirrors web: viewers keep watching
  /// the next game in the same broadcast).
  PlayState resetForNextGame() {
    final fresh = List<FrameInput>.generate(
      10,
      (_) => const FrameInput(),
      growable: false,
    );
    return PlayState(
      frames: fresh,
      cursor: const PlayCursor(frameIndex: 0, deliveryIndex: 0),
      score: computeGame(fresh),
      handedness: handedness,
      pinDefault: pinDefault,
      selectedBallId: selectedBallId,
      entryMode: entryMode,
      gameNumber: gameNumber + 1,
      live: live,
    );
  }

  @override
  List<Object?> get props => [
        frames,
        cursor,
        score,
        handedness,
        submitting,
        submittedGame,
        errors,
        pinDefault,
        selectedBallId,
        entryMode,
        gameNumber,
        quickScoreDraft,
        live,
        liveBusy,
      ];
}

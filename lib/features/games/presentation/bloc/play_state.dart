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

class PlayState extends Equatable {
  const PlayState({
    required this.frames,
    required this.cursor,
    required this.score,
    this.handedness = 'Righty',
    this.submitting = false,
    this.submittedGame,
    this.errors = const [],
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

  int get currentFrameNumber => cursor.isGameOver ? 10 : cursor.frameIndex + 1;
  int get currentDeliveryNumber => cursor.deliveryIndex + 1;
  bool get isGameOver => cursor.isGameOver;

  /// What pins are still standing right now (i.e., active-delivery view).
  List<int> get activeStanding {
    if (cursor.isGameOver) return const [];
    final frame = frames[cursor.frameIndex];
    if (cursor.deliveryIndex < frame.deliveries.length) {
      return frame.deliveries[cursor.deliveryIndex].pinsStanding;
    }
    // Cursor is on a not-yet-thrown delivery — start of rack.
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
    List<String>? errors,
  }) {
    return PlayState(
      frames: frames ?? this.frames,
      cursor: cursor ?? this.cursor,
      score: score ?? this.score,
      handedness: handedness ?? this.handedness,
      submitting: submitting ?? this.submitting,
      submittedGame: submittedGame ?? this.submittedGame,
      errors: errors ?? this.errors,
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
      ];
}

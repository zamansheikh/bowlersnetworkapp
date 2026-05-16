import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/game_detail.dart';
import '../../domain/repositories/games_repository.dart';
import '../../domain/scorer/bowling_scorer.dart';

part 'play_event.dart';
part 'play_state.dart';

/// Drives the play screen for one session. Holds 10 frame inputs, cursor
/// (which frame/delivery the user is on), and a live scoring snapshot.
///
/// NOT a singleton — spun up by the play screen's BlocProvider so each
/// game has its own state.
class PlayBloc extends Bloc<PlayEvent, PlayState> {
  PlayBloc({required GamesRepository repository, required String sessionUid})
      : _repository = repository,
        _sessionUid = sessionUid,
        super(PlayState.initial()) {
    on<PlayPinToggled>(_onPinToggled);
    on<PlayQuickAction>(_onQuickAction);
    on<PlayFrameJumped>(_onFrameJumped);
    on<PlayDeliveryUndone>(_onDeliveryUndone);
    on<PlayHandednessChanged>(_onHandednessChanged);
    on<PlayGameSubmitted>(_onSubmit);
    on<PlayGameReset>(_onReset);
  }

  final GamesRepository _repository;
  final String _sessionUid;

  // ── pin toggle ─────────────────────────────────────────────────────────────
  void _onPinToggled(PlayPinToggled event, Emitter<PlayState> emit) {
    if (state.cursor.isGameOver) return;
    final frame = state.frames[state.cursor.frameIndex];
    final activeDelivery = _currentDeliveryStanding(frame, state.cursor);
    final next = activeDelivery.contains(event.pin)
        ? [...activeDelivery.where((p) => p != event.pin)]
        : [...activeDelivery, event.pin]
      ..sort();
    emit(_withActiveStanding(state, next));
  }

  // ── quick actions: Strike / Spare / Miss / Clear ───────────────────────────
  void _onQuickAction(PlayQuickAction event, Emitter<PlayState> emit) {
    if (state.cursor.isGameOver) return;
    switch (event.action) {
      case PlayQuickActionType.strike:
        // Mark all pins down (empty standing) and commit.
        emit(_commitDelivery(state, const <int>[]));
      case PlayQuickActionType.spare:
        // Clear whatever's still up.
        emit(_commitDelivery(state, const <int>[]));
      case PlayQuickActionType.miss:
        // Keep whatever's standing — same set as before this delivery.
        final priorStanding = _priorStanding(state);
        emit(_commitDelivery(state, priorStanding));
      case PlayQuickActionType.clear:
        // Reset the in-progress active delivery to "all standing for the
        // rack" (i.e., nothing knocked yet on this throw).
        final priorStanding = _priorStanding(state);
        emit(_withActiveStanding(state, priorStanding));
    }
  }

  // ── jump to a specific frame (scorecard tap) ───────────────────────────────
  void _onFrameJumped(PlayFrameJumped event, Emitter<PlayState> emit) {
    if (event.frameIndex < 0 || event.frameIndex > 9) return;
    final f = state.frames[event.frameIndex];
    emit(state.copyWith(
      cursor: PlayCursor(
        frameIndex: event.frameIndex,
        deliveryIndex: f.deliveries.length,
      ),
    ));
  }

  // ── undo last delivery ─────────────────────────────────────────────────────
  void _onDeliveryUndone(PlayDeliveryUndone event, Emitter<PlayState> emit) {
    // Walk backwards from cursor until we find a frame with deliveries.
    var frameIdx = state.cursor.frameIndex;
    var deliveryIdx = state.cursor.deliveryIndex;

    // If cursor is mid-frame on delivery 0, go back to previous frame's last
    // delivery.
    if (deliveryIdx == 0) {
      if (frameIdx == 0) return;
      frameIdx -= 1;
      deliveryIdx = state.frames[frameIdx].deliveries.length;
    }

    if (deliveryIdx == 0) return;

    final frame = state.frames[frameIdx];
    final shortened = frame.deliveries.sublist(0, deliveryIdx - 1);
    final nextFrames = List<FrameInput>.from(state.frames);
    nextFrames[frameIdx] = frame.copyWith(deliveries: shortened);

    emit(state.copyWith(
      frames: nextFrames,
      cursor: PlayCursor(
        frameIndex: frameIdx,
        deliveryIndex: shortened.length,
      ),
    ));
  }

  void _onHandednessChanged(
    PlayHandednessChanged event,
    Emitter<PlayState> emit,
  ) {
    emit(state.copyWith(handedness: event.handedness));
  }

  // ── submit completed game ──────────────────────────────────────────────────
  Future<void> _onSubmit(
    PlayGameSubmitted event,
    Emitter<PlayState> emit,
  ) async {
    if (!state.score.isComplete) {
      emit(state.copyWith(errors: const ['Finish all 10 frames first.']));
      return;
    }
    emit(state.copyWith(submitting: true, errors: const []));

    final payload = _buildSubmitPayload(state.frames);
    final res = await _repository.submitGame(
      sessionUid: _sessionUid,
      frames: payload,
      handedness: state.handedness,
      totalScore: state.score.totalScore,
    );
    res.fold(
      (f) => emit(state.copyWith(submitting: false, errors: f.messages)),
      (game) => emit(state.copyWith(submitting: false, submittedGame: game)),
    );
  }

  void _onReset(PlayGameReset event, Emitter<PlayState> emit) {
    emit(PlayState.initial());
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  /// Active delivery's "pins still standing" list. If the user hasn't thrown
  /// yet, returns the rack as of the start of this delivery.
  List<int> _currentDeliveryStanding(FrameInput frame, PlayCursor cursor) {
    if (cursor.deliveryIndex < frame.deliveries.length) {
      return List<int>.from(frame.deliveries[cursor.deliveryIndex].pinsStanding);
    }
    return _rackForDelivery(frame, cursor.deliveryIndex);
  }

  List<int> _priorStanding(PlayState state) {
    final frame = state.frames[state.cursor.frameIndex];
    return _rackForDelivery(frame, state.cursor.deliveryIndex);
  }

  /// What pins are standing AT THE START of delivery [deliveryIndex] in this
  /// frame? On a fresh frame, that's all 10. After a non-strike delivery in
  /// frames 1-9, it's whatever was left. The 10th frame resets the rack
  /// after a strike or spare.
  List<int> _rackForDelivery(FrameInput frame, int deliveryIndex) {
    if (deliveryIndex == 0) return List<int>.from(allPins);

    // Walk backwards from previous delivery.
    final prev = frame.deliveries[deliveryIndex - 1].pinsStanding;
    final isTenth = state.cursor.frameIndex == 9;
    final clearedRack = prev.isEmpty;
    if (isTenth && clearedRack) {
      // Strike (delivery 0) or spare (delivery 1) → rack resets.
      return List<int>.from(allPins);
    }
    return List<int>.from(prev);
  }

  PlayState _withActiveStanding(PlayState state, List<int> standing) {
    final cursor = state.cursor;
    final frames = List<FrameInput>.from(state.frames);
    final frame = frames[cursor.frameIndex];
    final dels = List<Delivery>.from(frame.deliveries);

    if (cursor.deliveryIndex < dels.length) {
      dels[cursor.deliveryIndex] = Delivery(pinsStanding: standing);
    } else {
      dels.add(Delivery(pinsStanding: standing));
    }
    frames[cursor.frameIndex] = frame.copyWith(deliveries: dels);

    final newScore = computeGame(frames);
    return state.copyWith(frames: frames, score: newScore);
  }

  /// Commit the current delivery with [standing] and advance the cursor.
  PlayState _commitDelivery(PlayState state, List<int> standing) {
    final intermediate = _withActiveStanding(state, standing);
    final nextCursor = _advanceCursor(intermediate);
    return intermediate.copyWith(cursor: nextCursor);
  }

  PlayCursor _advanceCursor(PlayState state) {
    final cursor = state.cursor;
    final frame = state.frames[cursor.frameIndex];
    final isTenth = cursor.frameIndex == 9;
    final justCleared = frame
        .deliveries[cursor.deliveryIndex].pinsStanding.isEmpty;
    final isStrike = cursor.deliveryIndex == 0 && justCleared;

    if (isTenth) {
      final maxDels = (state.frames[9].deliveries.isNotEmpty &&
              (isStrike ||
                  (cursor.deliveryIndex == 1 && justCleared) ||
                  (cursor.deliveryIndex >= 1 &&
                      state.frames[9].deliveries.length >= 2 &&
                      state.frames[9].deliveries[0].pinsStanding.isEmpty)))
          ? 3
          : 2;
      if (cursor.deliveryIndex + 1 >= maxDels) {
        return PlayCursor.gameOver();
      }
      // For non-strike-non-spare 10th-frame second balls, no third delivery.
      return PlayCursor(
        frameIndex: 9,
        deliveryIndex: cursor.deliveryIndex + 1,
      );
    }

    // Frames 1-9: strike → next frame; ball 2 always advances to next.
    if (isStrike || cursor.deliveryIndex >= 1) {
      if (cursor.frameIndex >= 9) return PlayCursor.gameOver();
      return PlayCursor(
        frameIndex: cursor.frameIndex + 1,
        deliveryIndex: 0,
      );
    }
    // Ball 1, non-strike → ball 2 same frame.
    return PlayCursor(
      frameIndex: cursor.frameIndex,
      deliveryIndex: 1,
    );
  }

  List<SubmitFramePayload> _buildSubmitPayload(List<FrameInput> frames) {
    return [
      for (var i = 0; i < frames.length; i++)
        SubmitFramePayload(
          frameNumber: i + 1,
          ball1Standing: frames[i].deliveries.isNotEmpty
              ? frames[i].deliveries[0].pinsStanding
              : const [],
          ball2Standing: frames[i].deliveries.length > 1
              ? frames[i].deliveries[1].pinsStanding
              : null,
          ball3Standing: frames[i].deliveries.length > 2
              ? frames[i].deliveries[2].pinsStanding
              : null,
          ball1EquipmentId: frames[i].deliveries.isNotEmpty
              ? frames[i].deliveries[0].equipmentId
              : null,
          ball2EquipmentId: frames[i].deliveries.length > 1
              ? frames[i].deliveries[1].equipmentId
              : null,
          ball3EquipmentId: frames[i].deliveries.length > 2
              ? frames[i].deliveries[2].equipmentId
              : null,
        ),
    ];
  }
}

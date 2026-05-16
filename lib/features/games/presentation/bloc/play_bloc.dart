import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/live_socket.dart';
import '../../../live/domain/entities/live_broadcast.dart';
import '../../../live/domain/repositories/live_repository.dart';
import '../../data/services/play_local_state_service.dart';
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
  PlayBloc({
    required GamesRepository repository,
    required LiveRepository liveRepository,
    required PlayLocalStateService localState,
    required LiveSocket liveSocket,
    required String sessionUid,
  })  : _repository = repository,
        _live = liveRepository,
        _localState = localState,
        _socket = liveSocket,
        _sessionUid = sessionUid,
        super(PlayState.initial()) {
    on<PlayPinToggled>(_onPinToggled);
    on<PlayStandingChanged>(_onStandingChanged);
    on<PlayQuickAction>(_onQuickAction);
    on<PlayFrameJumped>(_onFrameJumped);
    on<PlayDeliveryUndone>(_onDeliveryUndone);
    on<PlayHandednessChanged>(_onHandednessChanged);
    on<PlayPinDefaultToggled>(_onPinDefaultToggled);
    on<PlaySelectedBallChanged>(_onSelectedBallChanged);
    on<PlayGameSubmitted>(_onSubmit);
    on<PlayGameReset>(_onReset);
    on<PlayEntryModeChanged>(_onEntryModeChanged);
    on<PlayQuickScoreDraftChanged>(_onQuickScoreDraftChanged);
    on<PlayQuickScoreSubmitted>(_onQuickScoreSubmitted);
    on<PlayAnotherGameRequested>(_onAnotherGameRequested);
    on<PlayGoLiveRequested>(_onGoLive);
    on<PlayEndLiveRequested>(_onEndLive);
    on<PlayLiveRehydrateRequested>(_onLiveRehydrate);
    on<PlayLocalStateRehydrateRequested>(_onLocalStateRehydrate);
    on<_PlayLiveSocketEvent>(_onLiveSocketEvent);
  }

  final GamesRepository _repository;
  final LiveRepository _live;
  final PlayLocalStateService _localState;
  final LiveSocket _socket;
  final String _sessionUid;

  StreamSubscription<LiveSocketEvent>? _socketSub;

  /// Snapshot the current state to disk. Fire-and-forget — saving failures
  /// shouldn't block UI updates.
  void _persist(PlayState s) {
    // Skip persistence when the user is on the celebration card — the
    // game already shipped to the server.
    if (s.submittedGame != null) return;
    _localState.save(_sessionUid, s);
  }

  /// Open the live-broadcast socket and route incoming events back into
  /// this bloc. Idempotent — re-calling with the same id is cheap.
  void _attachSocket(int livescoreId) {
    _socket.connect(livescoreId);
    _socketSub ??= _socket.events.listen(
      (event) => add(_PlayLiveSocketEvent(event)),
    );
  }

  Future<void> _detachSocket() async {
    await _socketSub?.cancel();
    _socketSub = null;
    await _socket.disconnect();
  }

  @override
  Future<void> close() async {
    await _detachSocket();
    return super.close();
  }

  // ── socket inbound ─────────────────────────────────────────────────────────
  void _onLiveSocketEvent(
    _PlayLiveSocketEvent event,
    Emitter<PlayState> emit,
  ) {
    final live = state.live;
    if (live == null) return;
    final ev = event.event;
    // Ignore events from a stale broadcast (e.g. we just hot-swapped
    // and a queued message arrived for the previous id).
    if (ev.livescoreId != live.id) return;
    switch (ev) {
      case LiveInitEvent(:final viewerCount):
        emit(state.copyWith(live: live.copyWith(viewerCount: viewerCount)));
      case LiveViewerCountEvent(:final viewerCount):
        emit(state.copyWith(live: live.copyWith(viewerCount: viewerCount)));
      case LiveBroadcastEndedEvent():
        // Server terminated the broadcast — drop local state to match.
        emit(state.copyWith(clearLive: true));
        _detachSocket();
    }
  }

  // ── pin toggle ─────────────────────────────────────────────────────────────
  void _onPinToggled(PlayPinToggled event, Emitter<PlayState> emit) {
    if (state.cursor.isGameOver) return;
    final frame = state.frames[state.cursor.frameIndex];
    final activeDelivery = _currentDeliveryStanding(frame, state.cursor);
    final next = activeDelivery.contains(event.pin)
        ? [...activeDelivery.where((p) => p != event.pin)]
        : [...activeDelivery, event.pin]
      ..sort();
    final newState = _withActiveStanding(state, next);
    emit(newState);
    _persist(newState);
  }

  // ── quick actions: Strike / Spare / Miss / Clear / Next ───────────────────
  void _onQuickAction(PlayQuickAction event, Emitter<PlayState> emit) {
    if (state.cursor.isGameOver) return;
    final PlayState newState;
    switch (event.action) {
      case PlayQuickActionType.strike:
        // Mark all pins down (empty standing) and commit.
        newState = _commitDelivery(state, const <int>[]);
      case PlayQuickActionType.spare:
        // Clear whatever's still up.
        newState = _commitDelivery(state, const <int>[]);
      case PlayQuickActionType.miss:
        // Keep whatever's standing — same set as before this delivery.
        final priorStanding = _priorStanding(state);
        newState = _commitDelivery(state, priorStanding);
      case PlayQuickActionType.clear:
        // Reset the in-progress active delivery. With pin-default
        // 'standing' the rack returns to all-up; with 'knocked' it goes
        // to all-down (so the user re-taps which ones survived).
        final priorStanding = _priorStanding(state);
        final reset = state.pinDefault == PinDefaultState.knocked
            ? const <int>[]
            : priorStanding;
        newState = _withActiveStanding(state, reset);
      case PlayQuickActionType.next:
        // Commit whatever the user has currently painted on the deck.
        newState = _commitDelivery(state, state.activeStanding);
    }
    emit(newState);
    _persist(newState);
  }

  // ── jump to a specific frame (scorecard tap) ───────────────────────────────
  void _onFrameJumped(PlayFrameJumped event, Emitter<PlayState> emit) {
    if (event.frameIndex < 0 || event.frameIndex > 9) return;
    final f = state.frames[event.frameIndex];
    final newState = state.copyWith(
      cursor: PlayCursor(
        frameIndex: event.frameIndex,
        deliveryIndex: f.deliveries.length,
      ),
    );
    emit(newState);
    _persist(newState);
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

    final newState = state.copyWith(
      frames: nextFrames,
      cursor: PlayCursor(
        frameIndex: frameIdx,
        deliveryIndex: shortened.length,
      ),
      score: computeGame(nextFrames),
    );
    emit(newState);
    _persist(newState);
  }

  void _onHandednessChanged(
    PlayHandednessChanged event,
    Emitter<PlayState> emit,
  ) {
    final newState = state.copyWith(handedness: event.handedness);
    emit(newState);
    _persist(newState);
  }

  /// Drag-aware setter: the deck pushes the full standing-pin set after
  /// every pointer move. We mirror it into the in-progress delivery and
  /// recompute the score; cursor doesn't advance until the user commits
  /// via Next / a quick action.
  void _onStandingChanged(
    PlayStandingChanged event,
    Emitter<PlayState> emit,
  ) {
    if (state.cursor.isGameOver) return;
    final newState = _withActiveStanding(state, event.standing);
    emit(newState);
    _persist(newState);
  }

  /// Flip the user's pin-default preference. If they're mid-delivery on
  /// a fresh frame, reset the active delivery's standing set to match.
  void _onPinDefaultToggled(
    PlayPinDefaultToggled event,
    Emitter<PlayState> emit,
  ) {
    final next = state.pinDefault == PinDefaultState.standing
        ? PinDefaultState.knocked
        : PinDefaultState.standing;
    final newState = state.copyWith(pinDefault: next);
    emit(newState);
    _persist(newState);
  }

  void _onSelectedBallChanged(
    PlaySelectedBallChanged event,
    Emitter<PlayState> emit,
  ) {
    final newState = state.copyWith(
      selectedBallId: event.userBallId,
      clearSelectedBall: event.userBallId == null,
    );
    emit(newState);
    _persist(newState);
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
      (game) {
        emit(state.copyWith(submitting: false, submittedGame: game));
        // Game is on the server now — drop the resume blob so the next
        // mount doesn't re-load a stale in-progress state.
        _localState.clear(_sessionUid);
      },
    );
  }

  void _onReset(PlayGameReset event, Emitter<PlayState> emit) {
    emit(PlayState.initial());
    _localState.clear(_sessionUid);
  }

  // ── entry mode + quick score ──────────────────────────────────────────────
  void _onEntryModeChanged(
    PlayEntryModeChanged event,
    Emitter<PlayState> emit,
  ) {
    final newState = state.copyWith(entryMode: event.mode);
    emit(newState);
    _persist(newState);
  }

  void _onQuickScoreDraftChanged(
    PlayQuickScoreDraftChanged event,
    Emitter<PlayState> emit,
  ) {
    final newState = state.copyWith(quickScoreDraft: event.value);
    emit(newState);
    _persist(newState);
  }

  Future<void> _onQuickScoreSubmitted(
    PlayQuickScoreSubmitted event,
    Emitter<PlayState> emit,
  ) async {
    final score = event.totalScore;
    if (score < 0 || score > 300) {
      emit(state.copyWith(errors: const ['Score must be between 0 and 300.']));
      return;
    }
    emit(state.copyWith(submitting: true, errors: const []));
    final res = await _repository.submitQuickScore(
      sessionUid: _sessionUid,
      totalScore: score,
      handedness: state.handedness,
    );
    res.fold(
      (f) => emit(state.copyWith(submitting: false, errors: f.messages)),
      (game) {
        emit(state.copyWith(
          submitting: false,
          submittedGame: game,
          // Clear the draft so re-entering quick mode starts blank.
          quickScoreDraft: '',
        ));
        _localState.clear(_sessionUid);
      },
    );
  }

  /// "Another Game" tap on the celebration screen. Preserves prefs
  /// (handedness / pin-default / selected ball / entry mode), bumps the
  /// game number, and wipes the just-submitted result so the user is
  /// returned to a fresh play surface.
  ///
  /// When live, ALSO POSTs `/api/games/sessions/{uid}/start-game` to spin
  /// up a fresh server-side Game row and retargets the broadcast at it —
  /// otherwise per-frame PUTs would keep streaming into the just-finished
  /// game and viewers would never see the new one start.
  Future<void> _onAnotherGameRequested(
    PlayAnotherGameRequested event,
    Emitter<PlayState> emit,
  ) async {
    final reset = state.resetForNextGame();
    if (reset.live == null) {
      emit(reset);
      _persist(reset);
      return;
    }
    final entryModeStr =
        reset.entryMode == PlayEntryMode.quick ? 'quick' : 'full';
    final res = await _repository.startNextGame(
      sessionUid: _sessionUid,
      entryMode: entryModeStr,
    );
    res.fold(
      (f) => emit(reset.copyWith(errors: f.messages)),
      (game) {
        final next = reset.copyWith(
          live: reset.live!.copyWith(
            currentGameId: game.id,
            currentGameNumber: game.gameNumber,
          ),
        );
        emit(next);
        _persist(next);
      },
    );
  }

  // ── live broadcast ────────────────────────────────────────────────────────
  Future<void> _onGoLive(
    PlayGoLiveRequested event,
    Emitter<PlayState> emit,
  ) async {
    if (state.isLive || state.liveBusy) return;
    emit(state.copyWith(liveBusy: true, errors: const []));
    final res = await _live.startBroadcast(sessionUid: _sessionUid);
    res.fold(
      (f) => emit(state.copyWith(liveBusy: false, errors: f.messages)),
      (broadcast) {
        emit(state.copyWith(liveBusy: false, live: broadcast));
        _attachSocket(broadcast.id);
      },
    );
  }

  Future<void> _onEndLive(
    PlayEndLiveRequested event,
    Emitter<PlayState> emit,
  ) async {
    final live = state.live;
    if (live == null || state.liveBusy) return;
    emit(state.copyWith(liveBusy: true, errors: const []));
    final res = await _live.endBroadcast(live.id);
    res.fold(
      (f) => emit(state.copyWith(liveBusy: false, errors: f.messages)),
      // Clear the broadcast regardless — server already terminated it.
      (_) {
        emit(state.copyWith(liveBusy: false, clearLive: true));
        _detachSocket();
      },
    );
  }

  /// On screen mount: adopt the user's active broadcast if there is one
  /// AND it belongs to this session. This handles cold-start mid-broadcast.
  Future<void> _onLiveRehydrate(
    PlayLiveRehydrateRequested event,
    Emitter<PlayState> emit,
  ) async {
    if (state.isLive) return;
    final res = await _live.getMyActive();
    res.fold(
      (_) {/* silent — rehydrate is best-effort */},
      (broadcast) {
        if (broadcast == null) return;
        if (broadcast.sessionUid != null &&
            broadcast.sessionUid != _sessionUid) {
          return;
        }
        emit(state.copyWith(live: broadcast));
        _attachSocket(broadcast.id);
      },
    );
  }

  /// On screen mount: read any saved play state for this session and
  /// adopt it. No-op if there's nothing saved (fresh game) or if the
  /// player has already started interacting in this run.
  Future<void> _onLocalStateRehydrate(
    PlayLocalStateRehydrateRequested event,
    Emitter<PlayState> emit,
  ) async {
    final saved = await _localState.load(_sessionUid);
    if (saved == null) return;
    // Don't clobber an active in-progress state (e.g. if rehydrate runs
    // after the user already started bowling in this mount).
    final pristine = state.frames.every((f) => f.deliveries.isEmpty) &&
        state.cursor.frameIndex == 0 &&
        state.cursor.deliveryIndex == 0;
    if (!pristine) return;
    // Preserve any broadcast already rehydrated on this mount.
    emit(saved.copyWith(
      live: state.live,
      liveBusy: state.liveBusy,
    ));
  }

  /// Fire-and-forget per-frame PUT used while broadcasting. Called
  /// inside [_commitDelivery] after every committed throw so viewers
  /// stay in sync without waiting for the full-game submit.
  void _syncFrameToBroadcast(PlayState newState, int committedFrameIdx) {
    final live = newState.live;
    final gameId = live?.currentGameId;
    if (live == null || gameId == null) return;
    final frame = newState.frames[committedFrameIdx];
    if (frame.deliveries.isEmpty) return;
    final payload = SubmitFramePayload(
      frameNumber: committedFrameIdx + 1,
      ball1Standing: frame.deliveries[0].pinsStanding,
      ball2Standing: frame.deliveries.length > 1
          ? frame.deliveries[1].pinsStanding
          : null,
      ball3Standing: frame.deliveries.length > 2
          ? frame.deliveries[2].pinsStanding
          : null,
      ball1EquipmentId: frame.deliveries[0].equipmentId,
      ball2EquipmentId: frame.deliveries.length > 1
          ? frame.deliveries[1].equipmentId
          : null,
      ball3EquipmentId: frame.deliveries.length > 2
          ? frame.deliveries[2].equipmentId
          : null,
    );
    // Don't await — failure here shouldn't block the player's next throw.
    _repository.updateFrame(gameId: gameId, frame: payload);
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
      dels[cursor.deliveryIndex] = Delivery(
        pinsStanding: standing,
        equipmentId: state.selectedBallId,
      );
    } else {
      dels.add(Delivery(
        pinsStanding: standing,
        equipmentId: state.selectedBallId,
      ));
    }
    frames[cursor.frameIndex] = frame.copyWith(deliveries: dels);

    final newScore = computeGame(frames);
    return state.copyWith(frames: frames, score: newScore);
  }

  /// Commit the current delivery with [standing] and advance the cursor.
  PlayState _commitDelivery(PlayState state, List<int> standing) {
    final committedFrameIdx = state.cursor.frameIndex;
    final intermediate = _withActiveStanding(state, standing);
    final nextCursor = _advanceCursor(intermediate);
    final next = intermediate.copyWith(cursor: nextCursor);
    // Stream the just-committed frame to viewers when broadcasting.
    _syncFrameToBroadcast(next, committedFrameIdx);
    return next;
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

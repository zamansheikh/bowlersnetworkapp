// presentation/bloc/add_score_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/bowling_game_entity.dart';
import '../../domain/entities/frame_entity.dart';
import '../../domain/entities/throw_entity.dart';
import '../../domain/repositories/game_repository.dart';
import 'add_score_event.dart';
import 'add_score_state.dart';

@injectable
class AddScoreBloc extends Bloc<AddScoreEvent, AddScoreState> {
  final GameRepository _gameRepository;
  static const List<int> _pinNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  static Set<int> _fullPinSet() => _pinNumbers.toSet();

  AddScoreBloc(this._gameRepository)
    : super(
        AddScoreState(
          frames: const <FrameEntity>[],
          currentFrame: 1,
          currentThrow: 1,
          currentKnockedPins: _fullPinSet(),
          currentIsFoul: false,
          cumulativeScores: const <int>[],
          completionScore: null,
        ),
      ) {
    on<StartNewGame>(_onStartNewGame);
    on<SelectPin>(_onSelectPin);
    on<PressShortcut>(_onPressShortcut);
    on<ConfirmThrow>(_onConfirmThrow);
    on<PreviousThrow>(_onPreviousThrow);
    on<NextThrow>(_onNextThrow);
    on<SaveGame>(_onSaveGame);
    on<DismissCompletionDialog>(_onDismissCompletionDialog);
  }

  void _onStartNewGame(StartNewGame event, Emitter<AddScoreState> emit) {
    final frames = List.generate(10, (i) => FrameEntity(number: i + 1));
    emit(
      AddScoreState(
        frames: frames,
        currentFrame: 1,
        currentThrow: 1,
        currentKnockedPins: _fullPinSet(),
        currentIsFoul: false,
        cumulativeScores: const <int>[],
        completionScore: null,
      ),
    );
  }

  void _onSelectPin(SelectPin event, Emitter<AddScoreState> emit) {
    if (state.currentIsFoul) return;

    final standingBefore = _pinsStandingBeforeThrow(
      state.frames,
      state.currentFrame - 1,
      state.currentThrow - 1,
    );

    if (!standingBefore.contains(event.pin)) return;

    final updated = {...state.currentKnockedPins};
    if (updated.contains(event.pin)) {
      updated.remove(event.pin);
    } else {
      updated.add(event.pin);
    }

    emit(state.copyWith(currentKnockedPins: updated));
  }

  void _onPressShortcut(PressShortcut event, Emitter<AddScoreState> emit) {
    switch (event.type) {
      case ShortcutType.foul:
        _commitThrow(emit, knockedPins: <int>{}, isFoul: true);
        break;
      case ShortcutType.miss:
        _commitThrow(emit, knockedPins: <int>{}, isFoul: false);
        break;
      case ShortcutType.strikeOrSpare:
        final standingBefore = _pinsStandingBeforeThrow(
          state.frames,
          state.currentFrame - 1,
          state.currentThrow - 1,
        );
        if (standingBefore.isEmpty) {
          return;
        }
        _commitThrow(emit, knockedPins: standingBefore, isFoul: false);
        break;
    }
  }

  void _onConfirmThrow(ConfirmThrow event, Emitter<AddScoreState> emit) {
    if (!_hasPendingChanges(state)) {
      return;
    }
    _commitThrow(emit);
  }

  void _onPreviousThrow(PreviousThrow event, Emitter<AddScoreState> emit) {
    final timeline = _buildTimeline(state.frames);
    if (timeline.isEmpty) return;

    final currentIndex = _currentTimelineIndex(state, timeline);
    if (currentIndex <= 0) return;

    final pointer = timeline[currentIndex - 1];
    emit(_stateForPointer(state, pointer));
  }

  void _onNextThrow(NextThrow event, Emitter<AddScoreState> emit) {
    if (_hasPendingChanges(state)) {
      _commitThrow(emit);
      return;
    }

    final timeline = _buildTimeline(state.frames);
    final currentIndex = _currentTimelineIndex(state, timeline);

    if (currentIndex < timeline.length - 1) {
      final pointer = timeline[currentIndex + 1];
      emit(_stateForPointer(state, pointer));
      return;
    }

    final nextEntry = _nextEntryPosition(state.frames);
    if (nextEntry == null) return;

    final pointer = _pointerForPosition(state.frames, nextEntry);
    if (pointer != null) {
      emit(_stateForPointer(state, pointer));
      return;
    }

    final standingBefore = _pinsStandingBeforeThrow(
      state.frames,
      nextEntry.frame - 1,
      nextEntry.throwNumber - 1,
    );

    emit(
      state.copyWith(
        currentFrame: nextEntry.frame,
        currentThrow: nextEntry.throwNumber,
        currentKnockedPins: standingBefore,
        currentIsFoul: false,
      ),
    );
  }

  Future<void> _onSaveGame(SaveGame event, Emitter<AddScoreState> emit) async {
    final game = BowlingGameEntity(
      frames: state.frames,
      totalScore: state.cumulativeScores.lastOrNull ?? 0,
      date: DateTime.now(),
    );
    await _gameRepository.saveGame(game);
  }

  void _onDismissCompletionDialog(
    DismissCompletionDialog event,
    Emitter<AddScoreState> emit,
  ) {
    if (state.completionScore == null) return;
    emit(state.copyWith(completionScore: null, setCompletionScore: true));
  }

  void _commitThrow(
    Emitter<AddScoreState> emit, {
    Set<int>? knockedPins,
    bool? isFoul,
  }) {
    final frameIndex = state.currentFrame - 1;
    if (frameIndex < 0 || frameIndex >= state.frames.length) return;

    final targetThrowIndex = state.currentThrow - 1;
    final standingBefore = _pinsStandingBeforeThrow(
      state.frames,
      frameIndex,
      targetThrowIndex,
    );

    final sanitizedThrow = _clipThrow(
      ThrowEntity(
        knockedPins: Set<int>.from(knockedPins ?? state.currentKnockedPins),
        isFoul: isFoul ?? state.currentIsFoul,
      ),
      standingBefore,
    );

    final updatedFrames = [...state.frames];
    final frame = updatedFrames[frameIndex];
    final updatedThrows = [...frame.throws];

    if (targetThrowIndex < updatedThrows.length) {
      updatedThrows[targetThrowIndex] = sanitizedThrow;
    } else {
      updatedThrows.add(sanitizedThrow);
    }

    final normalizedThrows = _normalizeThrows(frameIndex, updatedThrows);
    updatedFrames[frameIndex] = frame.copyWith(throws: normalizedThrows);

    final cumulatives = _computeCumulatives(updatedFrames);
    final timeline = _buildTimeline(updatedFrames);

    final committedIndex = normalizedThrows.isEmpty
        ? 0
        : (targetThrowIndex >= normalizedThrows.length
              ? normalizedThrows.length - 1
              : targetThrowIndex);
    final committedPointer = _ThrowPointer(frameIndex, committedIndex);

    final committedTimelineIndex = timeline.indexWhere(
      (pointer) =>
          pointer.frameIndex == committedPointer.frameIndex &&
          pointer.throwIndex == committedPointer.throwIndex,
    );

    final bool completed = _isGameComplete(updatedFrames);

    _ThrowPointer? nextPointer;
    _Position? nextEntry;

    if (!completed &&
        committedTimelineIndex != -1 &&
        committedTimelineIndex < timeline.length - 1) {
      nextPointer = timeline[committedTimelineIndex + 1];
    } else if (!completed) {
      nextEntry = _nextEntryPosition(updatedFrames);
      if (nextEntry != null) {
        final candidate = _pointerForPosition(updatedFrames, nextEntry);
        if (candidate != null) {
          nextPointer = candidate;
          nextEntry = null;
        }
      }
    } else {
      nextPointer = committedPointer;
    }

    late final int newFrame;
    late final int newThrow;
    late final Set<int> newKnockedPins;
    late final bool newIsFoul;

    if (nextPointer != null) {
      final standingBeforeNext = _pinsStandingBeforeThrow(
        updatedFrames,
        nextPointer.frameIndex,
        nextPointer.throwIndex,
      );
      final nextThrowEntity =
          updatedFrames[nextPointer.frameIndex].throws[nextPointer.throwIndex];
      final clippedNext = _clipThrow(nextThrowEntity, standingBeforeNext);
      newFrame = nextPointer.frameIndex + 1;
      newThrow = nextPointer.throwIndex + 1;
      newKnockedPins = clippedNext.knockedPins;
      newIsFoul = clippedNext.isFoul;
    } else if (nextEntry != null) {
      final standingBeforeNext = _pinsStandingBeforeThrow(
        updatedFrames,
        nextEntry.frame - 1,
        nextEntry.throwNumber - 1,
      );
      newFrame = nextEntry.frame;
      newThrow = nextEntry.throwNumber;
      newKnockedPins = standingBeforeNext;
      newIsFoul = false;
    } else {
      final standingBeforeCurrent = _pinsStandingBeforeThrow(
        updatedFrames,
        committedPointer.frameIndex,
        committedPointer.throwIndex,
      );
      final currentThrowEntity = updatedFrames[committedPointer.frameIndex]
          .throws[committedPointer.throwIndex];
      final clippedCurrent = _clipThrow(
        currentThrowEntity,
        standingBeforeCurrent,
      );
      newFrame = committedPointer.frameIndex + 1;
      newThrow = committedPointer.throwIndex + 1;
      newKnockedPins = clippedCurrent.knockedPins;
      newIsFoul = clippedCurrent.isFoul;
    }

    final int? completionScore = completed ? cumulatives.lastOrNull ?? 0 : null;

    emit(
      state.copyWith(
        frames: updatedFrames,
        currentFrame: newFrame,
        currentThrow: newThrow,
        currentKnockedPins: newKnockedPins,
        currentIsFoul: newIsFoul,
        cumulativeScores: cumulatives,
        completionScore: completionScore,
        setCompletionScore: true,
      ),
    );
  }

  bool _hasPendingChanges(AddScoreState state) {
    final frameIndex = state.currentFrame - 1;
    final throwIndex = state.currentThrow - 1;

    if (frameIndex < 0 || frameIndex >= state.frames.length) {
      return state.currentIsFoul || state.currentKnockedPins.isNotEmpty;
    }

    final frame = state.frames[frameIndex];
    final standingBefore = _pinsStandingBeforeThrow(
      state.frames,
      frameIndex,
      throwIndex,
    );

    if (throwIndex < frame.throws.length) {
      final existing = _clipThrow(frame.throws[throwIndex], standingBefore);
      if (existing.isFoul != state.currentIsFoul) {
        return true;
      }
      return !_setEquals(existing.knockedPins, state.currentKnockedPins);
    }

    if (state.currentIsFoul) {
      return true;
    }

    return state.currentKnockedPins.isNotEmpty;
  }

  List<_ThrowPointer> _buildTimeline(List<FrameEntity> frames) {
    final pointers = <_ThrowPointer>[];
    for (var i = 0; i < frames.length; i++) {
      final frame = frames[i];
      for (var j = 0; j < frame.throws.length; j++) {
        pointers.add(_ThrowPointer(i, j));
      }
    }
    return pointers;
  }

  int _currentTimelineIndex(AddScoreState state, List<_ThrowPointer> timeline) {
    final frameIndex = state.currentFrame - 1;
    if (frameIndex >= 0 && frameIndex < state.frames.length) {
      final frame = state.frames[frameIndex];
      final throwIndex = state.currentThrow - 1;
      if (throwIndex >= 0 && throwIndex < frame.throws.length) {
        for (var i = 0; i < timeline.length; i++) {
          final pointer = timeline[i];
          if (pointer.frameIndex == frameIndex &&
              pointer.throwIndex == throwIndex) {
            return i;
          }
        }
      }
    }
    return timeline.length;
  }

  AddScoreState _stateForPointer(AddScoreState current, _ThrowPointer pointer) {
    final standingBefore = _pinsStandingBeforeThrow(
      current.frames,
      pointer.frameIndex,
      pointer.throwIndex,
    );
    final throwEntity =
        current.frames[pointer.frameIndex].throws[pointer.throwIndex];
    final clipped = _clipThrow(throwEntity, standingBefore);
    return current.copyWith(
      currentFrame: pointer.frameIndex + 1,
      currentThrow: pointer.throwIndex + 1,
      currentKnockedPins: clipped.knockedPins,
      currentIsFoul: clipped.isFoul,
    );
  }

  _Position? _nextEntryPosition(List<FrameEntity> frames) {
    for (var i = 0; i < frames.length; i++) {
      final frame = frames[i];
      final allowed = _maxThrowsForFrame(i, frame);
      if (frame.throws.length < allowed) {
        return _Position(i + 1, frame.throws.length + 1);
      }
    }
    return null;
  }

  List<ThrowEntity> _normalizeThrows(int frameIndex, List<ThrowEntity> throws) {
    if (frameIndex < 9) {
      return _normalizeRegularFrame(throws);
    }
    return _normalizeTenthFrame(throws);
  }

  List<ThrowEntity> _normalizeRegularFrame(List<ThrowEntity> throws) {
    if (throws.isEmpty) {
      return throws;
    }

    var standing = _fullPinSet();
    final result = <ThrowEntity>[];

    final first = _clipThrow(throws.first, standing);
    result.add(first);

    if (!first.isFoul && first.pinsKnocked == 10) {
      return result;
    }

    if (throws.length >= 2) {
      standing = _applyThrowToStanding(standing, first);
      final second = _clipThrow(throws[1], standing);
      result.add(second);
    }

    return result;
  }

  List<ThrowEntity> _normalizeTenthFrame(List<ThrowEntity> throws) {
    if (throws.isEmpty) {
      return throws;
    }

    final result = <ThrowEntity>[];
    final first = _clipThrow(throws[0], _fullPinSet());
    result.add(first);

    if (throws.length >= 2) {
      final standingBeforeSecond = _standingBeforeSecondInTenth(first);
      final second = _clipThrow(throws[1], standingBeforeSecond);
      result.add(second);

      final allowThird = _allowTenthFrameThirdBall(first, second);
      if (allowThird && throws.length >= 3) {
        final standingBeforeThird = _standingBeforeThirdInTenth(first, second);
        final third = _clipThrow(throws[2], standingBeforeThird);
        result.add(third);
      }
    }

    return result;
  }

  bool _allowTenthFrameThirdBall(ThrowEntity first, ThrowEntity second) {
    if (!first.isFoul && first.pinsKnocked == 10) {
      return true;
    }
    if (!second.isFoul && second.pinsKnocked == 10) {
      return true;
    }
    if (!first.isFoul &&
        !second.isFoul &&
        first.pinsKnocked + second.pinsKnocked == 10) {
      return true;
    }
    return false;
  }

  int _maxThrowsForFrame(int frameIndex, FrameEntity frame) {
    if (frameIndex < 9) {
      if (frame.throws.isEmpty) {
        return 2;
      }
      final first = frame.throws.first;
      if (!first.isFoul && first.pinsKnocked == 10) {
        return 1;
      }
      return 2;
    }

    if (frame.throws.length < 2) {
      return 3;
    }

    final first = frame.throws[0];
    final second = frame.throws[1];
    return _allowTenthFrameThirdBall(first, second) ? 3 : 2;
  }

  bool _setEquals(Set<int> a, Set<int> b) {
    if (a.length != b.length) return false;
    for (final value in a) {
      if (!b.contains(value)) {
        return false;
      }
    }
    return true;
  }

  List<int> _computeCumulatives(List<FrameEntity> frames) {
    final throwPins = <int>[];
    for (final frame in frames) {
      for (final t in frame.throws) {
        throwPins.add(t.pinsKnocked);
      }
    }

    final cumulatives = <int>[];
    var total = 0;
    var throwIndex = 0;

    for (var frameNumber = 0; frameNumber < 10; frameNumber++) {
      var frameScore = 0;
      if (throwIndex >= throwPins.length) break;

      final first = throwPins[throwIndex];
      frameScore += first;
      throwIndex++;

      if (first == 10) {
        if (throwIndex < throwPins.length) {
          frameScore += throwPins[throwIndex];
        }
        if (throwIndex + 1 < throwPins.length) {
          frameScore += throwPins[throwIndex + 1];
        }
      } else {
        if (throwIndex < throwPins.length) {
          final second = throwPins[throwIndex];
          frameScore += second;
          throwIndex++;
          if (first + second == 10) {
            if (throwIndex < throwPins.length) {
              frameScore += throwPins[throwIndex];
            }
          }
        }
      }

      total += frameScore;
      cumulatives.add(total);
    }

    return cumulatives;
  }

  ThrowEntity _clipThrow(ThrowEntity throwEntity, Set<int> standingBefore) {
    if (throwEntity.isFoul) {
      return ThrowEntity(knockedPins: <int>{}, isFoul: true);
    }
    final clipped = throwEntity.knockedPins
        .where((pin) => standingBefore.contains(pin))
        .toSet();
    return ThrowEntity(knockedPins: clipped, isFoul: false);
  }

  Set<int> _applyThrowToStanding(Set<int> standing, ThrowEntity throwEntity) {
    final nextStanding = Set<int>.from(standing);
    if (!throwEntity.isFoul) {
      nextStanding.removeAll(throwEntity.knockedPins);
    }
    return nextStanding;
  }

  Set<int> _pinsStandingBeforeThrow(
    List<FrameEntity> frames,
    int frameIndex,
    int throwIndex,
  ) {
    var standing = _fullPinSet();
    if (frameIndex < 0 || frameIndex >= frames.length) {
      return standing;
    }

    final frame = frames[frameIndex];

    if (frameIndex < 9) {
      final throws = frame.throws;
      for (var i = 0; i < throwIndex && i < throws.length; i++) {
        standing = _applyThrowToStanding(standing, throws[i]);
      }
      return standing;
    }

    if (throwIndex <= 0) {
      return standing;
    }

    final first = frame.throws.isNotEmpty
        ? _clipThrow(frame.throws[0], standing)
        : ThrowEntity(knockedPins: <int>{});
    if (throwIndex == 1) {
      return _standingBeforeSecondInTenth(first);
    }

    final second = frame.throws.length > 1
        ? _clipThrow(frame.throws[1], _standingBeforeSecondInTenth(first))
        : ThrowEntity(knockedPins: <int>{});
    return _standingBeforeThirdInTenth(first, second);
  }

  Set<int> _standingBeforeSecondInTenth(ThrowEntity first) {
    if (!first.isFoul && first.pinsKnocked == 10) {
      return _fullPinSet();
    }
    return _applyThrowToStanding(_fullPinSet(), first);
  }

  Set<int> _standingBeforeThirdInTenth(ThrowEntity first, ThrowEntity second) {
    if (!first.isFoul && first.pinsKnocked == 10) {
      if (!second.isFoul && second.pinsKnocked == 10) {
        return _fullPinSet();
      }
      return _applyThrowToStanding(_fullPinSet(), second);
    }

    if (!first.isFoul &&
        !second.isFoul &&
        first.pinsKnocked + second.pinsKnocked == 10) {
      return _fullPinSet();
    }

    final standingBeforeSecond = _standingBeforeSecondInTenth(first);
    return _applyThrowToStanding(standingBeforeSecond, second);
  }

  _ThrowPointer? _pointerForPosition(
    List<FrameEntity> frames,
    _Position position,
  ) {
    final frameIndex = position.frame - 1;
    final throwIndex = position.throwNumber - 1;
    if (frameIndex < 0 ||
        frameIndex >= frames.length ||
        throwIndex < 0 ||
        throwIndex >= frames[frameIndex].throws.length) {
      return null;
    }
    return _ThrowPointer(frameIndex, throwIndex);
  }

  bool _isGameComplete(List<FrameEntity> frames) {
    if (frames.length < 10) return false;
    for (var i = 0; i < frames.length; i++) {
      if (!_isFrameComplete(i, frames[i])) {
        return false;
      }
    }
    return true;
  }

  bool _isFrameComplete(int index, FrameEntity frame) {
    if (index < 9) {
      if (frame.throws.isEmpty) {
        return false;
      }
      final first = frame.throws.first;
      if (!first.isFoul && first.pinsKnocked == 10) {
        return true;
      }
      return frame.throws.length >= 2;
    }

    if (frame.throws.length < 2) {
      return false;
    }

    final first = frame.throws[0];
    final second = frame.throws[1];
    final needsThird = _allowTenthFrameThirdBall(first, second);
    if (needsThird) {
      return frame.throws.length >= 3;
    }
    return true;
  }
}

class _ThrowPointer {
  final int frameIndex;
  final int throwIndex;

  const _ThrowPointer(this.frameIndex, this.throwIndex);
}

class _Position {
  final int frame;
  final int throwNumber;

  const _Position(this.frame, this.throwNumber);
}

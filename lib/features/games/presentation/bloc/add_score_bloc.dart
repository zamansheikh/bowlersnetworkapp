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

  AddScoreBloc(this._gameRepository)
    : super(
        const AddScoreState(
          frames: [],
          currentFrame: 1,
          currentThrow: 1,
          currentKnockedPins: {},
          currentIsFoul: false,
          cumulativeScores: [],
        ),
      ) {
    on<StartNewGame>(_onStartNewGame);
    on<SelectPin>(_onSelectPin);
    on<PressShortcut>(_onPressShortcut);
    on<ConfirmThrow>(_onConfirmThrow);
    on<PreviousThrow>(_onPreviousThrow);
    on<NextThrow>(_onNextThrow);
    on<SaveGame>(_onSaveGame);
  }

  void _onStartNewGame(StartNewGame event, Emitter<AddScoreState> emit) {
    final frames = List.generate(10, (i) => FrameEntity(number: i + 1));
    emit(
      AddScoreState(
        frames: frames,
        currentFrame: 1,
        currentThrow: 1,
        currentKnockedPins: {},
        currentIsFoul: false,
        cumulativeScores: [],
      ),
    );
  }

  void _onSelectPin(SelectPin event, Emitter<AddScoreState> emit) {
    if (state.currentIsFoul || !state.remainingPins.contains(event.pin)) return;
    final newKnocked = {...state.currentKnockedPins};
    if (newKnocked.contains(event.pin)) {
      newKnocked.remove(event.pin);
    } else {
      newKnocked.add(event.pin);
    }
    emit(state.copyWith(currentKnockedPins: newKnocked));
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
        final remaining = state.remainingPins;
        if (remaining.isEmpty) {
          return;
        }
        _commitThrow(
          emit,
          knockedPins: Set<int>.from(remaining),
          isFoul: false,
        );
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
    if (timeline.isEmpty) {
      return;
    }

    final currentIndex = _currentTimelineIndex(state, timeline);
    if (currentIndex <= 0) {
      // Already at the earliest recorded throw.
      return;
    }

    final pointer = timeline[currentIndex - 1];
    emit(_stateForPointer(state, pointer));
  }

  void _onNextThrow(NextThrow event, Emitter<AddScoreState> emit) {
    if (_hasPendingChanges(state)) {
      _commitThrow(emit);
      return;
    }

    final timeline = _buildTimeline(state.frames);
    if (timeline.isEmpty) {
      return;
    }

    final currentIndex = _currentTimelineIndex(state, timeline);

    if (currentIndex < timeline.length - 1) {
      final pointer = timeline[currentIndex + 1];
      emit(_stateForPointer(state, pointer));
      return;
    }

    if (currentIndex < timeline.length) {
      final nextEntry = _nextEntryPosition(state.frames);
      emit(
        state.copyWith(
          currentFrame: nextEntry.frame,
          currentThrow: nextEntry.throwNumber,
          currentKnockedPins: {},
          currentIsFoul: false,
        ),
      );
    }
  }

  Future<void> _onSaveGame(SaveGame event, Emitter<AddScoreState> emit) async {
    final game = BowlingGameEntity(
      frames: state.frames,
      totalScore: state.cumulativeScores.lastOrNull ?? 0,
      date: DateTime.now(),
    );
    await _gameRepository.saveGame(game);
    // Optionally emit a saved state or reset
  }

  void _commitThrow(
    Emitter<AddScoreState> emit, {
    Set<int>? knockedPins,
    bool? isFoul,
  }) {
    final frameIndex = state.currentFrame - 1;
    if (frameIndex < 0 || frameIndex >= state.frames.length) {
      return;
    }

    final targetThrowIndex = state.currentThrow - 1;
    final updatedFrames = [...state.frames];
    final frame = updatedFrames[frameIndex];
    final updatedThrows = [...frame.throws];

    final throwData = ThrowEntity(
      knockedPins: Set<int>.from(knockedPins ?? state.currentKnockedPins),
      isFoul: isFoul ?? state.currentIsFoul,
    );

    if (targetThrowIndex < updatedThrows.length) {
      updatedThrows[targetThrowIndex] = throwData;
    } else {
      updatedThrows.add(throwData);
    }

    final normalizedThrows = _normalizeThrows(frameIndex, updatedThrows);
    updatedFrames[frameIndex] = frame.copyWith(throws: normalizedThrows);

    final cumulatives = _computeCumulatives(updatedFrames);

    final committedIndex = normalizedThrows.isEmpty
        ? 0
        : (targetThrowIndex >= normalizedThrows.length
              ? normalizedThrows.length - 1
              : targetThrowIndex);

    final nextPosition = _nextPositionAfterCommit(
      frames: updatedFrames,
      committedFrame: frameIndex,
      committedThrow: committedIndex,
    );

    emit(
      state.copyWith(
        frames: updatedFrames,
        currentFrame: nextPosition.frame,
        currentThrow: nextPosition.throwNumber,
        currentKnockedPins: {},
        currentIsFoul: false,
        cumulativeScores: cumulatives,
      ),
    );
  }

  bool _hasPendingChanges(AddScoreState state) {
    final frameIndex = state.currentFrame - 1;
    if (frameIndex < 0 || frameIndex >= state.frames.length) {
      return state.currentIsFoul || state.currentKnockedPins.isNotEmpty;
    }

    final frame = state.frames[frameIndex];
    final targetIndex = state.currentThrow - 1;

    if (targetIndex < frame.throws.length) {
      final existing = frame.throws[targetIndex];
      if (existing.isFoul != state.currentIsFoul) {
        return true;
      }
      if (!_setEquals(existing.knockedPins, state.currentKnockedPins)) {
        return true;
      }
      return false;
    }

    return state.currentIsFoul || state.currentKnockedPins.isNotEmpty;
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
      final targetIndex = state.currentThrow - 1;
      if (targetIndex >= 0 && targetIndex < frame.throws.length) {
        for (var i = 0; i < timeline.length; i++) {
          final pointer = timeline[i];
          if (pointer.frameIndex == frameIndex &&
              pointer.throwIndex == targetIndex) {
            return i;
          }
        }
      }
    }
    return timeline.length;
  }

  AddScoreState _stateForPointer(AddScoreState state, _ThrowPointer pointer) {
    final frame = state.frames[pointer.frameIndex];
    final throwEntity = frame.throws[pointer.throwIndex];
    return state.copyWith(
      currentFrame: pointer.frameIndex + 1,
      currentThrow: pointer.throwIndex + 1,
      currentKnockedPins: Set<int>.from(throwEntity.knockedPins),
      currentIsFoul: throwEntity.isFoul,
    );
  }

  _Position _nextEntryPosition(List<FrameEntity> frames) {
    for (var i = 0; i < frames.length; i++) {
      final frame = frames[i];
      final allowed = _maxThrowsForFrame(i, frame);
      if (frame.throws.length < allowed) {
        return _Position(i + 1, frame.throws.length + 1);
      }
    }

    final lastFrame = frames.last;
    final length = lastFrame.throws.length;
    final throwNumber = length == 0
        ? 1
        : length > 3
        ? 3
        : length;
    return _Position(10, throwNumber);
  }

  _Position _nextPositionAfterCommit({
    required List<FrameEntity> frames,
    required int committedFrame,
    required int committedThrow,
  }) {
    final timeline = _buildTimeline(frames);
    final index = timeline.indexWhere(
      (pointer) =>
          pointer.frameIndex == committedFrame &&
          pointer.throwIndex == committedThrow,
    );

    if (index == -1 || index == timeline.length - 1) {
      return _nextEntryPosition(frames);
    }

    final nextPointer = timeline[index + 1];
    return _Position(nextPointer.frameIndex + 1, nextPointer.throwIndex + 1);
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

    final first = throws.first;
    if (!first.isFoul && first.pinsKnocked == 10) {
      return [first];
    }

    final result = <ThrowEntity>[first];
    if (throws.length >= 2) {
      result.add(throws[1]);
    }
    return result;
  }

  List<ThrowEntity> _normalizeTenthFrame(List<ThrowEntity> throws) {
    if (throws.isEmpty) {
      return throws;
    }

    final result = <ThrowEntity>[throws[0]];

    if (throws.length >= 2) {
      result.add(throws[1]);
    } else {
      return result;
    }

    final first = result[0];
    final second = result[1];
    final allowThird = _allowTenthFrameThirdBall(first, second);

    if (allowThird && throws.length >= 3) {
      result.add(throws[2]);
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
    if (a.length != b.length) {
      return false;
    }
    for (final value in a) {
      if (!b.contains(value)) {
        return false;
      }
    }
    return true;
  }

  List<int> _computeCumulatives(List<FrameEntity> frames) {
    List<int> throwPins = [];
    for (var frame in frames) {
      for (var t in frame.throws) {
        throwPins.add(t.pinsKnocked);
      }
    }

    int total = 0;
    List<int> cumulatives = [];
    int throwIndex = 0;

    for (int f = 0; f < 10; f++) {
      int frameScore = 0;
      if (throwIndex >= throwPins.length) break;

      int first = throwPins[throwIndex];
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
          int second = throwPins[throwIndex];
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

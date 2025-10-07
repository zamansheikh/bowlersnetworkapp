// presentation/bloc/add_score_bloc.dart

import 'package:bloc/bloc.dart';
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
      : super(const AddScoreState(
          frames: [],
          currentFrame: 1,
          currentThrow: 1,
          currentKnockedPins: {},
          currentIsFoul: false,
          cumulativeScores: [],
        )) {
    on<StartNewGame>(_onStartNewGame);
    on<SelectPin>(_onSelectPin);
    on<PressShortcut>(_onPressShortcut);
    on<ConfirmThrow>(_onConfirmThrow);
    on<PreviousThrow>(_onPreviousThrow);
    on<SaveGame>(_onSaveGame);
  }

  void _onStartNewGame(StartNewGame event, Emitter<AddScoreState> emit) {
    final frames = List.generate(10, (i) => FrameEntity(number: i + 1));
    emit(AddScoreState(
      frames: frames,
      currentFrame: 1,
      currentThrow: 1,
      currentKnockedPins: {},
      currentIsFoul: false,
      cumulativeScores: [],
    ));
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
        emit(state.copyWith(currentIsFoul: true, currentKnockedPins: {}));
        break;
      case ShortcutType.miss:
        emit(state.copyWith(currentIsFoul: false, currentKnockedPins: {}));
        break;
      case ShortcutType.strikeOrSpare:
        emit(state.copyWith(currentIsFoul: false, currentKnockedPins: state.remainingPins.toSet()));
        break;
    }
  }

  void _onConfirmThrow(ConfirmThrow event, Emitter<AddScoreState> emit) {
    final newThrow = ThrowEntity(
      knockedPins: state.currentKnockedPins,
      isFoul: state.currentIsFoul,
    );
    final frameIndex = state.currentFrame - 1;
    final frame = state.frames[frameIndex];
    final newThrows = [...frame.throws, newThrow];
    final newFrames = [...state.frames];
    newFrames[frameIndex] = frame.copyWith(throws: newThrows);

    int nextThrow = state.currentThrow + 1;
    int nextFrame = state.currentFrame;
    bool isFrameComplete = false;

    if (state.currentFrame < 10) {
      if (newThrows[0].pinsKnocked == 10 || newThrows.length == 2) {
        isFrameComplete = true;
      }
    } else {
      if (newThrows.length == 3) {
        isFrameComplete = true;
      } else if (newThrows.length == 2 &&
          newThrows[0].pinsKnocked != 10 &&
          newThrows[0].pinsKnocked + newThrows[1].pinsKnocked != 10) {
        isFrameComplete = true;
      }
    }

    if (isFrameComplete && state.currentFrame < 10) {
      nextFrame++;
      nextThrow = 1;
    }

    final newCumulatives = _computeCumulatives(newFrames);

    emit(state.copyWith(
      frames: newFrames,
      currentFrame: nextFrame,
      currentThrow: nextThrow,
      currentKnockedPins: {},
      currentIsFoul: false,
      cumulativeScores: newCumulatives,
    ));
  }

  void _onPreviousThrow(PreviousThrow event, Emitter<AddScoreState> emit) {
    if (state.currentKnockedPins.isNotEmpty || state.currentIsFoul) {
      // Can't go back if changes made to current
      return;
    }

    final frameIndex = state.currentFrame - 1;
    final frame = state.frames[frameIndex];
    if (frame.throws.isNotEmpty) {
      final lastThrow = frame.throws.last;
      final newThrows = frame.throws.sublist(0, frame.throws.length - 1);
      final newFrames = [...state.frames];
      newFrames[frameIndex] = frame.copyWith(throws: newThrows);

      final newCumulatives = _computeCumulatives(newFrames);

      emit(state.copyWith(
        frames: newFrames,
        currentKnockedPins: lastThrow.knockedPins,
        currentIsFoul: lastThrow.isFoul,
        cumulativeScores: newCumulatives,
      ));
    } else if (state.currentFrame > 1) {
      final prevFrameIndex = state.currentFrame - 2;
      final prevFrame = state.frames[prevFrameIndex];
      if (prevFrame.throws.isNotEmpty) {
        add(PreviousThrow()); // Recurse to remove from prev
      }
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
        if (throwIndex < throwPins.length) frameScore += throwPins[throwIndex];
        if (throwIndex + 1 < throwPins.length) frameScore += throwPins[throwIndex + 1];
      } else {
        if (throwIndex < throwPins.length) {
          int second = throwPins[throwIndex];
          frameScore += second;
          throwIndex++;
          if (first + second == 10) {
            if (throwIndex < throwPins.length) frameScore += throwPins[throwIndex];
          }
        }
      }

      total += frameScore;
      cumulatives.add(total);
    }

    return cumulatives;
  }
}
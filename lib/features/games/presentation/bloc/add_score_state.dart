// presentation/bloc/add_score_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/frame_entity.dart';
import '../../domain/entities/throw_entity.dart';

class AddScoreState extends Equatable {
  final String? gameId; // null for new games
  final DateTime? gameDate; // preserve original date for edits
  final List<FrameEntity> frames;
  final int currentFrame; // 1-10
  final int currentThrow; // 1-3
  final Set<int> currentKnockedPins;
  final bool currentIsFoul;
  final List<int> cumulativeScores;
  final int? completionScore;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool hasPendingChanges;
  final bool gameSaved;

  const AddScoreState({
    this.gameId,
    this.gameDate,
    required this.frames,
    required this.currentFrame,
    required this.currentThrow,
    required this.currentKnockedPins,
    required this.currentIsFoul,
    required this.cumulativeScores,
    this.completionScore,
    this.canGoPrevious = false,
    this.canGoNext = false,
    this.hasPendingChanges = false,
    this.gameSaved = false,
  });

  AddScoreState copyWith({
    String? gameId,
    bool setGameId = false,
    DateTime? gameDate,
    bool setGameDate = false,
    List<FrameEntity>? frames,
    int? currentFrame,
    int? currentThrow,
    Set<int>? currentKnockedPins,
    bool? currentIsFoul,
    List<int>? cumulativeScores,
    int? completionScore,
    bool setCompletionScore = false,
    bool? canGoPrevious,
    bool? canGoNext,
    bool? hasPendingChanges,
    bool? gameSaved,
    bool setGameSaved = false,
  }) {
    return AddScoreState(
      gameId: setGameId ? gameId : this.gameId,
      gameDate: setGameDate ? gameDate : this.gameDate,
      frames: frames ?? this.frames,
      currentFrame: currentFrame ?? this.currentFrame,
      currentThrow: currentThrow ?? this.currentThrow,
      currentKnockedPins: currentKnockedPins ?? this.currentKnockedPins,
      currentIsFoul: currentIsFoul ?? this.currentIsFoul,
      cumulativeScores: cumulativeScores ?? this.cumulativeScores,
      completionScore: setCompletionScore
          ? completionScore
          : this.completionScore,
      canGoPrevious: canGoPrevious ?? this.canGoPrevious,
      canGoNext: canGoNext ?? this.canGoNext,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
      gameSaved: setGameSaved ? (gameSaved ?? false) : this.gameSaved,
    );
  }

  Set<int> get remainingPins {
    final allPins = List.generate(10, (i) => i + 1);

    if (frames.isEmpty || currentFrame < 1 || currentFrame > frames.length) {
      return allPins.toSet();
    }

    final frame = frames[currentFrame - 1];
    final targetIndex = currentThrow - 1;

    if (currentFrame == 10) {
      if (targetIndex <= 0) {
        return allPins.toSet();
      }

      final first = frame.throws.isNotEmpty
          ? frame.throws[0]
          : ThrowEntity(knockedPins: <int>{});

      if (targetIndex == 1) {
        if (!first.isFoul && first.pinsKnocked == 10) {
          return allPins.toSet();
        }
        final standing = allPins.toSet();
        if (!first.isFoul) {
          standing.removeAll(first.knockedPins);
        }
        return standing;
      }

      final second = frame.throws.length > 1
          ? frame.throws[1]
          : ThrowEntity(knockedPins: <int>{});

      if (!first.isFoul && first.pinsKnocked == 10) {
        if (!second.isFoul && second.pinsKnocked == 10) {
          return allPins.toSet();
        }
        if (second.isFoul) {
          return allPins.toSet();
        }
        final standing = allPins.toSet();
        standing.removeAll(second.knockedPins);
        return standing;
      }

      if (!first.isFoul &&
          !second.isFoul &&
          first.pinsKnocked + second.pinsKnocked == 10) {
        return allPins.toSet();
      }

      final standing = allPins.toSet();
      if (!first.isFoul) {
        standing.removeAll(first.knockedPins);
      }
      if (!second.isFoul) {
        standing.removeAll(second.knockedPins);
      }
      return standing;
    }

    final standing = allPins.toSet();
    for (var i = 0; i < frame.throws.length && i < targetIndex; i++) {
      final previous = frame.throws[i];
      if (!previous.isFoul) {
        standing.removeAll(previous.knockedPins);
      }
    }
    return standing;
  }

  bool get isGameComplete {
    if (frames.length < 10) return false;
    for (var i = 0; i < 10; i++) {
      if (i >= frames.length) return false;
      final frame = frames[i];
      if (!_isFrameComplete(i, frame)) {
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

    // 10th frame
    if (frame.throws.length < 2) {
      return false;
    }

    final first = frame.throws[0];
    final second = frame.throws[1];

    // Check if third ball is needed
    final strikeOrSpareInFirstTwo =
        (!first.isFoul && first.pinsKnocked == 10) ||
        (!first.isFoul &&
            !second.isFoul &&
            first.pinsKnocked + second.pinsKnocked == 10);

    if (strikeOrSpareInFirstTwo) {
      return frame.throws.length >= 3;
    }

    return true; // Only 2 throws needed
  }

  @override
  List<Object?> get props => [
    gameId,
    gameDate,
    frames,
    currentFrame,
    currentThrow,
    currentKnockedPins,
    currentIsFoul,
    cumulativeScores,
    completionScore,
    canGoPrevious,
    canGoNext,
    hasPendingChanges,
    gameSaved,
  ];
}

// presentation/bloc/add_score_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/frame_entity.dart';
import '../../domain/entities/throw_entity.dart';

class AddScoreState extends Equatable {
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

  const AddScoreState({
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
  });

  AddScoreState copyWith({
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
  }) {
    return AddScoreState(
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

  @override
  List<Object?> get props => [
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
  ];
}

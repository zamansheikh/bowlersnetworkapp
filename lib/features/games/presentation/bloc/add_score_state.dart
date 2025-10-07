// presentation/bloc/add_score_state.dart

import 'package:equatable/equatable.dart';

import '../../domain/entities/frame_entity.dart';

class AddScoreState extends Equatable {
  final List<FrameEntity> frames;
  final int currentFrame; // 1-10
  final int currentThrow; // 1-3
  final Set<int> currentKnockedPins;
  final bool currentIsFoul;
  final List<int> cumulativeScores;

  const AddScoreState({
    required this.frames,
    required this.currentFrame,
    required this.currentThrow,
    required this.currentKnockedPins,
    required this.currentIsFoul,
    required this.cumulativeScores,
  });

  AddScoreState copyWith({
    List<FrameEntity>? frames,
    int? currentFrame,
    int? currentThrow,
    Set<int>? currentKnockedPins,
    bool? currentIsFoul,
    List<int>? cumulativeScores,
  }) {
    return AddScoreState(
      frames: frames ?? this.frames,
      currentFrame: currentFrame ?? this.currentFrame,
      currentThrow: currentThrow ?? this.currentThrow,
      currentKnockedPins: currentKnockedPins ?? this.currentKnockedPins,
      currentIsFoul: currentIsFoul ?? this.currentIsFoul,
      cumulativeScores: cumulativeScores ?? this.cumulativeScores,
    );
  }

  Set<int> get remainingPins {
    if (currentFrame == 10 && currentThrow == 3) {
      return Set<int>.from(List.generate(10, (i) => i + 1));
    }
    final frame = frames[currentFrame - 1];
    Set<int> standing = Set<int>.from(List.generate(10, (i) => i + 1));
    for (var t in frame.throws) {
      standing.removeAll(t.knockedPins);
    }
    return standing;
  }

  @override
  List<Object> get props => [
        frames,
        currentFrame,
        currentThrow,
        currentKnockedPins,
        currentIsFoul,
        cumulativeScores,
      ];
}
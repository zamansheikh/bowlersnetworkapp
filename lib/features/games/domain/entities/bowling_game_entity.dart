// domain/entities/bowling_game_entity.dart (for saving)

import 'package:equatable/equatable.dart';

import 'frame_entity.dart';

class BowlingGameEntity extends Equatable {
  final List<FrameEntity> frames;
  final int totalScore;
  final DateTime date;

  const BowlingGameEntity({
    required this.frames,
    required this.totalScore,
    required this.date,
  });

  @override
  List<Object> get props => [frames, totalScore, date];
}
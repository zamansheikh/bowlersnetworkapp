// domain/entities/bowling_game_entity.dart (for saving)

import 'package:equatable/equatable.dart';

import 'frame_entity.dart';

class BowlingGameEntity extends Equatable {
  final String id;
  final List<FrameEntity> frames;
  final int totalScore;
  final DateTime date;
  final bool isComplete;

  const BowlingGameEntity({
    required this.id,
    required this.frames,
    required this.totalScore,
    required this.date,
    required this.isComplete,
  });

  @override
  List<Object> get props => [id, frames, totalScore, date, isComplete];
}

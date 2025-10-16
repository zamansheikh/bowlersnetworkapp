// domain/entities/bowling_game_entity.dart (for saving)

import 'package:equatable/equatable.dart';

import 'frame_entity.dart';
import 'game_type.dart';
import 'hand_preference.dart';
import 'lane_condition.dart';
import 'oil_pattern.dart';

class BowlingGameEntity extends Equatable {
  final String id;
  final List<FrameEntity> frames;
  final int totalScore;
  final DateTime date;
  final bool isComplete;
  final HandPreference handPreference;
  final OilPattern oilPattern;
  final LaneCondition laneCondition;
  final GameType gameType;
  final String? laneNumber;

  const BowlingGameEntity({
    required this.id,
    required this.frames,
    required this.totalScore,
    required this.date,
    required this.isComplete,
    required this.handPreference,
    required this.oilPattern,
    required this.laneCondition,
    required this.gameType,
    this.laneNumber,
  });

  @override
  List<Object?> get props => [
    id,
    frames,
    totalScore,
    date,
    isComplete,
    handPreference,
    oilPattern,
    laneCondition,
    gameType,
    laneNumber,
  ];
}

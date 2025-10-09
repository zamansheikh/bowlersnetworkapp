import '../../domain/entities/bowling_game_entity.dart';
import '../../domain/entities/frame_entity.dart';
import '../../domain/entities/throw_entity.dart';

class BowlingGameModel {
  final String id;
  final List<FrameModel> frames;
  final int totalScore;
  final DateTime date;
  final bool isComplete;

  BowlingGameModel({
    required this.id,
    required this.frames,
    required this.totalScore,
    required this.date,
    required this.isComplete,
  });

  // Convert from entity
  factory BowlingGameModel.fromEntity(BowlingGameEntity entity) {
    return BowlingGameModel(
      id: entity.id,
      frames: entity.frames.map((f) => FrameModel.fromEntity(f)).toList(),
      totalScore: entity.totalScore,
      date: entity.date,
      isComplete: entity.isComplete,
    );
  }

  // Convert to entity
  BowlingGameEntity toEntity() {
    return BowlingGameEntity(
      id: id,
      frames: frames.map((f) => f.toEntity()).toList(),
      totalScore: totalScore,
      date: date,
      isComplete: isComplete,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'frames': frames.map((f) => f.toJson()).toList(),
      'totalScore': totalScore,
      'date': date.toIso8601String(),
      'isComplete': isComplete,
    };
  }

  factory BowlingGameModel.fromJson(Map<String, dynamic> json) {
    return BowlingGameModel(
      id: json['id'] as String,
      frames: (json['frames'] as List)
          .map((f) => FrameModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      totalScore: json['totalScore'] as int,
      date: DateTime.parse(json['date'] as String),
      isComplete: json['isComplete'] as bool? ?? false,
    );
  }
}

class FrameModel {
  final int number;
  final List<ThrowModel> throws;

  FrameModel({required this.number, required this.throws});

  factory FrameModel.fromEntity(FrameEntity entity) {
    return FrameModel(
      number: entity.number,
      throws: entity.throws.map((t) => ThrowModel.fromEntity(t)).toList(),
    );
  }

  FrameEntity toEntity() {
    return FrameEntity(
      number: number,
      throws: throws.map((t) => t.toEntity()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'number': number, 'throws': throws.map((t) => t.toJson()).toList()};
  }

  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel(
      number: json['number'] as int,
      throws: (json['throws'] as List)
          .map((t) => ThrowModel.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ThrowModel {
  final Set<int> knockedPins;
  final bool isFoul;

  ThrowModel({required this.knockedPins, required this.isFoul});

  factory ThrowModel.fromEntity(ThrowEntity entity) {
    return ThrowModel(knockedPins: entity.knockedPins, isFoul: entity.isFoul);
  }

  ThrowEntity toEntity() {
    return ThrowEntity(knockedPins: knockedPins, isFoul: isFoul);
  }

  Map<String, dynamic> toJson() {
    return {'knockedPins': knockedPins.toList(), 'isFoul': isFoul};
  }

  factory ThrowModel.fromJson(Map<String, dynamic> json) {
    return ThrowModel(
      knockedPins: Set<int>.from(json['knockedPins'] as List),
      isFoul: json['isFoul'] as bool,
    );
  }

  int get pinsKnocked => isFoul ? 0 : knockedPins.length;
}

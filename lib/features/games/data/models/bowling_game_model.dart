import '../../domain/entities/bowling_game_entity.dart';
import '../../domain/entities/frame_entity.dart';
import '../../domain/entities/game_type.dart';
import '../../domain/entities/hand_preference.dart';
import '../../domain/entities/lane_condition.dart';
import '../../domain/entities/oil_pattern.dart';
import '../../domain/entities/throw_entity.dart';

class BowlingGameModel {
  final String id;
  final List<FrameModel> frames;
  final int totalScore;
  final DateTime date;
  final bool isComplete;
  final HandPreference handPreference;
  final OilPattern oilPattern;
  final LaneCondition laneCondition;
  final GameType gameType;
  final String? laneNumber;
  final String? backendId; // Server-assigned ID after sync
  final String syncStatus; // pending_sync, synced
  final DateTime? syncedAt;
  final String? syncError;

  BowlingGameModel({
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
    this.backendId,
    this.syncStatus = 'pending_sync',
    this.syncedAt,
    this.syncError,
  });

  // Convert from entity
  factory BowlingGameModel.fromEntity(BowlingGameEntity entity) {
    return BowlingGameModel(
      id: entity.id,
      frames: entity.frames.map((f) => FrameModel.fromEntity(f)).toList(),
      totalScore: entity.totalScore,
      date: entity.date,
      isComplete: entity.isComplete,
      handPreference: entity.handPreference,
      oilPattern: entity.oilPattern,
      laneCondition: entity.laneCondition,
      gameType: entity.gameType,
      laneNumber: entity.laneNumber,
      syncStatus: 'pending_sync',
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
      handPreference: handPreference,
      oilPattern: oilPattern,
      laneCondition: laneCondition,
      gameType: gameType,
      laneNumber: laneNumber,
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
      'handPreference': handPreference.toJson(),
      'oilPattern': oilPattern.toJson(),
      'laneCondition': laneCondition.toJson(),
      'gameType': gameType.toJson(),
      'laneNumber': laneNumber,
      'backendId': backendId,
      'syncStatus': syncStatus,
      'syncedAt': syncedAt?.toIso8601String(),
      'syncError': syncError,
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
      handPreference: json['handPreference'] != null
          ? HandPreference.fromJson(json['handPreference'] as String)
          : HandPreference.right,
      oilPattern: json['oilPattern'] != null
          ? OilPattern.fromJson(json['oilPattern'] as String)
          : OilPattern.house,
      laneCondition: json['laneCondition'] != null
          ? LaneCondition.fromJson(json['laneCondition'] as String)
          : LaneCondition.medium,
      gameType: json['gameType'] != null
          ? GameType.fromJson(json['gameType'] as String)
          : GameType.practice,
      laneNumber: json['laneNumber'] as String?,
      backendId: json['backendId'] as String?,
      syncStatus: json['syncStatus'] as String? ?? 'pending_sync',
      syncedAt: json['syncedAt'] != null
          ? DateTime.parse(json['syncedAt'] as String)
          : null,
      syncError: json['syncError'] as String?,
    );
  }
}

class FrameModel {
  final int number;
  final List<ThrowModel> throws;
  final bool isPocketHit;

  FrameModel({
    required this.number,
    required this.throws,
    this.isPocketHit = false,
  });

  factory FrameModel.fromEntity(FrameEntity entity) {
    return FrameModel(
      number: entity.number,
      throws: entity.throws.map((t) => ThrowModel.fromEntity(t)).toList(),
      isPocketHit: entity.isPocketHit,
    );
  }

  FrameEntity toEntity() {
    return FrameEntity(
      number: number,
      throws: throws.map((t) => t.toEntity()).toList(),
      isPocketHit: isPocketHit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'throws': throws.map((t) => t.toJson()).toList(),
      'isPocketHit': isPocketHit,
    };
  }

  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel(
      number: json['number'] as int,
      throws: (json['throws'] as List)
          .map((t) => ThrowModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      isPocketHit: json['isPocketHit'] as bool? ?? false,
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

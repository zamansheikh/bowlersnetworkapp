// domain/entities/frame_entity.dart

import 'package:equatable/equatable.dart';

import 'throw_entity.dart';

class FrameEntity extends Equatable {
  final int number;
  final List<ThrowEntity> throws;

  const FrameEntity({
    required this.number,
    this.throws = const [],
  });

  FrameEntity copyWith({
    List<ThrowEntity>? throws,
  }) {
    return FrameEntity(
      number: number,
      throws: throws ?? this.throws,
    );
  }

  String get display {
    if (throws.isEmpty) return '';

    List<String> symbols = throws.map((t) {
      if (t.isFoul) return 'F';
      if (t.pinsKnocked == 0) return '-';
      return '${t.pinsKnocked}';
    }).toList();

    if (number < 10 || throws.length < 3) {
      if (throws.first.pinsKnocked == 10) {
        return 'X';
      }
      if (throws.length >= 2 && throws[0].pinsKnocked + throws[1].pinsKnocked == 10) {
        return '${symbols[0]} /';
      }
    } else {
      // For 10th frame, adjust symbols for X and /
      if (throws[0].pinsKnocked == 10) symbols[0] = 'X';
      if (throws.length >= 2) {
        if (throws[1].pinsKnocked == 10) symbols[1] = 'X';
        if (throws[0].pinsKnocked + throws[1].pinsKnocked == 10 && throws[0].pinsKnocked != 10) {
          symbols[1] = '/';
        }
      }
      if (throws.length >= 3) {
        if (throws[2].pinsKnocked == 10) symbols[2] = 'X';
        if (throws[1].pinsKnocked + throws[2].pinsKnocked == 10 && throws[1].pinsKnocked != 10) {
          symbols[2] = '/';
        }
      }
    }

    return symbols.join(' ');
  }

  @override
  List<Object> get props => [number, throws];
}
import 'package:flutter/material.dart';

import '../../../domain/entities/frame_entity.dart';
import '../../../domain/entities/throw_entity.dart';

class FrameScoreTile extends StatelessWidget {
  const FrameScoreTile({super.key, 
    required this.frame,
    required this.cumulativeScore,
    required this.isActive,
    this.activeThrowIndex,
  });

  final FrameEntity frame;
  final int? cumulativeScore;
  final bool isActive;
  final int? activeThrowIndex;

  @override
  Widget build(BuildContext context) {
    final isTenth = frame.number == 10;
    final slots = isTenth ? 3 : 2;
    final symbols = _frameSymbols(frame);

    final double tileWidth = isTenth ? 48 : 32;
    final Color borderColor = isActive
        ? const Color(0xFF8BC342)
        : const Color(0xFFE5E7EB);

    return Container(
      width: tileWidth,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: isActive ? 2 : 1),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF8BC342).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: List.generate(slots, (index) {
                final isActiveThrow =
                    activeThrowIndex != null && activeThrowIndex == index;
                final cellColor = isActiveThrow
                    ? const Color(0xFF8BC342)
                    : Colors.white;
                final textColor = isActiveThrow
                    ? Colors.white
                    : const Color(0xFF111827);
                return Expanded(
                  child: Container(
                    height: 22,
                    decoration: BoxDecoration(
                      border: Border(
                        right: index == slots - 1
                            ? BorderSide.none
                            : const BorderSide(color: Color(0xFFE3E6F3)),
                        bottom: const BorderSide(color: Color(0xFFE3E6F3)),
                      ),
                      color: cellColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      symbols[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              }),
            ),
            Container(
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(4),
                ),
              ),
              child: Text(
                cumulativeScore != null ? '$cumulativeScore' : '',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isActive
                      ? const Color(0xFF8BC342)
                      : const Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<String> _frameSymbols(FrameEntity frame) {
  final isTenth = frame.number == 10;
  final slots = isTenth ? 3 : 2;
  final result = List.filled(slots, '');
  final throws = frame.throws;

  if (throws.isEmpty) {
    return result;
  }

  final first = throws.first;
  result[0] = _symbolForFirstThrow(first);

  if (!isTenth) {
    if (first.pinsKnocked == 10 && !first.isFoul) {
      return result;
    }

    if (throws.length >= 2) {
      final second = throws[1];
      if (second.isFoul) {
        result[1] = 'F';
      } else if (!first.isFoul &&
          first.pinsKnocked + second.pinsKnocked == 10) {
        result[1] = '/';
      } else if (second.pinsKnocked == 0) {
        result[1] = '-';
      } else {
        result[1] = '${second.pinsKnocked}';
      }
    }

    return result;
  }

  if (throws.length >= 2) {
    final second = throws[1];
    if (second.isFoul) {
      result[1] = 'F';
    } else if (second.pinsKnocked == 10) {
      result[1] = 'X';
    } else if (!first.isFoul &&
        first.pinsKnocked != 10 &&
        first.pinsKnocked + second.pinsKnocked == 10) {
      result[1] = '/';
    } else if (second.pinsKnocked == 0) {
      result[1] = '-';
    } else {
      result[1] = '${second.pinsKnocked}';
    }
  }

  if (throws.length >= 3) {
    final second = throws[1];
    final third = throws[2];
    if (third.isFoul) {
      result[2] = 'F';
    } else if (third.pinsKnocked == 10) {
      result[2] = 'X';
    } else if (!second.isFoul &&
        second.pinsKnocked != 10 &&
        second.pinsKnocked + third.pinsKnocked == 10) {
      result[2] = '/';
    } else if (third.pinsKnocked == 0) {
      result[2] = '-';
    } else {
      result[2] = '${third.pinsKnocked}';
    }
  }

  return result;
}

String _symbolForFirstThrow(ThrowEntity throwEntity) {
  if (throwEntity.isFoul) return 'F';
  if (throwEntity.pinsKnocked == 10) return 'X';
  if (throwEntity.pinsKnocked == 0) return '-';
  return '${throwEntity.pinsKnocked}';
}

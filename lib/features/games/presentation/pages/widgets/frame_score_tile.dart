import 'package:flutter/material.dart';

import '../../../domain/entities/frame_entity.dart';
import '../../../domain/entities/throw_entity.dart';

const Set<int> _fullPinSet = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

// Physical neighbors in a bowling pin rack used to determine split groupings.
const Map<int, List<int>> _pinNeighbors = {
  1: [2, 3, 5],
  2: [1, 3, 4, 5],
  3: [1, 2, 5, 6],
  4: [2, 5, 7, 8],
  5: [1, 2, 3, 4, 6, 8, 9],
  6: [3, 5, 9, 10],
  7: [4, 8],
  8: [4, 5, 7, 9],
  9: [5, 6, 8, 10],
  10: [6, 9],
};

class FrameScoreTile extends StatelessWidget {
  const FrameScoreTile({
    super.key,
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
    final splitIndexes = _splitThrowIndexes(frame);

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
                final bool isSplitThrow = splitIndexes.contains(index);
                final Color textColor = isActiveThrow
                    ? (isSplitThrow ? const Color(0xFFFFE4E6) : Colors.white)
                    : (isSplitThrow
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF111827));
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

Set<int> _splitThrowIndexes(FrameEntity frame) {
  final result = <int>{};
  for (var i = 0; i < frame.throws.length; i++) {
    if (_isSplit(frame, i)) {
      result.add(i);
    }
  }
  return result;
}

bool _isSplit(FrameEntity frame, int throwIndex) {
  if (throwIndex < 0 || throwIndex >= frame.throws.length) {
    return false;
  }

  if (frame.number < 10 && throwIndex != 0) {
    return false; // Only first ball can create a split in frames 1-9.
  }

  if (frame.number == 10 && throwIndex > 1) {
    return false; // No split context after the final ball in the tenth frame.
  }

  final ThrowEntity currentThrow = frame.throws[throwIndex];
  if (currentThrow.isFoul || currentThrow.knockedPins.isEmpty) {
    return false;
  }

  final Set<int> standingBefore = _standingBeforeThrow(
    frame,
    throwIndex,
  ).toSet();
  final Set<int> standingAfter = _applyThrowToStanding(
    standingBefore,
    currentThrow,
  );

  if (standingAfter.length < 2) {
    return false; // Need at least two pins for a split.
  }

  if (standingAfter.contains(1)) {
    return false; // Head pin still standing, not a split.
  }

  final int clusters = _countClusters(standingAfter);
  return clusters > 1;
}

Set<int> _standingBeforeThrow(FrameEntity frame, int throwIndex) {
  var standing = _fullPinSet.toSet();
  if (frame.number < 10) {
    for (var i = 0; i < throwIndex && i < frame.throws.length; i++) {
      standing = _applyThrowToStanding(standing, frame.throws[i]);
    }
    return standing;
  }

  if (throwIndex <= 0) {
    return standing;
  }

  final ThrowEntity first = frame.throws.isNotEmpty
      ? _clipThrow(frame.throws[0], standing)
      : ThrowEntity(knockedPins: <int>{});
  if (throwIndex == 1) {
    return _standingBeforeSecondInTenth(first);
  }

  final ThrowEntity second = frame.throws.length > 1
      ? _clipThrow(frame.throws[1], _standingBeforeSecondInTenth(first))
      : ThrowEntity(knockedPins: <int>{});
  return _standingBeforeThirdInTenth(first, second);
}

Set<int> _applyThrowToStanding(Set<int> standing, ThrowEntity throwEntity) {
  final nextStanding = Set<int>.from(standing);
  if (!throwEntity.isFoul) {
    nextStanding.removeAll(throwEntity.knockedPins);
  }
  return nextStanding;
}

ThrowEntity _clipThrow(ThrowEntity throwEntity, Set<int> standingBefore) {
  if (throwEntity.isFoul) {
    return const ThrowEntity(knockedPins: <int>{}, isFoul: true);
  }
  final clipped = throwEntity.knockedPins
      .where((pin) => standingBefore.contains(pin))
      .toSet();
  return ThrowEntity(knockedPins: clipped, isFoul: false);
}

Set<int> _standingBeforeSecondInTenth(ThrowEntity first) {
  if (!first.isFoul && first.pinsKnocked == 10) {
    return _fullPinSet.toSet();
  }
  return _applyThrowToStanding(_fullPinSet, first);
}

Set<int> _standingBeforeThirdInTenth(ThrowEntity first, ThrowEntity second) {
  if (!first.isFoul && first.pinsKnocked == 10) {
    if (!second.isFoul && second.pinsKnocked == 10) {
      return _fullPinSet.toSet();
    }
    return _applyThrowToStanding(_fullPinSet, second);
  }

  if (!first.isFoul &&
      !second.isFoul &&
      first.pinsKnocked + second.pinsKnocked == 10) {
    return _fullPinSet.toSet();
  }

  final standingBeforeSecond = _standingBeforeSecondInTenth(first);
  return _applyThrowToStanding(standingBeforeSecond, second);
}

int _countClusters(Set<int> pins) {
  final visited = <int>{};
  var clusters = 0;

  for (final pin in pins) {
    if (visited.contains(pin)) continue;
    clusters++;
    final queue = <int>[pin];
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (!visited.add(current)) continue;
      for (final neighbor in _pinNeighbors[current] ?? const <int>[]) {
        if (pins.contains(neighbor) && !visited.contains(neighbor)) {
          queue.add(neighbor);
        }
      }
    }
  }

  return clusters;
}

import '../domain/entities/frame_entity.dart';
import '../domain/entities/throw_entity.dart';

const Set<int> fullPinSet = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};

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

Set<int> fullPinSetCopy() => Set<int>.from(fullPinSet);

ThrowEntity clipToStanding(ThrowEntity throwEntity, Set<int> standingBefore) {
  if (throwEntity.isFoul) {
    return ThrowEntity(knockedPins: <int>{}, isFoul: true);
  }
  final clipped = throwEntity.knockedPins
      .where((pin) => standingBefore.contains(pin))
      .toSet();
  return ThrowEntity(knockedPins: clipped, isFoul: false);
}

Set<int> applyThrowToStanding(Set<int> standing, ThrowEntity throwEntity) {
  final nextStanding = Set<int>.from(standing);
  if (!throwEntity.isFoul) {
    nextStanding.removeAll(throwEntity.knockedPins);
  }
  return nextStanding;
}

Set<int> standingPinsBefore(FrameEntity frame, int throwIndex) {
  var standing = fullPinSetCopy();
  if (frame.number < 10) {
    for (var i = 0; i < throwIndex && i < frame.throws.length; i++) {
      standing = applyThrowToStanding(
        standing,
        clipToStanding(frame.throws[i], standing),
      );
    }
    return standing;
  }

  if (throwIndex <= 0) {
    return standing;
  }

  final first = frame.throws.isNotEmpty
      ? clipToStanding(frame.throws[0], standing)
      : ThrowEntity(knockedPins: <int>{});
  if (throwIndex == 1) {
    return _standingBeforeSecondInTenth(first);
  }

  final second = frame.throws.length > 1
      ? clipToStanding(frame.throws[1], _standingBeforeSecondInTenth(first))
      : ThrowEntity(knockedPins: <int>{});
  return _standingBeforeThirdInTenth(first, second);
}

Set<int> standingPinsAfter(FrameEntity frame, int throwIndex) {
  if (throwIndex < 0 || throwIndex >= frame.throws.length) {
    return fullPinSetCopy();
  }
  final before = standingPinsBefore(frame, throwIndex);
  final clipped = clipToStanding(frame.throws[throwIndex], before);
  return applyThrowToStanding(before, clipped);
}

bool isSplitLeave(FrameEntity frame, int throwIndex) {
  if (throwIndex < 0 || throwIndex >= frame.throws.length) {
    return false;
  }
  if (frame.number < 10 && throwIndex != 0) {
    return false;
  }
  if (frame.number == 10 && throwIndex > 1) {
    return false;
  }

  final throwEntity = frame.throws[throwIndex];
  if (throwEntity.isFoul || throwEntity.knockedPins.isEmpty) {
    return false;
  }

  final standingAfter = standingPinsAfter(frame, throwIndex);
  if (standingAfter.length < 2) {
    return false;
  }
  if (standingAfter.contains(1)) {
    return false;
  }
  return _countClusters(standingAfter) > 1;
}

int _countClusters(Set<int> pins) {
  final visited = <int>{};
  var clusters = 0;

  for (final pin in pins) {
    if (visited.contains(pin)) continue;
    clusters++;
    final stack = <int>[pin];
    while (stack.isNotEmpty) {
      final current = stack.removeLast();
      if (!visited.add(current)) continue;
      for (final neighbor in _pinNeighbors[current] ?? const <int>[]) {
        if (pins.contains(neighbor) && !visited.contains(neighbor)) {
          stack.add(neighbor);
        }
      }
    }
  }

  return clusters;
}

Set<int> _standingBeforeSecondInTenth(ThrowEntity first) {
  if (!first.isFoul && first.pinsKnocked == 10) {
    return fullPinSetCopy();
  }
  return applyThrowToStanding(fullPinSet, first);
}

Set<int> _standingBeforeThirdInTenth(ThrowEntity first, ThrowEntity second) {
  if (!first.isFoul && first.pinsKnocked == 10) {
    if (!second.isFoul && second.pinsKnocked == 10) {
      return fullPinSetCopy();
    }
    return applyThrowToStanding(fullPinSet, second);
  }

  if (!first.isFoul &&
      !second.isFoul &&
      first.pinsKnocked + second.pinsKnocked == 10) {
    return fullPinSetCopy();
  }

  final standingBeforeSecond = _standingBeforeSecondInTenth(first);
  return applyThrowToStanding(standingBeforeSecond, second);
}

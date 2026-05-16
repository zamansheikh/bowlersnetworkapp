/// 10-pin bowling score engine — Dart port of the web's
/// `lib/bowlingScorer.ts`. Pure, side-effect free, no Flutter deps.
///
/// Scoring rules:
///   • 10 frames per game. Frames 1–9: max 2 deliveries. Frame 10: 2 + bonus.
///   • Strike  (X)  = all 10 pins on 1st delivery → 10 + next 2 deliveries
///   • Spare   (/)  = all remaining pins on 2nd delivery → 10 + next 1 delivery
///   • Open frame    = sum of the frame's deliveries (no bonus)
///   • 10th frame: simply sum all deliveries (no carry-forward bonus)
library;

import 'package:equatable/equatable.dart';

/// One delivery — the pins still STANDING after the throw (not the ones
/// knocked down). Matches the backend's `ball_N_pins_standing` shape.
class Delivery extends Equatable {
  const Delivery({this.pinsStanding = const [], this.equipmentId});

  final List<int> pinsStanding;
  final int? equipmentId;

  @override
  List<Object?> get props => [pinsStanding, equipmentId];
}

class FrameInput extends Equatable {
  const FrameInput({this.deliveries = const []});

  final List<Delivery> deliveries;

  FrameInput copyWith({List<Delivery>? deliveries}) =>
      FrameInput(deliveries: deliveries ?? this.deliveries);

  @override
  List<Object?> get props => [deliveries];
}

class FrameResult extends Equatable {
  const FrameResult({
    required this.frameNumber,
    required this.deliveries,
    required this.pinfalls,
    required this.marks,
    required this.isStrike,
    required this.isSpare,
    required this.isOpen,
    this.cumulativeScore,
    this.frameTotal,
  });

  final int frameNumber;
  final List<Delivery> deliveries;

  /// Pins knocked per delivery in this frame.
  final List<int> pinfalls;

  /// Standard notation per delivery (`X`, `/`, `-`, or digit string).
  final List<String> marks;

  final bool isStrike;
  final bool isSpare;
  final bool isOpen;

  /// Running game total at this frame; `null` when bonus is still pending.
  final int? cumulativeScore;

  /// Total for this frame alone; `null` when bonus is still pending.
  final int? frameTotal;

  @override
  List<Object?> get props => [
        frameNumber,
        deliveries,
        pinfalls,
        marks,
        isStrike,
        isSpare,
        isOpen,
        cumulativeScore,
        frameTotal,
      ];
}

class GameScoreResult extends Equatable {
  const GameScoreResult({
    required this.frames,
    required this.totalScore,
    required this.projectedScore,
    required this.isComplete,
  });

  final List<FrameResult> frames;
  final int totalScore;

  /// Maximum possible total if every remaining delivery is a strike.
  final int projectedScore;

  final bool isComplete;

  @override
  List<Object?> get props => [frames, totalScore, projectedScore, isComplete];
}

/// Compute the game from the cursor's current frame state. Always returns
/// 10 [FrameResult]s — unplayed frames have empty pinfalls/marks.
GameScoreResult computeGame(List<FrameInput> frameInputs) {
  final results = <FrameResult>[];

  // ── Pass 1: pinfalls + marks per frame ────────────────────────────────────
  for (var f = 0; f < 10; f++) {
    final input =
        f < frameInputs.length ? frameInputs[f] : const FrameInput();
    final dels = input.deliveries;
    final is10th = f == 9;
    final pinfalls = <int>[];
    final marks = <String>[];

    if (is10th) {
      // 10th frame: up to 3 deliveries. Rack resets after strike or spare.
      var rackSize = 10;
      for (var d = 0; d < dels.length; d++) {
        final standing = dels[d].pinsStanding;
        final k = rackSize - standing.length;
        pinfalls.add(k);

        if (standing.isEmpty) {
          marks.add(rackSize == 10 ? 'X' : '/');
          rackSize = 10;
        } else {
          marks.add(k == 0 ? '-' : '$k');
          rackSize = standing.length;
        }
      }
    } else {
      // Frames 1–9: max 2 deliveries.
      if (dels.isNotEmpty) {
        final standing1 = dels[0].pinsStanding;
        final k1 = 10 - standing1.length;
        pinfalls.add(k1);

        if (standing1.isEmpty) {
          marks.add('X');
        } else {
          marks.add(k1 == 0 ? '-' : '$k1');
          if (dels.length >= 2) {
            final standing2 = dels[1].pinsStanding;
            final k2 = standing1.length - standing2.length;
            pinfalls.add(k2);
            if (standing2.isEmpty) {
              marks.add('/');
            } else {
              marks.add(k2 == 0 ? '-' : '$k2');
            }
          }
        }
      }
    }

    final isStrike = pinfalls.isNotEmpty && marks[0] == 'X';
    final isSpare = !isStrike && marks.contains('/');
    final isFrameDone = is10th
        ? ((isStrike || isSpare) ? dels.length >= 3 : dels.length >= 2)
        : (isStrike || dels.length >= 2);
    final isOpen = isFrameDone && !isStrike && !isSpare;

    results.add(FrameResult(
      frameNumber: f + 1,
      deliveries: dels,
      pinfalls: pinfalls,
      marks: marks,
      isStrike: isStrike,
      isSpare: isSpare,
      isOpen: isOpen,
    ));
  }

  // ── Pass 2: flatten pinfalls for bonus lookups ────────────────────────────
  final allPinfalls = <int>[];
  for (final r in results) {
    allPinfalls.addAll(r.pinfalls);
  }

  int? pf(int idx) => (idx >= 0 && idx < allPinfalls.length)
      ? allPinfalls[idx]
      : null;

  // ── Pass 3: frame totals + cumulative ─────────────────────────────────────
  final scored = <FrameResult>[];
  var cumulative = 0;
  var ballIdx = 0;
  for (var f = 0; f < results.length; f++) {
    final r = results[f];
    if (r.pinfalls.isEmpty) {
      scored.add(r);
      continue;
    }

    int? frameTotal;
    int? cumScore;

    if (f == 9) {
      final sum = r.pinfalls.fold<int>(0, (a, b) => a + b);
      frameTotal = sum;
      cumulative += sum;
      cumScore = cumulative;
      scored.add(_withScore(r, frameTotal, cumScore));
      break;
    }

    if (r.isStrike) {
      final b1 = pf(ballIdx + 1);
      final b2 = pf(ballIdx + 2);
      if (b1 != null && b2 != null) {
        frameTotal = 10 + b1 + b2;
        cumulative += frameTotal;
        cumScore = cumulative;
      }
      ballIdx += 1;
    } else if (r.isSpare) {
      final bonus = pf(ballIdx + 2);
      if (bonus != null) {
        frameTotal = 10 + bonus;
        cumulative += frameTotal;
        cumScore = cumulative;
      }
      ballIdx += 2;
    } else {
      final sum = r.pinfalls.fold<int>(0, (a, b) => a + b);
      frameTotal = sum;
      cumulative += sum;
      cumScore = cumulative;
      ballIdx += r.pinfalls.length;
    }

    scored.add(_withScore(r, frameTotal, cumScore));
  }

  // Final scored list (rebuilt because we mutated via `_withScore`).
  final finalResults = scored;

  final totalScore = finalResults
          .where((r) => r.cumulativeScore != null)
          .map((r) => r.cumulativeScore!)
          .fold<int>(0, (a, b) => b); // last non-null cumulative

  final isComplete = (() {
    if (finalResults.length < 10) return false;
    final f10 = finalResults[9];
    if (f10.deliveries.isEmpty) return false;
    if (f10.isStrike || f10.isSpare) return f10.deliveries.length >= 3;
    return f10.deliveries.length >= 2;
  })();

  final projectedScore = _projectedScore(finalResults, totalScore);

  return GameScoreResult(
    frames: finalResults,
    totalScore: totalScore,
    projectedScore: projectedScore,
    isComplete: isComplete,
  );
}

FrameResult _withScore(FrameResult r, int? frameTotal, int? cumScore) =>
    FrameResult(
      frameNumber: r.frameNumber,
      deliveries: r.deliveries,
      pinfalls: r.pinfalls,
      marks: r.marks,
      isStrike: r.isStrike,
      isSpare: r.isSpare,
      isOpen: r.isOpen,
      frameTotal: frameTotal,
      cumulativeScore: cumScore,
    );

/// Max possible total if every remaining delivery is a strike.
int _projectedScore(List<FrameResult> results, int currentTotal) {
  final completed = results.where((r) => r.cumulativeScore != null).length;
  if (completed == 0) return 300;
  if (completed >= 10) return currentTotal;

  final simFrames = <FrameInput>[];
  for (var i = 0; i < results.length; i++) {
    final r = results[i];
    if (i < completed && r.deliveries.isNotEmpty) {
      simFrames.add(FrameInput(deliveries: List<Delivery>.from(r.deliveries)));
    } else if (i == 9) {
      simFrames.add(const FrameInput(deliveries: [
        Delivery(pinsStanding: []),
        Delivery(pinsStanding: []),
        Delivery(pinsStanding: []),
      ]));
    } else {
      simFrames.add(const FrameInput(deliveries: [Delivery(pinsStanding: [])]));
    }
  }

  // If a frame has one delivery with pins still standing, simulate the
  // optimistic 2nd ball as a spare (clear remaining).
  for (var i = 0; i < 9; i++) {
    final f = simFrames[i];
    if (f.deliveries.length == 1 &&
        f.deliveries[0].pinsStanding.isNotEmpty) {
      simFrames[i] = FrameInput(
        deliveries: [...f.deliveries, const Delivery(pinsStanding: [])],
      );
    }
  }

  return computeGame(simFrames).totalScore;
}

/// All 10 pin numbers. Useful for "all standing" defaults.
const allPins = <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

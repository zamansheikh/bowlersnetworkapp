import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/frame_entity.dart';
import '../../domain/entities/throw_entity.dart';
import '../../domain/repositories/game_repository.dart';
import '../../utils/bowling_pin_utils.dart';
import 'widgets/frame_score_tile.dart';

class GameAnalyticsPage extends StatelessWidget {
  final String gameId;

  const GameAnalyticsPage({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<GameRepository>().getGameById(gameId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingAnalytics();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const _ErrorAnalytics();
        }

        return snapshot.data!.fold(
          (failure) => const _ErrorAnalytics(),
          (game) => _GameAnalyticsView(game: game),
        );
      },
    );
  }
}

class _LoadingAnalytics extends StatelessWidget {
  const _LoadingAnalytics();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Analytics'),
        backgroundColor: const Color(0xFF8BC342),
        foregroundColor: Colors.white,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorAnalytics extends StatelessWidget {
  const _ErrorAnalytics();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Analytics'),
        backgroundColor: const Color(0xFF8BC342),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load game'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameAnalyticsView extends StatelessWidget {
  const _GameAnalyticsView({required this.game});

  final dynamic game;

  @override
  Widget build(BuildContext context) {
    final frames = (game.frames as List<FrameEntity>).toList();
    final stats = _calculateStats(frames);
    final cumulativeScores = _buildCumulativeScores(frames);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Analytics'),
        backgroundColor: const Color(0xFF8BC342),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ScoreSummaryCard(
              totalScore: game.totalScore as int,
              completed: (game.isComplete as bool?) ?? true,
              framesCompleted: stats.completedFrames,
            ),
            const SizedBox(height: 24),
            const _SectionHeading(title: 'Key Stats'),
            const SizedBox(height: 12),
            _PrimaryStatsGrid(stats: stats),
            const SizedBox(height: 24),
            const _SectionHeading(title: 'Conversion Breakdown'),
            const SizedBox(height: 12),
            _ConversionBreakdown(stats: stats),
            const SizedBox(height: 24),
            const _SectionHeading(title: 'Spare Attempts'),
            const SizedBox(height: 12),
            _SpareAttemptsSection(frames: frames),
            const SizedBox(height: 24),
            const _SectionHeading(title: 'Frame by Frame'),
            const SizedBox(height: 12),
            _AnalyticsScoreboard(
              frames: frames,
              cumulativeScores: cumulativeScores,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreSummaryCard extends StatelessWidget {
  const _ScoreSummaryCard({
    required this.totalScore,
    required this.completed,
    required this.framesCompleted,
  });

  final int totalScore;
  final bool completed;
  final int framesCompleted;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8BC342), Color(0xFF5A8B22)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Score',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$totalScore',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _summaryChip(
                  icon: Icons.timeline,
                  label: 'Frames Scored',
                  value: '$framesCompleted/10',
                ),
                if (!completed)
                  _summaryChip(
                    icon: Icons.warning_amber_rounded,
                    label: 'Status',
                    value: 'Incomplete game',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF111827),
      ),
    );
  }
}

class _PrimaryStatsGrid extends StatelessWidget {
  const _PrimaryStatsGrid({required this.stats});

  final _AnalyticsStats stats;

  @override
  Widget build(BuildContext context) {
    final tiles = <_PrimaryStatData>[
      _PrimaryStatData(
        label: 'Strikes',
        value: '${stats.strikes}',
        helper: 'Total strikes',
        icon: Icons.flash_on,
        accent: const Color(0xFF3CB371),
      ),
      _PrimaryStatData(
        label: 'Spares',
        value: '${stats.spares}',
        helper: 'Converted spares',
        icon: Icons.sports_baseball,
        accent: const Color(0xFF1D4ED8),
      ),
      _PrimaryStatData(
        label: 'Opens',
        value: '${stats.opens}',
        helper: 'Frames left open',
        icon: Icons.remove_circle_outline,
        accent: const Color(0xFFF59E0B),
      ),
      _PrimaryStatData(
        label: 'First Ball Avg',
        value: stats.firstBallAverage.toStringAsFixed(2),
        helper: 'Pins per first shot',
        icon: Icons.align_vertical_top,
        accent: const Color(0xFF7C3AED),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final bool singleColumn = maxWidth < 520;
        final double tileWidth = singleColumn ? maxWidth : (maxWidth - 16) / 2;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: tiles
              .map(
                (data) => SizedBox(
                  width: tileWidth,
                  child: _PrimaryStatTile(data: data),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _PrimaryStatData {
  const _PrimaryStatData({
    required this.label,
    required this.value,
    required this.helper,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String helper;
  final IconData icon;
  final Color accent;
}

class _PrimaryStatTile extends StatelessWidget {
  const _PrimaryStatTile({required this.data});

  final _PrimaryStatData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: data.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, color: data.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.helper,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversionBreakdown extends StatelessWidget {
  const _ConversionBreakdown({required this.stats});

  final _AnalyticsStats stats;

  @override
  Widget build(BuildContext context) {
    final items = <_ConversionStatData>[
      _ConversionStatData(
        label: 'Strike %',
        value: stats.strikePercentageString,
        helper: 'Strike rate across frames',
      ),
      _ConversionStatData(
        label: 'Spare %',
        value: stats.sparePercentageString,
        helper: 'Converted after first throw',
      ),
      _ConversionStatData(
        label: 'Makeable Spare %',
        value: stats.makeableSpareConversionString,
        helper: 'Excludes splits & washouts',
      ),
      _ConversionStatData(
        label: 'Split Conversion %',
        value: stats.splitConversionString,
        helper: 'Converted marked splits',
      ),
      _ConversionStatData(
        label: 'Single Pin %',
        value: stats.singlePinConversionString,
        helper: 'Single-pin leave conversions',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final bool singleColumn = maxWidth < 520;
        final double tileWidth = singleColumn ? maxWidth : (maxWidth - 16) / 2;

        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              children: items
                  .map(
                    (item) => SizedBox(
                      width: tileWidth,
                      child: _ConversionStatTile(data: item),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }
}

class _ConversionStatData {
  const _ConversionStatData({
    required this.label,
    required this.value,
    required this.helper,
  });

  final String label;
  final String value;
  final String helper;
}

class _ConversionStatTile extends StatelessWidget {
  const _ConversionStatTile({required this.data});

  final _ConversionStatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.helper,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsScoreboard extends StatelessWidget {
  const _AnalyticsScoreboard({
    required this.frames,
    required this.cumulativeScores,
  });

  final List<FrameEntity> frames;
  final List<int> cumulativeScores;

  @override
  Widget build(BuildContext context) {
    final frameMap = {for (final frame in frames) frame.number: frame};
    final orderedFrames = List.generate(
      10,
      (index) => frameMap[index + 1] ?? FrameEntity(number: index + 1),
    );

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: List.generate(orderedFrames.length, (index) {
              final frame = orderedFrames[index];
              final cumulative = index < cumulativeScores.length
                  ? cumulativeScores[index]
                  : null;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FrameScoreTile(
                  frame: frame,
                  cumulativeScore: cumulative,
                  isActive: false,
                  activeThrowIndex: null,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _SpareAttemptsSection extends StatelessWidget {
  const _SpareAttemptsSection({required this.frames});

  final List<FrameEntity> frames;

  @override
  Widget build(BuildContext context) {
    final spareAttempts = _groupSpareAttempts(frames);

    if (spareAttempts.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No spare opportunities in this game',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: spareAttempts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final attempt = spareAttempts[index];
          return _SpareAttemptTile(attempt: attempt);
        },
      ),
    );
  }

  List<_SpareAttemptGroup> _groupSpareAttempts(List<FrameEntity> frames) {
    final Map<String, _SpareAttemptGroup> groups = {};

    for (final frame in frames) {
      if (frame.throws.isEmpty) continue;

      final first = frame.throws.first;

      // Skip strikes
      if (!first.isFoul && first.pinsKnocked == 10) continue;

      // Skip if no second throw opportunity
      if (frame.throws.length < 2) continue;

      final pinsLeft = standingPinsAfter(frame, 0);
      if (pinsLeft.isEmpty) continue;

      // Create a key based on the pin configuration
      final key = pinsLeft.toList()..sort();
      final keyString = key.join(',');

      final second = frame.throws[1];
      final converted =
          !first.isFoul &&
          !second.isFoul &&
          first.pinsKnocked + second.pinsKnocked == 10;

      if (!groups.containsKey(keyString)) {
        groups[keyString] = _SpareAttemptGroup(
          pinsLeft: pinsLeft,
          attempts: [],
        );
      }

      groups[keyString]!.attempts.add(
        _SpareAttempt(
          frameNumber: frame.number,
          converted: converted,
          isSplit: isSplitLeave(frame, 0),
        ),
      );
    }

    // Sort by number of pins remaining (ascending)
    final result = groups.values.toList()
      ..sort((a, b) => a.pinsLeft.length.compareTo(b.pinsLeft.length));

    return result;
  }
}

class _SpareAttemptGroup {
  final Set<int> pinsLeft;
  final List<_SpareAttempt> attempts;

  _SpareAttemptGroup({required this.pinsLeft, required this.attempts});

  int get converted => attempts.where((a) => a.converted).length;
  int get total => attempts.length;
  double get percentage => total == 0 ? 0 : (converted / total) * 100;
}

class _SpareAttempt {
  final int frameNumber;
  final bool converted;
  final bool isSplit;

  _SpareAttempt({
    required this.frameNumber,
    required this.converted,
    required this.isSplit,
  });
}

class _SpareAttemptTile extends StatelessWidget {
  const _SpareAttemptTile({required this.attempt});

  final _SpareAttemptGroup attempt;

  @override
  Widget build(BuildContext context) {
    final percentage = attempt.percentage.toStringAsFixed(0);
    final hasSplit = attempt.attempts.any((a) => a.isSplit);

    return InkWell(
      onTap: () {
        // Could show detailed breakdown in a dialog
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Pin visualization
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: _buildPinVisualization(attempt.pinsLeft)),
            ),
            const SizedBox(width: 16),
            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$percentage% (${attempt.converted}/${attempt.total})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      if (hasSplit) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFDC2626,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SPLIT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${attempt.pinsLeft.length} ${attempt.pinsLeft.length == 1 ? 'pin' : 'pins'} left',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildPinVisualization(Set<int> pinsLeft) {
    // Simplified pin visualization showing which pins are standing
    return CustomPaint(
      size: const Size(40, 40),
      painter: _PinPainter(pinsLeft: pinsLeft),
    );
  }
}

class _PinPainter extends CustomPainter {
  _PinPainter({required this.pinsLeft});

  final Set<int> pinsLeft;

  // Standard bowling pin positions (normalized to 0-1 scale)
  static const Map<int, Offset> pinPositions = {
    7: Offset(0.25, 0.15),
    8: Offset(0.5, 0.15),
    9: Offset(0.75, 0.15),
    4: Offset(0.33, 0.4),
    5: Offset(0.5, 0.4),
    6: Offset(0.67, 0.4),
    2: Offset(0.42, 0.65),
    3: Offset(0.58, 0.65),
    1: Offset(0.5, 0.9),
    10: Offset(0.95, 0.15), // Typically pin 10 not used in standard triangle
  };

  @override
  void paint(Canvas canvas, Size size) {
    final standingPaint = Paint()
      ..color = const Color(0xFF8BC342)
      ..style = PaintingStyle.fill;

    final knockedPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..style = PaintingStyle.fill;

    for (int pin = 1; pin <= 10; pin++) {
      final pos = pinPositions[pin];
      if (pos == null) continue;

      final center = Offset(pos.dx * size.width, pos.dy * size.height);
      final paint = pinsLeft.contains(pin) ? standingPaint : knockedPaint;

      canvas.drawCircle(center, 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) {
    return oldDelegate.pinsLeft != pinsLeft;
  }
}

class _AnalyticsStats {
  const _AnalyticsStats({
    required this.strikes,
    required this.spares,
    required this.opens,
    required this.totalFrames,
    required this.firstBallPins,
    required this.firstBallAttempts,
    required this.makeableLeaves,
    required this.makeableConverted,
    required this.splitLeaves,
    required this.splitConverted,
    required this.singlePinLeaves,
    required this.singlePinConverted,
  });

  final int strikes;
  final int spares;
  final int opens;
  final int totalFrames;
  final int firstBallPins;
  final int firstBallAttempts;
  final int makeableLeaves;
  final int makeableConverted;
  final int splitLeaves;
  final int splitConverted;
  final int singlePinLeaves;
  final int singlePinConverted;

  int get completedFrames => totalFrames;

  double get firstBallAverage =>
      firstBallAttempts == 0 ? 0 : firstBallPins / firstBallAttempts;

  String get strikePercentageString => _percentage(strikes, totalFrames);

  String get sparePercentageString =>
      _percentage(spares, totalFrames - strikes);

  String get makeableSpareConversionString =>
      _percentage(makeableConverted, makeableLeaves);

  String get splitConversionString => _percentage(splitConverted, splitLeaves);

  String get singlePinConversionString =>
      _percentage(singlePinConverted, singlePinLeaves);

  String _percentage(int made, int attempts) {
    if (attempts <= 0) return '—';
    final value = (made / attempts) * 100;
    return '${value.toStringAsFixed(1)}%';
  }
}

_AnalyticsStats _calculateStats(List<FrameEntity> frames) {
  var strikes = 0;
  var spares = 0;
  var opens = 0;
  var totalFrames = 0;
  var firstBallPins = 0;
  var firstBallAttempts = 0;
  var makeableLeaves = 0;
  var makeableConverted = 0;
  var splitLeaves = 0;
  var splitConverted = 0;
  var singlePinLeaves = 0;
  var singlePinConverted = 0;

  for (final frame in frames) {
    if (frame.number < 1 || frame.number > 10) {
      continue;
    }

    totalFrames++;

    if (frame.throws.isEmpty) {
      continue;
    }

    final ThrowEntity first = frame.throws.first;
    firstBallAttempts++;
    firstBallPins += first.pinsKnocked;

    final bool isStrike = !first.isFoul && first.pinsKnocked == 10;
    if (isStrike) {
      strikes++;
      if (frame.number == 10) {
        if (frame.throws.length >= 2) {
          final ThrowEntity second = frame.throws[1];
          if (!second.isFoul && second.pinsKnocked == 10) {
            strikes++;
          }
          if (frame.throws.length >= 3) {
            final ThrowEntity third = frame.throws[2];
            if (!third.isFoul && third.pinsKnocked == 10) {
              strikes++;
            }
          }
        }
      }
      continue;
    }

    if (frame.throws.length < 2) {
      opens++;
      continue;
    }

    final ThrowEntity second = frame.throws[1];
    final int combined = first.pinsKnocked + second.pinsKnocked;
    final bool isSpare =
        !first.isFoul &&
        !second.isFoul &&
        combined == 10 &&
        first.pinsKnocked != 10;
    if (isSpare) {
      spares++;
    } else {
      opens++;
    }

    final Set<int> leaveAfterFirst = standingPinsAfter(
      frame,
      0,
    ); // After first ball in frame

    if (leaveAfterFirst.length == 1) {
      singlePinLeaves++;
      if (isSpare) {
        singlePinConverted++;
      }
    }

    if (isSplitLeave(frame, 0)) {
      splitLeaves++;
      if (isSpare) {
        splitConverted++;
      }
    } else if (leaveAfterFirst.isNotEmpty) {
      makeableLeaves++;
      if (isSpare) {
        makeableConverted++;
      }
    }

    if (frame.number == 10 && isSpare && frame.throws.length >= 3) {
      final ThrowEntity third = frame.throws[2];
      if (!third.isFoul && third.pinsKnocked == 10) {
        strikes++;
      }
    }
  }

  return _AnalyticsStats(
    strikes: strikes,
    spares: spares,
    opens: opens,
    totalFrames: totalFrames,
    firstBallPins: firstBallPins,
    firstBallAttempts: firstBallAttempts,
    makeableLeaves: makeableLeaves,
    makeableConverted: makeableConverted,
    splitLeaves: splitLeaves,
    splitConverted: splitConverted,
    singlePinLeaves: singlePinLeaves,
    singlePinConverted: singlePinConverted,
  );
}

List<int> _buildCumulativeScores(List<FrameEntity> frames) {
  final orderedFrames = List<FrameEntity>.from(frames)
    ..sort((a, b) => a.number.compareTo(b.number));
  final limitedFrames = orderedFrames
      .where((frame) => frame.number >= 1 && frame.number <= 10)
      .toList();

  final cumulatives = <int>[];
  var runningTotal = 0;

  for (var i = 0; i < limitedFrames.length; i++) {
    final frameScore = _frameScoreAt(limitedFrames, i);
    if (frameScore == null) {
      break;
    }
    runningTotal += frameScore;
    cumulatives.add(runningTotal);
  }

  return cumulatives;
}

int? _frameScoreAt(List<FrameEntity> frames, int index) {
  final frame = frames[index];
  if (frame.throws.isEmpty) {
    return null;
  }

  final bool isTenth = frame.number == 10;
  final ThrowEntity first = frame.throws[0];
  final int firstPins = first.pinsKnocked;
  final bool firstStrike = !first.isFoul && firstPins == 10;

  if (isTenth) {
    if (frame.throws.length < 2) {
      return null;
    }
    final ThrowEntity second = frame.throws[1];
    final int secondPins = second.pinsKnocked;
    final bool needsFillBall =
        firstStrike ||
        (!first.isFoul && !second.isFoul && firstPins + secondPins == 10);
    if (needsFillBall && frame.throws.length < 3) {
      return null;
    }
    final Iterable<ThrowEntity> scoredThrows = needsFillBall
        ? frame.throws.take(3)
        : frame.throws.take(2);
    return scoredThrows.fold<int>(
      0,
      (sum, throwEntity) => sum + throwEntity.pinsKnocked,
    );
  }

  if (firstStrike) {
    final bonus = _nextPins(frames, index + 1, 2);
    if (bonus.length < 2) {
      return null;
    }
    return 10 + bonus[0] + bonus[1];
  }

  if (frame.throws.length < 2) {
    return null;
  }

  final ThrowEntity second = frame.throws[1];
  final int framePins = firstPins + second.pinsKnocked;
  final bool isSpare =
      !first.isFoul && !second.isFoul && firstPins != 10 && framePins == 10;

  if (isSpare) {
    final bonus = _nextPins(frames, index + 1, 1);
    if (bonus.isEmpty) {
      return null;
    }
    return 10 + bonus.first;
  }

  return framePins;
}

List<int> _nextPins(List<FrameEntity> frames, int startFrame, int count) {
  final values = <int>[];
  for (var i = startFrame; i < frames.length; i++) {
    for (final throwEntity in frames[i].throws) {
      values.add(throwEntity.pinsKnocked);
      if (values.length == count) {
        return values;
      }
    }
  }
  return values;
}

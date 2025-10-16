import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/bowling_game_entity.dart';
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

class _GameAnalyticsView extends StatefulWidget {
  const _GameAnalyticsView({required this.game});

  final dynamic game;

  @override
  State<_GameAnalyticsView> createState() => _GameAnalyticsViewState();
}

class _GameAnalyticsViewState extends State<_GameAnalyticsView> {
  int _selectedTab = 0; // 0: Overview, 1: Details, 2: Frames

  @override
  Widget build(BuildContext context) {
    final frames = (widget.game.frames as List<FrameEntity>).toList();
    final stats = _calculateStats(frames);
    final cumulativeScores = _buildCumulativeScores(frames);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Analytics'),
        backgroundColor: const Color(0xFF8BC342),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Quick Tab Navigation
          Container(
            color: const Color(0xFF8BC342).withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _TabButton(
                  label: 'Overview',
                  isActive: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                  icon: Icons.dashboard,
                ),
                const SizedBox(width: 12),
                _TabButton(
                  label: 'Details',
                  isActive: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                  icon: Icons.bar_chart,
                ),
                const SizedBox(width: 12),
                _TabButton(
                  label: 'Frames',
                  isActive: _selectedTab == 2,
                  onTap: () => setState(() => _selectedTab = 2),
                  icon: Icons.apps,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedTab == 0) ...[
                    // Overview Tab
                    _OverviewTab(
                      game: widget.game,
                      stats: stats,
                      frames: frames,
                    ),
                  ] else if (_selectedTab == 1) ...[
                    // Details Tab
                    _DetailsTab(stats: stats, frames: frames),
                  ] else ...[
                    // Frames Tab
                    _FramesTab(
                      frames: frames,
                      cumulativeScores: cumulativeScores,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// === Tab Button ===
class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF8BC342) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isActive ? Colors.white : const Color(0xFF8BC342),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : const Color(0xFF8BC342),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// === Overview Tab ===
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.game,
    required this.stats,
    required this.frames,
  });

  final dynamic game;
  final _AnalyticsStats stats;
  final List<FrameEntity> frames;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScoreSummaryCard(
          totalScore: game.totalScore as int,
          completed: (game.isComplete as bool?) ?? true,
          framesCompleted: stats.completedFrames,
        ),
        const SizedBox(height: 24),
        _EnvironmentSection(game: game),
        const SizedBox(height: 24),
        _GameTypeIndicator(game: game),
        const SizedBox(height: 24),
        const _SectionHeading(title: 'Performance Snapshot'),
        const SizedBox(height: 12),
        _QuickStatsRow(stats: stats),
        const SizedBox(height: 24),
        const _SectionHeading(title: 'Conversion Rate'),
        const SizedBox(height: 12),
        _ConversionBreakdown(stats: stats),
      ],
    );
  }
}

// === Details Tab ===
class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.stats, required this.frames});

  final _AnalyticsStats stats;
  final List<FrameEntity> frames;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Detailed Statistics'),
        const SizedBox(height: 12),
        _PrimaryStatsGrid(stats: stats),
        const SizedBox(height: 24),
        const _SectionHeading(title: 'Consistency Analysis'),
        const SizedBox(height: 12),
        _ConsistencySection(stats: stats),
        const SizedBox(height: 24),
        const _SectionHeading(title: 'Spare Attempts Analysis'),
        const SizedBox(height: 12),
        _SpareAttemptsSection(frames: frames),
      ],
    );
  }
}

// === Frames Tab ===
class _FramesTab extends StatelessWidget {
  const _FramesTab({required this.frames, required this.cumulativeScores});

  final List<FrameEntity> frames;
  final List<int> cumulativeScores;

  @override
  Widget build(BuildContext context) {
    final movingAverage = _buildMovingAverage(frames);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(title: 'Score Trend'),
        const SizedBox(height: 12),
        _ScoreTrendCard(frameScores: frames, movingAverage: movingAverage),
        const SizedBox(height: 24),
        const _SectionHeading(title: 'Frame-by-Frame Breakdown'),
        const SizedBox(height: 12),
        _AnalyticsScoreboard(
          frames: frames,
          cumulativeScores: cumulativeScores,
        ),
      ],
    );
  }
}

// === Quick Stats Row (compact horizontal view) ===
class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.stats});

  final _AnalyticsStats stats;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _QuickStatCard(
            icon: Icons.flash_on,
            label: 'Strikes',
            value: '${stats.strikes}',
            color: const Color(0xFF3CB371),
          ),
          const SizedBox(width: 12),
          _QuickStatCard(
            icon: Icons.sports_baseball,
            label: 'Spares',
            value: '${stats.spares}',
            color: const Color(0xFF1D4ED8),
          ),
          const SizedBox(width: 12),
          _QuickStatCard(
            icon: Icons.remove_circle_outline,
            label: 'Opens',
            value: '${stats.opens}',
            color: const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 12),
          _QuickStatCard(
            icon: Icons.trending_up,
            label: 'Avg (1st)',
            value: stats.firstBallAverage.toStringAsFixed(1),
            color: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// === Score Trend Card ===
class _ScoreTrendCard extends StatelessWidget {
  const _ScoreTrendCard({
    required this.frameScores,
    required this.movingAverage,
  });

  final List<FrameEntity> frameScores;
  final List<double> movingAverage;

  @override
  Widget build(BuildContext context) {
    final orderedFrames = List<FrameEntity>.from(frameScores)
      ..sort((a, b) => a.number.compareTo(b.number));
    final limitedFrames = orderedFrames
        .where((frame) => frame.number >= 1 && frame.number <= 10)
        .toList();

    final frameScoresInt = <int>[];
    for (var i = 0; i < limitedFrames.length; i++) {
      final score = _frameScoreAt(limitedFrames, i);
      if (score != null) {
        frameScoresInt.add(score);
      }
    }

    if (frameScoresInt.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Insufficient data for trend analysis'),
        ),
      );
    }

    final maxScore = frameScoresInt.reduce((a, b) => a > b ? a : b);
    final minScore = frameScoresInt.reduce((a, b) => a < b ? a : b);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Frame Score Trend',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3-Frame Moving Average',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Frames: ${frameScoresInt.length}/10',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Mini graph representation
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(frameScoresInt.length, (index) {
                final score = frameScoresInt[index];
                final normalized =
                    (score - minScore) / (maxScore - minScore + 1).toDouble();
                final barHeight = normalized * 60;

                // Determine color based on moving average trend
                Color barColor = Colors.white;
                if (index < movingAverage.length) {
                  if (score > movingAverage[index] + 5) {
                    barColor = const Color(0xFF10B981); // Green - above trend
                  } else if (score < movingAverage[index] - 5) {
                    barColor = const Color(0xFFF87171); // Red - below trend
                  }
                }

                return Tooltip(
                  message: 'Frame ${index + 1}: $score pins',
                  child: Container(
                    width: 20,
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TrendLegend(
                color: const Color(0xFF10B981),
                label: 'Above Trend',
              ),
              const SizedBox(width: 20),
              _TrendLegend(color: Colors.white, label: 'On Trend'),
              const SizedBox(width: 20),
              _TrendLegend(
                color: const Color(0xFFF87171),
                label: 'Below Trend',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendLegend extends StatelessWidget {
  const _TrendLegend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8BC342), Color(0xFF5A8B22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8BC342).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Score',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalScore',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ],
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$framesCompleted',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      'of 10',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: framesCompleted / 10,
                        minHeight: 4,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(
                          Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (!completed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Game in progress',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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

    return Column(
      children: tiles
          .map(
            (data) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PrimaryStatTile(data: data),
            ),
          )
          .toList(),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            data.accent.withValues(alpha: 0.1),
            data.accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.accent.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: data.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.accent, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: data.accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.helper,
                  style: TextStyle(
                    fontSize: 11,
                    color: data.accent.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data.value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: data.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// === Consistency Section ===
class _ConsistencySection extends StatelessWidget {
  const _ConsistencySection({required this.stats});

  final _AnalyticsStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stdDev = stats.scoreStandardDeviation;
    final avgScore = stats.frameScores.isEmpty
        ? 0
        : stats.frameScores.reduce((a, b) => a + b) / stats.frameScores.length;

    // Consistency rating based on std dev
    String getConsistencyRating() {
      if (stdDev < 15) return 'Excellent';
      if (stdDev < 25) return 'Very Good';
      if (stdDev < 35) return 'Good';
      if (stdDev < 50) return 'Average';
      return 'Variable';
    }

    Color getConsistencyColor() {
      if (stdDev < 15) return const Color(0xFF10B981);
      if (stdDev < 25) return const Color(0xFF3B82F6);
      if (stdDev < 35) return const Color(0xFFF59E0B);
      if (stdDev < 50) return const Color(0xFFF97316);
      return const Color(0xFFEF4444);
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Standard Deviation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Score Consistency',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getConsistencyRating(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: getConsistencyColor(),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: getConsistencyColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Std Dev:\n${stdDev.toStringAsFixed(1)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: getConsistencyColor(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pocket Hits
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pocket Hits',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${stats.pocketHits} / ${stats.totalFrames}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF3CB371).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  stats.pocketHitPercentageString,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3CB371),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Average Frame Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Average Frame Score',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    avgScore.toStringAsFixed(1),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF7C3AED),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
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
        helper: 'Strike rate',
        percentage: _parsePercentage(stats.strikePercentageString),
        color: const Color(0xFF10B981),
        icon: Icons.flash_on,
      ),
      _ConversionStatData(
        label: 'Spare %',
        value: stats.sparePercentageString,
        helper: 'After first throw',
        percentage: _parsePercentage(stats.sparePercentageString),
        color: const Color(0xFF3B82F6),
        icon: Icons.sports_baseball,
      ),
      _ConversionStatData(
        label: 'Makeable %',
        value: stats.makeableSpareConversionString,
        helper: 'Excl. splits',
        percentage: _parsePercentage(stats.makeableSpareConversionString),
        color: const Color(0xFF8B5CF6),
        icon: Icons.check_circle,
      ),
      _ConversionStatData(
        label: 'Split %',
        value: stats.splitConversionString,
        helper: 'Marked splits',
        percentage: _parsePercentage(stats.splitConversionString),
        color: const Color(0xFFEC4899),
        icon: Icons.splitscreen,
      ),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ConversionStatTile(data: item),
            ),
          )
          .toList(),
    );
  }
}

double _parsePercentage(String value) {
  final numStr = value.replaceAll('%', '').trim();
  final num = double.tryParse(numStr) ?? 0;
  return (num / 100).clamp(0, 1);
}

class _ConversionStatData {
  const _ConversionStatData({
    required this.label,
    required this.value,
    required this.helper,
    required this.percentage,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String helper;
  final double percentage;
  final Color color;
  final IconData icon;
}

class _ConversionStatTile extends StatelessWidget {
  const _ConversionStatTile({required this.data});

  final _ConversionStatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            data.color.withValues(alpha: 0.08),
            data.color.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.color.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(data.icon, color: data.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: data.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.helper,
                      style: TextStyle(
                        fontSize: 11,
                        color: data.color.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                data.value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: data.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.percentage,
              minHeight: 6,
              backgroundColor: data.color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(data.color),
            ),
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8BC342).withValues(alpha: 0.08),
            const Color(0xFF8BC342).withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8BC342).withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(orderedFrames.length, (index) {
            final frame = orderedFrames[index];
            final cumulative = index < cumulativeScores.length
                ? cumulativeScores[index]
                : null;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
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
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'No spare opportunities in this game',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: spareAttempts
          .map(
            (attempt) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SpareAttemptTile(attempt: attempt),
            ),
          )
          .toList(),
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
    final percentage = attempt.percentage;
    final hasSplit = attempt.attempts.any((a) => a.isSplit);
    final successColor = percentage > 75
        ? const Color(0xFF10B981)
        : percentage > 50
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            successColor.withValues(alpha: 0.08),
            successColor.withValues(alpha: 0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: successColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Pin visualization
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: successColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: successColor.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Center(
                  child: _buildPinVisualization(attempt.pinsLeft, successColor),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${attempt.pinsLeft.length} ${attempt.pinsLeft.length == 1 ? 'Pin' : 'Pins'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: successColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Left standing',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: successColor.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hasSplit) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFDC2626,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
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
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: successColor,
                    ),
                  ),
                  Text(
                    '${attempt.converted}/${attempt.total}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: successColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: attempt.percentage / 100,
              minHeight: 5,
              backgroundColor: successColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(successColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinVisualization(Set<int> pinsLeft, Color successColor) {
    // Simplified pin visualization showing which pins are standing
    return CustomPaint(
      size: const Size(48, 48),
      painter: _PinPainter(pinsLeft: pinsLeft, pinColor: successColor),
    );
  }
}

class _PinPainter extends CustomPainter {
  _PinPainter({required this.pinsLeft, required this.pinColor});

  final Set<int> pinsLeft;
  final Color pinColor;

  // Standard bowling pin positions (normalized, properly centered)
  // Pin layout (standard 10-pin):
  //       7  8  9  10
  //        4  5  6
  //         2  3
  //          1
  static const Map<int, Offset> pinPositions = {
    // Back row (4 pins)
    7: Offset(0.20, 0.15),
    8: Offset(0.40, 0.15),
    9: Offset(0.60, 0.15),
    10: Offset(0.80, 0.15),
    // Third row (3 pins)
    4: Offset(0.30, 0.40),
    5: Offset(0.50, 0.40),
    6: Offset(0.70, 0.40),
    // Second row (2 pins)
    2: Offset(0.40, 0.65),
    3: Offset(0.60, 0.65),
    // Front pin
    1: Offset(0.50, 0.85),
  };

  @override
  void paint(Canvas canvas, Size size) {
    // Standing pins: Use the dynamic color with full opacity
    final standingPaint = Paint()
      ..color = pinColor
      ..style = PaintingStyle.fill;

    // Knocked pins: Light gray, very subtle
    final knockedPaint = Paint()
      ..color = const Color(0xFFD1D5DB).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    // Draw outline for standing pins to make them more visible
    final outlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int pin = 1; pin <= 10; pin++) {
      final pos = pinPositions[pin];
      if (pos == null) continue;

      final center = Offset(pos.dx * size.width, pos.dy * size.height);
      final isStanding = pinsLeft.contains(pin);
      final paint = isStanding ? standingPaint : knockedPaint;
      final radius = isStanding ? 3.8 : 2.2;

      // Draw the pin
      canvas.drawCircle(center, radius, paint);

      // Add white outline to standing pins for better visibility
      if (isStanding) {
        canvas.drawCircle(center, radius, outlinePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_PinPainter oldDelegate) {
    return oldDelegate.pinsLeft != pinsLeft || oldDelegate.pinColor != pinColor;
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
    required this.pocketHits,
    required this.frameScores,
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
  final int pocketHits;
  final List<int> frameScores;

  int get completedFrames => totalFrames;

  double get firstBallAverage =>
      firstBallAttempts == 0 ? 0 : firstBallPins / firstBallAttempts;

  double get scoreStandardDeviation {
    if (frameScores.isEmpty) return 0.0;
    if (frameScores.length == 1) return 0.0;

    final mean = frameScores.reduce((a, b) => a + b) / frameScores.length;
    final variance =
        frameScores.fold<double>(
          0.0,
          (sum, score) => sum + ((score - mean) * (score - mean)),
        ) /
        frameScores.length;
    return math.sqrt(variance);
  }

  String get strikePercentageString => _percentage(strikes, totalFrames);

  String get sparePercentageString =>
      _percentage(spares, totalFrames - strikes);

  String get pocketHitPercentageString => _percentage(pocketHits, totalFrames);

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
  var pocketHits = 0;
  final frameScores = <int>[];

  // Build frame scores list first
  final orderedFrames = List<FrameEntity>.from(frames)
    ..sort((a, b) => a.number.compareTo(b.number));
  for (var i = 0; i < orderedFrames.length; i++) {
    final frameScore = _frameScoreAt(orderedFrames, i);
    if (frameScore != null) {
      frameScores.add(frameScore);
    }
  }

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
      pocketHits++; // Pocket hit is a strike on first ball
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
    pocketHits: pocketHits,
    frameScores: frameScores,
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

List<double> _buildMovingAverage(List<FrameEntity> frames, {int window = 3}) {
  final orderedFrames = List<FrameEntity>.from(frames)
    ..sort((a, b) => a.number.compareTo(b.number));
  final limitedFrames = orderedFrames
      .where((frame) => frame.number >= 1 && frame.number <= 10)
      .toList();

  final frameScores = <int>[];
  for (var i = 0; i < limitedFrames.length; i++) {
    final frameScore = _frameScoreAt(limitedFrames, i);
    if (frameScore == null) {
      break;
    }
    frameScores.add(frameScore);
  }

  final movingAverages = <double>[];
  for (var i = 0; i < frameScores.length; i++) {
    final start = (i - window + 1).clamp(0, frameScores.length - 1);
    final end = (i + 1).clamp(1, frameScores.length);
    final window_ = frameScores.sublist(start, end);
    final avg = window_.reduce((a, b) => a + b) / window_.length;
    movingAverages.add(avg);
  }

  return movingAverages;
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

// === Environment Section ===
class _EnvironmentSection extends StatelessWidget {
  const _EnvironmentSection({required this.game});

  final BowlingGameEntity game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Environment',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _EnvironmentRow(
            label: 'Oil Pattern',
            value: game.oilPattern.displayName,
            icon: Icons.water_drop,
          ),
          const SizedBox(height: 12),
          _EnvironmentRow(
            label: 'Lane Condition',
            value: game.laneCondition.displayName,
            icon: Icons.gradient,
          ),
          const SizedBox(height: 12),
          _EnvironmentRow(
            label: 'Game Type',
            value: game.gameType.displayName,
            icon: Icons.emoji_events,
          ),
          if (game.laneNumber != null) ...[
            const SizedBox(height: 12),
            _EnvironmentRow(
              label: 'Lane Number',
              value: game.laneNumber!,
              icon: Icons.pin_drop,
            ),
          ],
        ],
      ),
    );
  }
}

class _EnvironmentRow extends StatelessWidget {
  const _EnvironmentRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// === Game Type Indicator ===
class _GameTypeIndicator extends StatelessWidget {
  const _GameTypeIndicator({required this.game});

  final BowlingGameEntity game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTournament = game.gameType.name == 'tournament';
    final backgroundColor = isTournament
        ? const Color(0xFFDEDC1C).withValues(alpha: 0.1)
        : const Color(0xFF3B82F6).withValues(alpha: 0.1);
    final borderColor = isTournament
        ? const Color(0xFFDEDC1C)
        : const Color(0xFF3B82F6);
    final icon = isTournament ? Icons.emoji_events : Icons.sports_basketball;
    final label = isTournament ? 'Tournament Game' : 'Practice Game';
    final description = isTournament
        ? 'Official competition'
        : 'Practice & improvement';

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.3), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: borderColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: borderColor,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Badge(
            backgroundColor: borderColor,
            label: Text(
              game.gameType.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../domain/entities/frame_entity.dart';
import '../../bloc/add_score_state.dart';
import 'frame_score_tile.dart';

class Scoreboard extends StatelessWidget {
  const Scoreboard({super.key, required this.state});

  final AddScoreState state;

  @override
  Widget build(BuildContext context) {
    final frames = state.frames.isNotEmpty
        ? state.frames
        : List.generate(10, (i) => FrameEntity(number: i + 1));

    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.all(6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Frame numbers row
            Row(
              children: frames.map((frame) {
                final isTenth = frame.number == 10;
                final double tileWidth = isTenth ? 48 : 32;
                final isActive = state.currentFrame == frame.number;
                final Color borderColor = isActive
                    ? const Color(0xFF8BC342)
                    : const Color(0xFFE5E7EB);
                final Color textColor = isActive
                    ? const Color(0xFF8BC342)
                    : const Color(0xFF6B7280);

                return Container(
                  width: tileWidth,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: borderColor,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${frame.number}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
            // Score tiles row
            Row(
              children: frames.map((frame) {
                final cumulative = frame.number <= state.cumulativeScores.length
                    ? state.cumulativeScores[frame.number - 1]
                    : null;
                final isActive = state.currentFrame == frame.number;
                final maxIndex = frame.number == 10 ? 2 : 1;
                final currentIndex = state.currentThrow - 1;
                final activeThrowIndex = isActive
                    ? (currentIndex < 0
                          ? 0
                          : (currentIndex > maxIndex ? maxIndex : currentIndex))
                    : null;
                return FrameScoreTile(
                  frame: frame,
                  cumulativeScore: cumulative,
                  isActive: isActive,
                  activeThrowIndex: activeThrowIndex,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

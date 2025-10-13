

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
        child: Row(
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
      ),
    );
  }
}

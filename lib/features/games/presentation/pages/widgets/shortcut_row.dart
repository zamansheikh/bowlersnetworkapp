import 'package:flutter/material.dart';

import '../../bloc/add_score_state.dart';
import 'miss_or_foul_button.dart';
import 'shortcut_button.dart';

class ShortcutRow extends StatelessWidget {
  const ShortcutRow({
    super.key,
    required this.state,
    required this.onFoul,
    required this.onMiss,
    required this.onStrikeOrSpare,
  });

  final AddScoreState state;
  final VoidCallback onFoul;
  final VoidCallback onMiss;
  final VoidCallback onStrikeOrSpare;

  @override
  Widget build(BuildContext context) {
    final strikeLabel =
        (state.currentThrow == 1 ||
            (state.currentFrame == 10 && state.currentThrow == 3))
        ? 'Strike'
        : 'Spare';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          ShortcutButton(
            label: strikeLabel,
            textColor: Colors.white,
            borderColor: const Color(0xFF8BC342),
            backgroundColor: const Color(0xFF8BC342),
            onTap: onStrikeOrSpare,
          ),
          MissFoulButton(onMiss: onMiss, onFoul: onFoul),
        ],
      ),
    );
  }
}

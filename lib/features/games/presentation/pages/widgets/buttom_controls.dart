import 'package:flutter/material.dart';

import 'circular_icon_button.dart';

class BottomControls extends StatelessWidget {
  const BottomControls({
    super.key,
    required this.onPrevious,
    required this.onNext,
    required this.canGoPrevious,
    required this.canGoNext,
  });

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoPrevious;
  final bool canGoNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircularIconButton(
            icon: Icons.arrow_back,
            onTap: onPrevious,
            isEnabled: canGoPrevious,
          ),
          CircularIconButton(
            icon: Icons.arrow_forward,
            onTap: onNext,
            isEnabled: canGoNext,
          ),
        ],
      ),
    );
  }
}

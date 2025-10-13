
import 'package:flutter/material.dart';

import 'circular_icon_button.dart';

class BottomControls extends StatelessWidget {
  const BottomControls({super.key, 
    required this.onPrevious,
    required this.onSave,
    required this.onNext,
    required this.canGoPrevious,
    required this.canGoNext,
    this.canSave = false,
    this.isGameComplete = false,
  });

  final VoidCallback onPrevious;
  final VoidCallback onSave;
  final VoidCallback onNext;
  final bool canGoPrevious;
  final bool canGoNext;
  final bool canSave;
  final bool isGameComplete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          CircularIconButton(
            icon: Icons.arrow_back,
            onTap: onPrevious,
            isEnabled: canGoPrevious,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: canSave ? onSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSave
                        ? const Color(0xFF374151)
                        : const Color(0xFFE5E7EB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFE5E7EB),
                    disabledForegroundColor: const Color(0xFF9CA3AF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: canSave ? 1 : 0,
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    canSave
                        ? (isGameComplete ? 'Save game' : 'Save (Incomplete)')
                        : 'Complete all frames',
                    style: TextStyle(
                      color: canSave ? Colors.white : const Color(0xFF9CA3AF),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
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

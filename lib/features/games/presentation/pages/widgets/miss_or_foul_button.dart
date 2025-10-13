import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MissFoulButton extends StatefulWidget {
  const MissFoulButton({super.key, required this.onMiss, required this.onFoul});

  final VoidCallback onMiss;
  final VoidCallback onFoul;

  @override
  State<MissFoulButton> createState() => _MissFoulButtonState();
}

class _MissFoulButtonState extends State<MissFoulButton> {
  bool _showFoulState = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _handleMiss() {
    _resetTimer?.cancel();
    if (_showFoulState) {
      setState(() => _showFoulState = false);
    }
    HapticFeedback.selectionClick();
    widget.onMiss();
  }

  void _handleFoul() {
    HapticFeedback.mediumImpact();
    widget.onFoul();
    setState(() => _showFoulState = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _showFoulState = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFoulMode = _showFoulState;
    final Color borderColor = isFoulMode
        ? const Color(0xFFDC2626)
        : const Color(0xFFF59E0B);
    final Color backgroundColor = isFoulMode
        ? const Color(0xFFFEE2E2)
        : Colors.white;
    final Color textColor = isFoulMode
        ? const Color(0xFFB91C1C)
        : const Color(0xFFF59E0B);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 54,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isFoulMode
                ? [
                    BoxShadow(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : <BoxShadow>[],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _handleMiss,
              onLongPress: _handleFoul,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: Text(
                    isFoulMode ? 'Foul' : 'Miss',
                    key: ValueKey<bool>(isFoulMode),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

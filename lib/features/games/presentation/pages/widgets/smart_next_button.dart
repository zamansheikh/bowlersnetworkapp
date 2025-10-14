import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SmartNextButton extends StatefulWidget {
  const SmartNextButton({
    super.key,
    required this.onNext,
    required this.onMiss,
    required this.onFoul,
  });

  final VoidCallback onNext;
  final VoidCallback onMiss;
  final VoidCallback onFoul;

  @override
  State<SmartNextButton> createState() => _SmartNextButtonState();
}

class _SmartNextButtonState extends State<SmartNextButton> {
  bool _isLongPressing = false;
  int _selectedOption = 0; // 0 = Miss, 1 = Foul

  void _handleTap() {
    if (!_isLongPressing) {
      HapticFeedback.selectionClick();
      widget.onNext();
    }
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLongPressing = true;
      _selectedOption = 0;
    });
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_isLongPressing) return;

    setState(() {
      // Calculate which option is selected based on horizontal position
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        final width = box.size.width;
        final relativeX = details.localPosition.dx;

        if (relativeX < width / 2) {
          if (_selectedOption != 0) {
            HapticFeedback.selectionClick();
            _selectedOption = 0;
          }
        } else {
          if (_selectedOption != 1) {
            HapticFeedback.selectionClick();
            _selectedOption = 1;
          }
        }
      }
    });
  }

  void _handleLongPressEnd() {
    if (_isLongPressing) {
      HapticFeedback.mediumImpact();

      // Trigger the selected action
      if (_selectedOption == 0) {
        widget.onMiss();
      } else {
        widget.onFoul();
      }

      setState(() {
        _isLongPressing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLongPressing) {
      return _buildOptionsMode();
    } else {
      return _buildNextMode();
    }
  }

  Widget _buildNextMode() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: _handleTap,
          onLongPressStart: _handleLongPressStart,
          onLongPressMoveUpdate: _handleLongPressMoveUpdate,
          onLongPressEnd: (_) => _handleLongPressEnd(),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8BC342), width: 2),
            ),
            child: Center(
              child: Text(
                'Next',
                style: TextStyle(
                  color: const Color(0xFF8BC342),
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsMode() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onLongPressMoveUpdate: _handleLongPressMoveUpdate,
          onLongPressEnd: (_) => _handleLongPressEnd(),
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8BC342), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Row(
                children: [
                  // Miss option
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: _selectedOption == 0
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFFFEF3C7),
                        border: Border(
                          right: BorderSide(
                            color: const Color(0xFF8BC342),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Miss',
                          style: TextStyle(
                            color: _selectedOption == 0
                                ? Colors.white
                                : const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Foul option
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: _selectedOption == 1
                            ? const Color(0xFFDC2626)
                            : const Color(0xFFFEE2E2),
                      ),
                      child: Center(
                        child: Text(
                          'Foul',
                          style: TextStyle(
                            color: _selectedOption == 1
                                ? Colors.white
                                : const Color(0xFFDC2626),
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

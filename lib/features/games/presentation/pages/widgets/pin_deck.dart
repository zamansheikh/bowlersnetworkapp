import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../bloc/add_score_state.dart';

class PinDeck extends StatefulWidget {
  const PinDeck({super.key, required this.state, required this.onPinTap});

  final AddScoreState state;
  final ValueChanged<int> onPinTap;

  @override
  State<PinDeck> createState() => _PinDeckState();
}

class _PinDeckState extends State<PinDeck> {
  final Set<int> _swipedPins = {};
  bool _isSwiping = false;

  void _handlePanStart(DragStartDetails details, RenderBox box) {
    setState(() {
      _isSwiping = true;
      _swipedPins.clear();
    });
    _checkPinAtPosition(details.localPosition, box);
  }

  void _handlePanUpdate(DragUpdateDetails details, RenderBox box) {
    if (!_isSwiping) return;
    _checkPinAtPosition(details.localPosition, box);
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _isSwiping = false;
      _swipedPins.clear();
    });
  }

  void _checkPinAtPosition(Offset position, RenderBox box) {
    final width = box.size.width;
    final height = box.size.height;
    final radius = (width / 16).clamp(22.0, 32.0) * 1.5;

    final positions = {
      1: Offset(0.5 * width, 0.85 * height),
      2: Offset(0.37 * width, 0.6 * height),
      3: Offset(0.63 * width, 0.6 * height),
      4: Offset(0.25 * width, 0.35 * height),
      5: Offset(0.5 * width, 0.35 * height),
      6: Offset(0.75 * width, 0.35 * height),
      7: Offset(0.15 * width, 0.1 * height),
      8: Offset(0.37 * width, 0.1 * height),
      9: Offset(0.63 * width, 0.1 * height),
      10: Offset(0.85 * width, 0.1 * height),
    };

    for (final entry in positions.entries) {
      final pinNumber = entry.key;
      final pinCenter = entry.value;
      final distance = (position - pinCenter).distance;

      // Check if touch is within pin radius
      if (distance <= radius && !_swipedPins.contains(pinNumber)) {
        final availablePins = widget.state.remainingPins;
        final isAvailable = availablePins.contains(pinNumber);
        final isDisabled = widget.state.currentIsFoul || !isAvailable;

        if (!isDisabled) {
          _swipedPins.add(pinNumber);
          widget.onPinTap(pinNumber);

          // Add haptic feedback for better UX
          HapticFeedback.lightImpact();
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    // Calculate component heights
    const safetyMargin = 20.0;
    const headerHeight = 76.0; // Header + spacing
    const scoreboardHeight = 66.0; // Scoreboard height
    const shortcutRowHeight = 52.0; // Shortcut buttons height
    const bottomControlsHeight = 54.0; // Bottom controls height
    const spacingTotal = 20 + 16 + 18 + 16; // All spacing between components

    // Calculate available height for pin deck
    final availableHeight =
        screenHeight -
        headerHeight -
        scoreboardHeight -
        shortcutRowHeight -
        bottomControlsHeight -
        safetyMargin -
        spacingTotal;

    // Use calculated height or minimum height if screen is too small
    final deckHeight = availableHeight.clamp(280.0, 500.0);
    final deckWidth = screenWidth - 32; // Account for horizontal padding

    return SizedBox(
      height: deckHeight,
      width: deckWidth,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          final radius = (width / 16).clamp(22.0, 32.0);
          final positions = {
            1: const Offset(0.5, 0.85),
            2: const Offset(0.37, 0.6),
            3: const Offset(0.63, 0.6),
            4: const Offset(0.25, 0.35),
            5: const Offset(0.5, 0.35),
            6: const Offset(0.75, 0.35),
            7: const Offset(0.15, 0.1),
            8: const Offset(0.37, 0.1),
            9: const Offset(0.63, 0.1),
            10: const Offset(0.85, 0.1),
          };

          return GestureDetector(
            onPanStart: (details) {
              final box = context.findRenderObject() as RenderBox;
              _handlePanStart(details, box);
            },
            onPanUpdate: (details) {
              final box = context.findRenderObject() as RenderBox;
              _handlePanUpdate(details, box);
            },
            onPanEnd: _handlePanEnd,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: positions.entries.map((entry) {
                  final pinNumber = entry.key;
                  final position = entry.value;
                  final availablePins = widget.state.remainingPins;
                  final isAvailable = availablePins.contains(pinNumber);
                  final isKnocked = widget.state.currentKnockedPins.contains(
                    pinNumber,
                  );
                  final isStanding = isAvailable && !isKnocked;
                  final isDisabled = widget.state.currentIsFoul || !isAvailable;

                  return Positioned(
                    left: position.dx * width - radius * 1.5,
                    top: position.dy * height - radius,
                    child: _Pin(
                      number: pinNumber,
                      radius: radius * 1.5,
                      isStanding: isStanding,
                      isKnocked: isKnocked,
                      isDisabled: isDisabled,
                      onTap: () => widget.onPinTap(pinNumber),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Pin extends StatelessWidget {
  const _Pin({
    required this.number,
    required this.radius,
    required this.isStanding,
    required this.isKnocked,
    required this.isDisabled,
    required this.onTap,
  });

  final int number;
  final double radius;
  final bool isStanding;
  final bool isKnocked;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    if (!isStanding) {
      return GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              shape: BoxShape.circle,
              border: Border.all(
                color: isKnocked
                    ? const Color(0xFF8BC342)
                    : const Color(0xFFD1D5DB),
                width: isKnocked ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Color(0xFFB0B5C0),
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isKnocked ? const Color(0xFFECFDF5) : Colors.white,
                border: Border.all(
                  color: isKnocked
                      ? const Color(0xFF8BC342)
                      : const Color(0xFF8BC342),
                  width: isKnocked ? 3 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isKnocked
                        ? const Color(0xFF8BC342).withValues(alpha: 0.2)
                        : const Color(0xFF8BC342).withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
            //Bowling pin Icon
            Positioned(
              bottom: size * 0.0,
              child: SvgPicture.asset(
                'assets/icons/bowling_pin.svg',
                width: size,
                colorFilter: ColorFilter.mode(
                  isKnocked ? const Color(0xFF8BC342) : const Color(0xFFE43F4E),
                  BlendMode.srcIn,
                ),
              ),
            ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isKnocked
                      ? const Color(0xFF8BC342)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            Positioned(
              bottom: 6,
              child: Text(
                '$number',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isKnocked
                      ? const Color(0xFF059669)
                      : const Color(0xFF4B5563),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

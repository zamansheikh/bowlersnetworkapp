import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/context_extensions.dart';
import 'bowling_pin.dart';

/// Pin layout — coordinates match web's PIN_POS exactly (272×218 canvas).
/// Pins are positioned via percentages so the deck scales to any width.
const Map<int, ({double x, double y})> _pinPos = {
  7: (x: 28, y: 10),
  8: (x: 92, y: 10),
  9: (x: 156, y: 10),
  10: (x: 220, y: 10),
  4: (x: 60, y: 62),
  5: (x: 124, y: 62),
  6: (x: 188, y: 62),
  2: (x: 92, y: 114),
  3: (x: 156, y: 114),
  1: (x: 124, y: 166),
};

const _canvasWidth = 272.0;
const _canvasHeight = 220.0;
const _pinSize = 48.0;

/// Web's "press → drag → release" batch toggle. Tap any pin to flip its
/// state; press and slide across other pins to apply the same flip to
/// each one you pass.
///
/// [standing] is the set of pin numbers still up. The set is rendered;
/// callbacks fire when the user flips a pin. The bloc owns the state and
/// the rules — this widget is presentational.
class PinDeck extends StatefulWidget {
  const PinDeck({
    super.key,
    required this.standing,
    required this.availablePins,
    required this.onSetStanding,
  });

  /// Currently-standing pins after the in-progress delivery (i.e. what
  /// the user sees up after their imagined throw).
  final List<int> standing;

  /// Pins that are eligible to be toggled this delivery. Pins NOT in this
  /// set render as faded and don't respond to taps/drag.
  final List<int> availablePins;

  /// Called when the user toggles the standing set. The widget computes
  /// the next set and hands it over — bloc decides whether to commit.
  final ValueChanged<List<int>> onSetStanding;

  @override
  State<PinDeck> createState() => _PinDeckState();
}

/// During a drag, all touched pins flip to the SAME target state (the
/// opposite of the first-touched pin's state). Matches web's `dragMode`.
enum _DragMode { knock, stand, none }

class _PinDeckState extends State<PinDeck> {
  _DragMode _dragMode = _DragMode.none;
  final Set<int> _touchedThisDrag = {};

  /// Rebuild the standing set after toggling [pin].
  ///   - In _DragMode.knock: pin becomes knocked (removed from standing).
  ///   - In _DragMode.stand: pin becomes standing (added).
  ///   - On a fresh tap (drag-start), flip based on the pin's current state.
  void _applyToPin(int pin, {required _DragMode mode}) {
    if (!widget.availablePins.contains(pin)) return;
    final isStanding = widget.standing.contains(pin);
    final next = [...widget.standing];

    final targetKnock = switch (mode) {
      _DragMode.knock => true,
      _DragMode.stand => false,
      _DragMode.none => isStanding, // first tap → opposite of current
    };

    if (targetKnock) {
      next.removeWhere((p) => p == pin);
    } else if (!next.contains(pin)) {
      next.add(pin);
    }
    next.sort();
    widget.onSetStanding(next);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final scale = constraints.maxWidth / _canvasWidth;
      final pinW = _pinSize * scale;
      final h = _canvasHeight * scale;

      // Pre-compute pin rects in this layout's coords.
      final rects = <int, Rect>{
        for (final entry in _pinPos.entries)
          entry.key: Rect.fromCenter(
            center: Offset(entry.value.x * scale, entry.value.y * scale),
            width: pinW,
            height: pinW * (56 / 40), // pin aspect ratio
          ),
      };

      int? hitTest(Offset local) {
        for (final entry in rects.entries) {
          if (entry.value.contains(local)) return entry.key;
        }
        return null;
      }

      return SizedBox(
        height: h,
        width: constraints.maxWidth,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            final hit = hitTest(event.localPosition);
            if (hit == null) return;
            if (!widget.availablePins.contains(hit)) return;
            // First touched pin chooses the drag direction.
            final isStanding = widget.standing.contains(hit);
            _dragMode = isStanding ? _DragMode.knock : _DragMode.stand;
            _touchedThisDrag
              ..clear()
              ..add(hit);
            _applyToPin(hit, mode: _dragMode);
            HapticFeedback.selectionClick();
          },
          onPointerMove: (event) {
            if (_dragMode == _DragMode.none) return;
            final hit = hitTest(event.localPosition);
            if (hit == null || _touchedThisDrag.contains(hit)) return;
            _touchedThisDrag.add(hit);
            _applyToPin(hit, mode: _dragMode);
            HapticFeedback.selectionClick();
          },
          onPointerUp: (_) {
            _dragMode = _DragMode.none;
            _touchedThisDrag.clear();
          },
          onPointerCancel: (_) {
            _dragMode = _DragMode.none;
            _touchedThisDrag.clear();
          },
          child: Stack(
            children: [
              for (final entry in _pinPos.entries)
                Positioned.fromRect(
                  rect: rects[entry.key]!,
                  child: _PinSlot(
                    number: entry.key,
                    isStanding: widget.standing.contains(entry.key),
                    isAvailable: widget.availablePins.contains(entry.key),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _PinSlot extends StatelessWidget {
  const _PinSlot({
    required this.number,
    required this.isStanding,
    required this.isAvailable,
  });

  final int number;
  final bool isStanding;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isAvailable ? 1.0 : 0.18,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 90),
        scale: isStanding ? 1.0 : 0.92,
        curve: Curves.easeOut,
        child: Stack(
          fit: StackFit.expand,
          children: [
            BowlingPin(number: number, isStanding: isStanding),
            // Number badge — only on standing pins (knocked already shows
            // the number inside its hollow circle).
            if (isStanding)
              Positioned.fill(
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.6,
                    heightFactor: 0.35,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.only(top: 14),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$number',
                          style: TextStyle(
                            color: colors.textPrimary
                                .withValues(alpha: 0.55),
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

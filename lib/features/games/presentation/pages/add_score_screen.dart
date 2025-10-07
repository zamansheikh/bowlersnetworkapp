// presentation/pages/add_score_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/frame_entity.dart';
import '../../domain/entities/throw_entity.dart';
import '../bloc/add_score_bloc.dart';
import '../bloc/add_score_event.dart';
import '../bloc/add_score_state.dart';

class AddScoreScreen extends StatelessWidget {
  const AddScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddScoreBloc>()..add(StartNewGame()),
      child: const _AddScoreView(),
    );
  }
}

class _AddScoreView extends StatelessWidget {
  const _AddScoreView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F131F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: BlocListener<AddScoreBloc, AddScoreState>(
            listenWhen: (previous, current) =>
                previous.completionScore != current.completionScore,
            listener: (context, state) async {
              final score = state.completionScore;
              if (score == null) return;

              await showDialog<void>(
                context: context,
                barrierDismissible: true,
                builder: (dialogContext) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFF161A28),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text(
                      'Game complete!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: Text(
                      'Your total score is $score.',
                      style: const TextStyle(
                        color: Color(0xFFD9DFF5),
                        fontSize: 16,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text(
                          'Great',
                          style: TextStyle(
                            color: Color(0xFF35D07F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (!context.mounted) return;
              context.read<AddScoreBloc>().add(DismissCompletionDialog());
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(onBackPressed: () => context.pop()),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<AddScoreBloc, AddScoreState>(
                    builder: (context, state) {
                      final bloc = context.read<AddScoreBloc>();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Scoreboard(state: state),
                          const SizedBox(height: 24),
                          Expanded(
                            child: _PinDeck(
                              state: state,
                              onPinTap: (pin) => bloc.add(SelectPin(pin)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _ShortcutRow(
                            state: state,
                            onFoul: () =>
                                bloc.add(PressShortcut(ShortcutType.foul)),
                            onMiss: () =>
                                bloc.add(PressShortcut(ShortcutType.miss)),
                            onStrikeOrSpare: () => bloc.add(
                              PressShortcut(ShortcutType.strikeOrSpare),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _BottomControls(
                            onPrevious: () => bloc.add(PreviousThrow()),
                            onSave: () => bloc.add(SaveGame()),
                            onNext: () => bloc.add(NextThrow()),
                          ),
                        ],
                      );
                    },
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

class _Header extends StatelessWidget {
  const _Header({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircularIconButton(
          icon: Icons.arrow_back,
          onTap: onBackPressed,
          backgroundColor: const Color(0x23161A28),
          iconColor: const Color(0xFF35D07F),
        ),
        const SizedBox(width: 12),
        const Text(
          'Add your scores',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _Scoreboard extends StatelessWidget {
  const _Scoreboard({required this.state});

  final AddScoreState state;

  @override
  Widget build(BuildContext context) {
    final frames = state.frames.isNotEmpty
        ? state.frames
        : List.generate(10, (i) => FrameEntity(number: i + 1));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF161A2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: frames.map((frame) {
            final cumulative = frame.number <= state.cumulativeScores.length
                ? state.cumulativeScores[frame.number - 1]
                : null;
            final isActive = state.currentFrame == frame.number;
            return _FrameScoreTile(
              frame: frame,
              cumulativeScore: cumulative,
              isActive: isActive,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FrameScoreTile extends StatelessWidget {
  const _FrameScoreTile({
    required this.frame,
    required this.cumulativeScore,
    required this.isActive,
  });

  final FrameEntity frame;
  final int? cumulativeScore;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isTenth = frame.number == 10;
    final slots = isTenth ? 3 : 2;
    final symbols = _frameSymbols(frame);

    final double tileWidth = isTenth ? 68 : 56;
    final Color borderColor = isActive
        ? const Color(0xFF35D07F)
        : Colors.white.withValues(alpha: 0.14);

    return Container(
      width: tileWidth,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF101426),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: List.generate(slots, (index) {
                return Expanded(
                  child: Container(
                    height: 28,
                    decoration: BoxDecoration(
                      border: Border(
                        right: index == slots - 1
                            ? BorderSide.none
                            : const BorderSide(color: Color(0xFFE3E6F3)),
                        bottom: const BorderSide(color: Color(0xFFE3E6F3)),
                      ),
                      color: Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      symbols[index],
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1F2233),
                      ),
                    ),
                  ),
                );
              }),
            ),
            Container(
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF35D07F) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              child: Text(
                cumulativeScore != null ? '$cumulativeScore' : '',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isActive ? Colors.white : const Color(0xFF1F2233),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinDeck extends StatelessWidget {
  const _PinDeck({required this.state, required this.onPinTap});

  final AddScoreState state;
  final ValueChanged<int> onPinTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final radius = width / 14;
        final positions = {
          1: const Offset(0.5, 0.87),
          2: const Offset(0.42, 0.69),
          3: const Offset(0.58, 0.69),
          4: const Offset(0.34, 0.51),
          5: const Offset(0.5, 0.51),
          6: const Offset(0.66, 0.51),
          7: const Offset(0.26, 0.33),
          8: const Offset(0.42, 0.33),
          9: const Offset(0.58, 0.33),
          10: const Offset(0.74, 0.33),
        };

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF141829), Color(0xFF0F121E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: positions.entries.map((entry) {
              final pinNumber = entry.key;
              final position = entry.value;
              final availablePins = state.remainingPins;
              final isAvailable = availablePins.contains(pinNumber);
              final isKnocked = state.currentKnockedPins.contains(pinNumber);
              final isStanding = isAvailable && !isKnocked;
              final isDisabled = state.currentIsFoul || !isAvailable;

              return Positioned(
                left: position.dx * width - radius,
                top: position.dy * height - radius,
                child: _Pin(
                  number: pinNumber,
                  radius: radius,
                  isStanding: isStanding,
                  isKnocked: isKnocked,
                  isDisabled: isDisabled,
                  onTap: () => onPinTap(pinNumber),
                ),
              );
            }).toList(),
          ),
        );
      },
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
              color: const Color(0xFF191D2D),
              shape: BoxShape.circle,
              border: Border.all(
                color: isKnocked
                    ? const Color(0xFF35D07F)
                    : Colors.white.withValues(alpha: 0.08),
                width: isKnocked ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Color(0xFFD9DFF5),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
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
                gradient: LinearGradient(
                  colors: isKnocked
                      ? [const Color(0xFFFFFFFF), const Color(0xFFEAFEF3)]
                      : [const Color(0xFFF6F6FB), const Color(0xFFE4E7F6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
            Positioned(
              top: size * 0.22,
              child: Container(
                width: size * 0.68,
                height: size * 0.2,
                decoration: BoxDecoration(
                  color: const Color(0xFFE43F4E),
                  borderRadius: BorderRadius.circular(size),
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
                      ? const Color(0xFF35D07F)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            Positioned(
              bottom: 6,
              child: Text(
                '$number',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2233),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
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

    return Row(
      children: [
        _ShortcutButton(
          label: 'Foul',
          textColor: const Color(0xFFFF5C8D),
          borderColor: const Color(0xFFFF5C8D),
          onTap: onFoul,
        ),
        _ShortcutButton(
          label: 'Miss',
          textColor: const Color(0xFFF3D158),
          borderColor: const Color(0xFFF3D158),
          onTap: onMiss,
        ),
        _ShortcutButton(
          label: strikeLabel,
          textColor: const Color(0xFF0E1A12),
          borderColor: const Color(0xFF35D07F),
          backgroundColor: const Color(0xFF35D07F),
          onTap: onStrikeOrSpare,
        ),
      ],
    );
  }
}

class _ShortcutButton extends StatelessWidget {
  const _ShortcutButton({
    required this.label,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
    this.backgroundColor,
  });

  final String label;
  final Color textColor;
  final Color borderColor;
  final Color? backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              backgroundColor: backgroundColor ?? Colors.transparent,
              side: BorderSide(color: borderColor, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.onPrevious,
    required this.onSave,
    required this.onNext,
  });

  final VoidCallback onPrevious;
  final VoidCallback onSave;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircularIconButton(icon: Icons.arrow_back, onTap: onPrevious),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A5F72),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text(
                  'Save game',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
        _CircularIconButton(icon: Icons.arrow_forward, onTap: onNext),
      ],
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor = const Color(0xFF161A28),
    this.iconColor = const Color(0xFF35D07F),
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: iconColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

List<String> _frameSymbols(FrameEntity frame) {
  final isTenth = frame.number == 10;
  final slots = isTenth ? 3 : 2;
  final result = List.filled(slots, '');
  final throws = frame.throws;

  if (throws.isEmpty) {
    return result;
  }

  final first = throws.first;
  result[0] = _symbolForFirstThrow(first);

  if (!isTenth) {
    if (first.pinsKnocked == 10 && !first.isFoul) {
      return result;
    }

    if (throws.length >= 2) {
      final second = throws[1];
      if (second.isFoul) {
        result[1] = 'F';
      } else if (!first.isFoul &&
          first.pinsKnocked + second.pinsKnocked == 10) {
        result[1] = '/';
      } else if (second.pinsKnocked == 0) {
        result[1] = '-';
      } else {
        result[1] = '${second.pinsKnocked}';
      }
    }

    return result;
  }

  if (throws.length >= 2) {
    final second = throws[1];
    if (second.isFoul) {
      result[1] = 'F';
    } else if (second.pinsKnocked == 10) {
      result[1] = 'X';
    } else if (!first.isFoul &&
        first.pinsKnocked != 10 &&
        first.pinsKnocked + second.pinsKnocked == 10) {
      result[1] = '/';
    } else if (second.pinsKnocked == 0) {
      result[1] = '-';
    } else {
      result[1] = '${second.pinsKnocked}';
    }
  }

  if (throws.length >= 3) {
    final second = throws[1];
    final third = throws[2];
    if (third.isFoul) {
      result[2] = 'F';
    } else if (third.pinsKnocked == 10) {
      result[2] = 'X';
    } else if (!second.isFoul &&
        second.pinsKnocked != 10 &&
        second.pinsKnocked + third.pinsKnocked == 10) {
      result[2] = '/';
    } else if (third.pinsKnocked == 0) {
      result[2] = '-';
    } else {
      result[2] = '${third.pinsKnocked}';
    }
  }

  return result;
}

String _symbolForFirstThrow(ThrowEntity throwEntity) {
  if (throwEntity.isFoul) return 'F';
  if (throwEntity.pinsKnocked == 10) return 'X';
  if (throwEntity.pinsKnocked == 0) return '-';
  return '${throwEntity.pinsKnocked}';
}

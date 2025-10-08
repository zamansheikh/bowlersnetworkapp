// presentation/pages/add_score_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white, // Pure white background
        body: SafeArea(
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
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: const Text(
                      'Game complete!',
                      style: TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    content: Text(
                      'Your total score is $score.',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
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
            child: BlocBuilder<AddScoreBloc, AddScoreState>(
              builder: (context, state) {
                final bloc = context.read<AddScoreBloc>();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _Header(onBackPressed: () => context.pop()),
                    const SizedBox(height: 20),
                    _Scoreboard(state: state),
                    const SizedBox(height: 16),
                    _PinDeck(
                      state: state,
                      onPinTap: (pin) => bloc.add(SelectPin(pin)),
                    ),
                    const Spacer(),
                    _ShortcutRow(
                      state: state,
                      onFoul: () => bloc.add(PressShortcut(ShortcutType.foul)),
                      onMiss: () => bloc.add(PressShortcut(ShortcutType.miss)),
                      onStrikeOrSpare: () =>
                          bloc.add(PressShortcut(ShortcutType.strikeOrSpare)),
                    ),
                    const SizedBox(height: 18),
                    _BottomControls(
                      onPrevious: () => bloc.add(PreviousThrow()),
                      onSave: () => bloc.add(SaveGame()),
                      onNext: () => bloc.add(NextThrow()),
                      canGoPrevious: state.canGoPrevious,
                      canGoNext: state.canGoNext,
                    ),
                    const SizedBox(height: 16), // Bottom padding
                  ],
                );
              },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF35D07F), width: 2),
            ),
            child: _CircularIconButton(
              icon: Icons.arrow_back,
              onTap: onBackPressed,
              backgroundColor: Colors.white,
              iconColor: const Color(0xFF35D07F),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Add your scores',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha: 0.06),
        //     blurRadius: 12,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
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
            return _FrameScoreTile(
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

class _FrameScoreTile extends StatelessWidget {
  const _FrameScoreTile({
    required this.frame,
    required this.cumulativeScore,
    required this.isActive,
    this.activeThrowIndex,
  });

  final FrameEntity frame;
  final int? cumulativeScore;
  final bool isActive;
  final int? activeThrowIndex;

  @override
  Widget build(BuildContext context) {
    final isTenth = frame.number == 10;
    final slots = isTenth ? 3 : 2;
    final symbols = _frameSymbols(frame);

    final double tileWidth = isTenth ? 48 : 32;
    final Color borderColor = isActive
        ? const Color(0xFF35D07F)
        : const Color(0xFFE5E7EB);

    return Container(
      width: tileWidth,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: isActive ? 2 : 1),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF35D07F).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: List.generate(slots, (index) {
                final isActiveThrow =
                    activeThrowIndex != null && activeThrowIndex == index;
                final cellColor = isActiveThrow
                    ? const Color(0xFF35D07F)
                    : Colors.white;
                final textColor = isActiveThrow
                    ? Colors.white
                    : const Color(0xFF111827);
                return Expanded(
                  child: Container(
                    height: 22,
                    decoration: BoxDecoration(
                      border: Border(
                        right: index == slots - 1
                            ? BorderSide.none
                            : const BorderSide(color: Color(0xFFE3E6F3)),
                        bottom: const BorderSide(color: Color(0xFFE3E6F3)),
                      ),
                      color: cellColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      symbols[index],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                  ),
                );
              }),
            ),
            Container(
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(4),
                ),
              ),
              child: Text(
                cumulativeScore != null ? '$cumulativeScore' : '',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isActive
                      ? const Color(0xFF35D07F)
                      : const Color(0xFF111827),
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

          return Container(
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
                final availablePins = state.remainingPins;
                final isAvailable = availablePins.contains(pinNumber);
                final isKnocked = state.currentKnockedPins.contains(pinNumber);
                final isStanding = isAvailable && !isKnocked;
                final isDisabled = state.currentIsFoul || !isAvailable;

                return Positioned(
                  left: position.dx * width - radius * 1.5,
                  top: position.dy * height - radius,
                  child: _Pin(
                    number: pinNumber,
                    radius: radius * 1.5,
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
                    ? const Color(0xFF35D07F)
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
                      ? const Color(0xFF35D07F)
                      : const Color(0xFF35D07F),
                  width: isKnocked ? 3 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isKnocked
                        ? const Color(0xFF35D07F).withValues(alpha: 0.2)
                        : const Color(0xFF35D07F).withValues(alpha: 0.08),
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
                  isKnocked ? const Color(0xFF35D07F) : const Color(0xFFE43F4E),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _ShortcutButton(
            label: 'Foul',
            textColor: const Color(0xFFDC2626),
            borderColor: const Color(0xFFDC2626),
            onTap: onFoul,
          ),
          _ShortcutButton(
            label: 'Miss',
            textColor: const Color(0xFFF59E0B),
            borderColor: const Color(0xFFF59E0B),
            onTap: onMiss,
          ),
          _ShortcutButton(
            label: strikeLabel,
            textColor: Colors.white,
            borderColor: const Color(0xFF35D07F),
            backgroundColor: const Color(0xFF35D07F),
            onTap: onStrikeOrSpare,
          ),
        ],
      ),
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
          height: 54,
          child: OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              backgroundColor: backgroundColor ?? Colors.white,
              side: BorderSide(color: borderColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: 17,
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
    required this.canGoPrevious,
    required this.canGoNext,
  });

  final VoidCallback onPrevious;
  final VoidCallback onSave;
  final VoidCallback onNext;
  final bool canGoPrevious;
  final bool canGoNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _CircularIconButton(
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
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF374151),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 1,
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save game',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _CircularIconButton(
            icon: Icons.arrow_forward,
            onTap: onNext,
            isEnabled: canGoNext,
          ),
        ],
      ),
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({
    required this.icon,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = const Color(0xFF35D07F),
    this.isEnabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color iconColor;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final effectiveBackground = isEnabled
        ? backgroundColor
        : const Color(0xFFF3F4F6);
    final effectiveBorder = isEnabled ? iconColor : const Color(0xFFD1D5DB);
    final effectiveIcon = isEnabled ? iconColor : const Color(0xFF9CA3AF);

    final shadows = isEnabled
        ? [
            BoxShadow(
              color: const Color(0xFF35D07F).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : <BoxShadow>[];

    return IgnorePointer(
      ignoring: !isEnabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isEnabled ? 1 : 0.45,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: effectiveBackground,
              shape: BoxShape.circle,
              border: Border.all(color: effectiveBorder, width: 2),
              boxShadow: shadows,
            ),
            child: Icon(icon, color: effectiveIcon, size: 22),
          ),
        ),
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

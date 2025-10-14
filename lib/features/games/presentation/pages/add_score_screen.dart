// presentation/pages/add_score_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../bloc/add_score_bloc.dart';
import '../bloc/add_score_event.dart';
import '../bloc/add_score_state.dart';
import '../../domain/entities/bowling_game_entity.dart';
import 'widgets/buttom_controls.dart';
import 'widgets/header.dart';
import 'widgets/pin_deck.dart';
import 'widgets/scoreboard.dart';
import 'widgets/shortcut_row.dart';

class AddScoreScreen extends StatelessWidget {
  final BowlingGameEntity? initialGame;

  const AddScoreScreen({super.key, this.initialGame});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<AddScoreBloc>();
        if (initialGame != null) {
          bloc.add(LoadExistingGame(initialGame!));
        } else {
          bloc.add(StartNewGame());
        }
        return bloc;
      },
      child: const AddScoreView(),
    );
  }
}

class AddScoreView extends StatelessWidget {
  const AddScoreView({super.key});

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
          child: MultiBlocListener(
            listeners: [
              BlocListener<AddScoreBloc, AddScoreState>(
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
                                color: Color(0xFF8BC342),
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
              ),
              BlocListener<AddScoreBloc, AddScoreState>(
                listenWhen: (previous, current) =>
                    previous.gameSaved != current.gameSaved &&
                    current.gameSaved,
                listener: (context, state) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Game saved successfully!'),
                      backgroundColor: Color(0xFF8BC342),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Navigate back to games list
                  context.pop();
                },
              ),
            ],
            child: BlocBuilder<AddScoreBloc, AddScoreState>(
              builder: (context, state) {
                final bloc = context.read<AddScoreBloc>();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Header(
                      onBackPressed: () => context.pop(),
                      onSave: () => bloc.add(SaveGame()),
                    ),
                    const SizedBox(height: 20),
                    Scoreboard(state: state),
                    const SizedBox(height: 16),
                    PinDeck(
                      state: state,
                      onPinTap: (pin) => bloc.add(SelectPin(pin)),
                    ),
                    const Spacer(),
                    ShortcutRow(
                      state: state,
                      onFoul: () => bloc.add(PressShortcut(ShortcutType.foul)),
                      onMiss: () => bloc.add(PressShortcut(ShortcutType.miss)),
                      onStrikeOrSpare: () =>
                          bloc.add(PressShortcut(ShortcutType.strikeOrSpare)),
                    ),
                    const SizedBox(height: 18),
                    BottomControls(
                      onPrevious: () => bloc.add(PreviousThrow()),
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

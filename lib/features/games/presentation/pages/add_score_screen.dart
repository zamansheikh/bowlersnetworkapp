// presentation/pages/add_score_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../bloc/add_score_bloc.dart';
import '../bloc/add_score_event.dart';
import '../bloc/add_score_state.dart';

class AddScoreScreen extends StatelessWidget {
  const AddScoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddScoreBloc>()..add(StartNewGame()),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.green),
                    onPressed: () => context.pop(),
                  ),
                  const Text('Add your scores', style: TextStyle(fontSize: 20)),
                ],
              ),
              BlocBuilder<AddScoreBloc, AddScoreState>(
                builder: (context, state) {
                  final bloc = context.read<AddScoreBloc>();
                  final displayStrings = state.frames
                      .map((f) => f.display)
                      .toList();
                  final cum = state.cumulativeScores;

                  return Column(
                    children: [
                      // Score table
                      Container(
                        padding: const EdgeInsets.all(8),
                        child: Table(
                          border: TableBorder.all(color: Colors.grey),
                          defaultColumnWidth: const IntrinsicColumnWidth(),
                          children: [
                            TableRow(
                              children: List.generate(10, (i) {
                                return Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    displayStrings.length > i
                                        ? displayStrings[i]
                                        : '',
                                  ),
                                );
                              }),
                            ),
                            TableRow(
                              children: List.generate(10, (i) {
                                return Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    cum.length > i ? '${cum[i]}' : '',
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      // Pin diagram
                      SizedBox(
                        height: 300,
                        child: LayoutBuilder(
                          builder: (ctx, cons) {
                            double width = cons.maxWidth;
                            double height = cons.maxHeight;
                            double r = width / 20;
                            final pinPositions = {
                              1: const Offset(0.5, 0.85),
                              2: const Offset(0.4, 0.65),
                              3: const Offset(0.6, 0.65),
                              4: const Offset(0.3, 0.45),
                              5: const Offset(0.5, 0.45),
                              6: const Offset(0.7, 0.45),
                              7: const Offset(0.2, 0.25),
                              8: const Offset(0.4, 0.25),
                              9: const Offset(0.6, 0.25),
                              10: const Offset(0.8, 0.25),
                            };

                            return Stack(
                              children: pinPositions.entries.map((e) {
                                double x = e.value.dx * width - r;
                                double y = e.value.dy * height - r;
                                int pin = e.key;
                                bool isStanding = state.remainingPins.contains(
                                  pin,
                                );
                                bool isKnocked = state.currentKnockedPins
                                    .contains(pin);
                                Color color;
                                if (!isStanding) {
                                  color = Colors.grey.shade800;
                                } else if (isKnocked) {
                                  color = Colors.grey.shade800;
                                } else {
                                  color = Colors.white;
                                }

                                return Positioned(
                                  left: x,
                                  top: y,
                                  child: GestureDetector(
                                    onTap: state.currentIsFoul || !isStanding
                                        ? null
                                        : () => bloc.add(SelectPin(pin)),
                                    child: Container(
                                      width: 2 * r,
                                      height: 2 * r,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: color == Colors.white
                                            ? Border.all(
                                                color: Colors.red,
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$pin',
                                          style: TextStyle(
                                            color: color == Colors.white
                                                ? Colors.black
                                                : Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                      // Buttons
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                              ),
                              onPressed: () =>
                                  bloc.add(PressShortcut(ShortcutType.foul)),
                              child: const Text('Foul'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow.shade700,
                              ),
                              onPressed: () =>
                                  bloc.add(PressShortcut(ShortcutType.miss)),
                              child: const Text('Miss'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              onPressed: () => bloc.add(
                                PressShortcut(ShortcutType.strikeOrSpare),
                              ),
                              child: Text(
                                (state.currentThrow == 1 ||
                                        (state.currentFrame == 10 &&
                                            state.currentThrow == 3))
                                    ? 'Strike'
                                    : 'Spare',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Save row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            color: Colors.green,
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => bloc.add(PreviousThrow()),
                          ),
                          ElevatedButton(
                            onPressed: () => bloc.add(SaveGame()),
                            child: const Text('Save game'),
                          ),
                          IconButton(
                            color: Colors.green,
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () => bloc.add(ConfirmThrow()),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

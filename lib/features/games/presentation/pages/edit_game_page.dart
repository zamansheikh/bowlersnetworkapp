import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../domain/repositories/game_repository.dart';
import '../bloc/add_score_bloc.dart';
import '../bloc/add_score_event.dart';
import 'add_score_screen.dart';

class EditGamePage extends StatelessWidget {
  final String gameId;

  const EditGamePage({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<GameRepository>().getGameById(gameId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    snapshot.data?.fold(
                          (failure) => 'Error loading game',
                          (game) => 'Game not found',
                        ) ??
                        'Game not found',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        return snapshot.data!.fold(
          (failure) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load game',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
          (game) => _EditGameView(game: game),
        );
      },
    );
  }
}

class _EditGameView extends StatelessWidget {
  final dynamic game;

  const _EditGameView({required this.game});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddScoreBloc>()..add(LoadExistingGame(game)),
      child: const AddScoreScreen(),
    );
  }
}

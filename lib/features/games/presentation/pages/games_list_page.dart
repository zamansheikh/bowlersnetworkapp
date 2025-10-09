// presentation/pages/games_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../bloc/games_list_bloc.dart';
import '../bloc/games_list_event.dart';
import '../bloc/games_list_state.dart';

class GamesListPage extends StatelessWidget {
  const GamesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<GamesListBloc>()..add(LoadGames()),
      child: const GamesListView(),
    );
  }
}

class GamesListView extends StatelessWidget {
  const GamesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Games'),
        backgroundColor: const Color(0xFF8BC342),
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<GamesListBloc, GamesListState>(
        builder: (context, state) {
          if (state is GamesListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GamesListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<GamesListBloc>().add(LoadGames());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is GamesListLoaded) {
            if (state.games.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_baseball,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No games yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add your first game',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.games.length,
              itemBuilder: (context, index) {
                final game = state.games[index];
                final dateFormat = DateFormat('MMM dd, yyyy - hh:mm a');

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // TODO: Navigate to game details/analytics page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Game details coming soon!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Score circle
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8BC342),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${game.totalScore}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Game info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Game #${state.games.length - index}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormat.format(game.date),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Delete button
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red[400],
                            onPressed: () {
                              _showDeleteConfirmation(context, game.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/add-score');
        },
        backgroundColor: const Color(0xFF8BC342),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Score',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String gameId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Game'),
        content: const Text(
          'Are you sure you want to delete this game? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GamesListBloc>().add(DeleteGame(gameId));
              Navigator.of(dialogContext).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

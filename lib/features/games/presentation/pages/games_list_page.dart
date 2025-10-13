// presentation/pages/games_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../bloc/games_list_bloc.dart';
import '../bloc/games_list_event.dart';
import '../bloc/games_list_state.dart';
import '../../domain/services/pin_settings_service.dart';

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
    // Listen for navigation back to refresh the list
    return PopScope(
      onPopInvoked: (didPop) {
        if (!didPop) {
          context.read<GamesListBloc>().add(LoadGames());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Games'),
          backgroundColor: const Color(0xFF8BC342),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Game settings',
              onPressed: () => _showSettings(context),
            ),
          ],
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
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
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
                        // Navigate to analytics page
                        context.push('/game-analytics/${game.id}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Score circle with status indicator
                            Stack(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: game.isComplete
                                        ? const Color(0xFF8BC342)
                                        : const Color(0xFFF59E0B),
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
                                if (!game.isComplete)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Color(0xFFF59E0B),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Game info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Game #${state.games.length - index}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (!game.isComplete) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: const Text(
                                            'Incomplete',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFFF59E0B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
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
                            // Action buttons
                            if (!game.isComplete)
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                color: const Color(0xFF8BC342),
                                tooltip: 'Continue',
                                onPressed: () async {
                                  await context.push('/edit-game/${game.id}');
                                  if (context.mounted) {
                                    context.read<GamesListBloc>().add(
                                      LoadGames(),
                                    );
                                  }
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: Colors.red[400],
                              tooltip: 'Delete',
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
          onPressed: () async {
            await context.push('/add-score');
            // Reload games when returning from add score
            if (context.mounted) {
              context.read<GamesListBloc>().add(LoadGames());
            }
          },
          backgroundColor: const Color(0xFF8BC342),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Add Score',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
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

  void _showSettings(BuildContext context) {
    final pinSettings = getIt<PinSettingsService>();
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        var knockedByDefault = pinSettings.pinsKnockedByDefault;
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game settings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Choose how the pin deck behaves when you open the score sheet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Material(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(16),
                    child: SwitchListTile.adaptive(
                      value: knockedByDefault,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'Pins knocked by default',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: const Text(
                        'Enable to keep pins down when you start a throw. Disable to see all pins standing.',
                      ),
                      onChanged: (value) async {
                        setState(() => knockedByDefault = value);
                        await pinSettings.setPinsKnockedByDefault(value);
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Changes apply the next time you open or advance to a fresh frame.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// presentation/pages/games_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../domain/services/game_settings_service.dart';
import '../bloc/games_list_bloc.dart';
import '../bloc/games_list_event.dart';
import '../bloc/games_list_state.dart';
import '../widgets/game_setup_dialog.dart';
import '../widgets/hand_preference_dialog.dart';

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
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          title: const Text('My Games 🎳'),
          backgroundColor: const Color(0xFF8BC342),
          foregroundColor: Colors.white,
          elevation: 0,
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
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8BC342)),
                ),
              );
            }

            if (state is GamesListError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF374151),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<GamesListBloc>().add(LoadGames());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8BC342),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8BC342), Color(0xFF7AB233)],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF8BC342,
                              ).withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports_basketball,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'No games yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Get started by adding your first game',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
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

                  return _buildGameCard(
                    context,
                    game,
                    state.games.length - index,
                    dateFormat,
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            // Check if user has set hand preference
            final gameSettings = getIt<GameSettingsService>();
            if (!gameSettings.hasSetHandPreference) {
              // Show dialog to ask for hand preference
              final preference = await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const HandPreferenceDialog(),
              );

              if (preference != null && context.mounted) {
                await gameSettings.setDefaultHandPreference(preference);
              }
            }

            // Show game setup dialog
            if (context.mounted) {
              final setupData = await showDialog<GameSetupData>(
                context: context,
                barrierDismissible: false,
                builder: (context) => const GameSetupDialog(),
              );

              if (setupData != null && context.mounted) {
                await context.push('/add-score', extra: setupData);
                // Reload games when returning from add score
                if (context.mounted) {
                  context.read<GamesListBloc>().add(LoadGames());
                }
              }
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

  Widget _buildGameCard(
    BuildContext context,
    dynamic game,
    int gameNumber,
    DateFormat dateFormat,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to analytics page
        context.push('/game-analytics/${game.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.push('/game-analytics/${game.id}');
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    // Score circle with gradient
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: game.isComplete
                              ? const [Color(0xFF8BC342), Color(0xFF7AB233)]
                              : const [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: game.isComplete
                                ? const Color(
                                    0xFF8BC342,
                                  ).withValues(alpha: 0.25)
                                : const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${game.totalScore}',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Score',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    // Game info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Game #$gameNumber',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              if (!game.isComplete) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFEF3C7),
                                        Color(0xFFFCD34D),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFF59E0B,
                                        ).withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'In Progress',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD97706),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ] else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF8BC342,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF8BC342),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            dateFormat.format(game.date),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Action buttons
                    if (!game.isComplete)
                      Tooltip(
                        message: 'Continue',
                        child: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          color: const Color(0xFF8BC342),
                          iconSize: 20,
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            await context.push('/edit-game/${game.id}');
                            if (context.mounted) {
                              context.read<GamesListBloc>().add(LoadGames());
                            }
                          },
                        ),
                      ),
                    Tooltip(
                      message: 'Delete',
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.red.withValues(alpha: 0.6),
                        iconSize: 20,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          _showDeleteConfirmation(context, game.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String gameId) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFAFAFA), Color(0xFFF5F5F5)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 32,
                    color: Colors.red[400],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete Game?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This action cannot be undone. Your game data will be permanently removed.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<GamesListBloc>().add(DeleteGame(gameId));
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          shadowColor: Colors.red.withValues(alpha: 0.3),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettings(BuildContext context) {
    context.push('/games-settings').then((_) {
      // Reload games when returning from settings in case anything changed
      context.read<GamesListBloc>().add(LoadGames());
    });
  }
}

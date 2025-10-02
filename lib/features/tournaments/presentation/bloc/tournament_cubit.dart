import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/usecases/tournament_usecases.dart';
import 'tournament_state.dart';

@injectable
class TournamentCubit extends Cubit<TournamentState> {
  final GetTournamentsUseCase getTournaments;
  final GetTournamentByIdUseCase getTournamentById;
  final RegisterForTournamentUseCase registerForTournament;
  final UnregisterFromTournamentUseCase unregisterFromTournament;
  final CreateTournamentUseCase createTournament;
  final GetUserRegisteredTournamentsUseCase getUserRegisteredTournaments;
  final GetAvailableTournamentsUseCase getAvailableTournaments;

  TournamentCubit({
    required this.getTournaments,
    required this.getTournamentById,
    required this.registerForTournament,
    required this.unregisterFromTournament,
    required this.createTournament,
    required this.getUserRegisteredTournaments,
    required this.getAvailableTournaments,
  }) : super(TournamentInitial());

  Future<void> loadTournaments() async {
    try {
      emit(TournamentLoading());
      final tournaments = await getTournaments();
      emit(TournamentLoaded(tournaments: tournaments));
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }

  Future<void> refreshTournaments() async {
    final currentState = state;
    if (currentState is TournamentLoaded) {
      try {
        final tournaments = await getTournaments();
        emit(currentState.copyWith(tournaments: tournaments));
      } catch (e) {
        emit(TournamentError(message: e.toString()));
      }
    } else {
      await loadTournaments();
    }
  }

  void setActiveTab(String tab) {
    final currentState = state;
    if (currentState is TournamentLoaded) {
      emit(currentState.copyWith(activeTab: tab));
    }
  }

  void updateSearchTerm(String searchTerm) {
    final currentState = state;
    if (currentState is TournamentLoaded) {
      emit(currentState.copyWith(searchTerm: searchTerm));
    }
  }

  void updateSearchMode(TournamentSearchMode mode) {
    final currentState = state;
    if (currentState is TournamentLoaded) {
      emit(currentState.copyWith(searchMode: mode, searchTerm: ''));
    }
  }

  void toggleFormatFilter(String format) {
    final currentState = state;
    if (currentState is TournamentLoaded) {
      final currentFormats = List<String>.from(currentState.selectedFormats);
      if (currentFormats.contains(format)) {
        currentFormats.remove(format);
      } else {
        currentFormats.add(format);
      }
      emit(currentState.copyWith(selectedFormats: currentFormats));
    }
  }

  void toggleAccessLevelFilter(String accessLevel) {
    final currentState = state;
    if (currentState is TournamentLoaded) {
      final currentLevels = List<String>.from(
        currentState.selectedAccessLevels,
      );
      if (currentLevels.contains(accessLevel)) {
        currentLevels.remove(accessLevel);
      } else {
        currentLevels.add(accessLevel);
      }
      emit(currentState.copyWith(selectedAccessLevels: currentLevels));
    }
  }

  void resetFilters() {
    final currentState = state;
    if (currentState is TournamentLoaded) {
      emit(
        currentState.copyWith(
          searchTerm: '',
          selectedFormats: [],
          selectedAccessLevels: [],
        ),
      );
    }
  }

  List<String> getSearchSuggestions(String query) {
    final currentState = state;
    if (currentState is! TournamentLoaded || query.isEmpty) {
      return const [];
    }

    final lowerQuery = query.toLowerCase();
    final suggestions = <String>[];
    final source = currentState.searchMode == TournamentSearchMode.location
        ? currentState.tournaments.map((t) => t.address)
        : currentState.tournaments.map((t) => t.name);

    for (final item in source) {
      final normalized = item.trim();
      if (normalized.isEmpty) continue;
      final alreadyAdded = suggestions.any(
        (existing) => existing.toLowerCase() == normalized.toLowerCase(),
      );
      if (!alreadyAdded && normalized.toLowerCase().contains(lowerQuery)) {
        suggestions.add(normalized);
      }
      if (suggestions.length >= 6) break;
    }

    return suggestions;
  }

  Future<void> handleTournamentRegistration(Tournament tournament) async {
    try {
      emit(TournamentRegistering(tournamentId: tournament.id));

      if (tournament.isRegistered) {
        // Unregister
        await unregisterFromTournament(tournament.id);

        // Update the tournament in the list
        final currentState = state;
        if (currentState is TournamentLoaded) {
          final updatedTournaments = currentState.tournaments.map((t) {
            if (t.id == tournament.id) {
              return t.copyWith(alreadyEnrolled: 0);
            }
            return t;
          }).toList();

          emit(currentState.copyWith(tournaments: updatedTournaments));
          emit(
            TournamentRegistrationSuccess(
              tournament: tournament.copyWith(alreadyEnrolled: 0),
              wasRegistered: false,
            ),
          );
        }
      } else {
        // Register
        await registerForTournament(tournament.id);

        // Update the tournament in the list
        final currentState = state;
        if (currentState is TournamentLoaded) {
          final updatedTournaments = currentState.tournaments.map((t) {
            if (t.id == tournament.id) {
              return t.copyWith(alreadyEnrolled: 1);
            }
            return t;
          }).toList();

          emit(currentState.copyWith(tournaments: updatedTournaments));
          emit(
            TournamentRegistrationSuccess(
              tournament: tournament.copyWith(alreadyEnrolled: 1),
              wasRegistered: true,
            ),
          );
        }
      }

      // Return to loaded state after a brief delay
      await Future.delayed(const Duration(milliseconds: 500));
      await refreshTournaments();
    } catch (e) {
      emit(TournamentError(message: e.toString()));
      await Future.delayed(const Duration(seconds: 2));
      await refreshTournaments();
    }
  }

  Future<void> createNewTournament({
    required String name,
    required String startDate,
    required String regDeadline,
    required String regFee,
    required String address,
    required String format,
    required int participantsCount,
    required String accessType,
    required String tournamentType,
    double? average,
    double? percentage,
  }) async {
    try {
      emit(TournamentLoading());

      await createTournament(
        name: name,
        startDate: startDate,
        regDeadline: regDeadline,
        regFee: regFee,
        address: address,
        format: format,
        participantsCount: participantsCount,
        accessType: accessType,
        tournamentType: tournamentType,
        average: average,
        percentage: percentage,
      );

      // Refresh the tournaments list after creation
      await loadTournaments();
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }
}

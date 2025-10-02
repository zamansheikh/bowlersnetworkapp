import 'package:equatable/equatable.dart';
import '../../domain/entities/tournament.dart';

enum TournamentSearchMode { name, location }

abstract class TournamentState extends Equatable {
  const TournamentState();

  @override
  List<Object?> get props => [];
}

class TournamentInitial extends TournamentState {}

class TournamentLoading extends TournamentState {}

class TournamentLoaded extends TournamentState {
  final List<Tournament> tournaments;
  final String activeTab; // 'All Tournament', 'Registered', 'Available'
  final String searchTerm;
  final List<String>
  selectedFormats; // Filter by format (Singles, Doubles, Teams)
  final List<String> selectedAccessLevels; // Filter by access level/price
  final TournamentSearchMode searchMode;

  const TournamentLoaded({
    required this.tournaments,
    this.activeTab = 'All Tournament',
    this.searchTerm = '',
    this.selectedFormats = const [],
    this.selectedAccessLevels = const [],
    this.searchMode = TournamentSearchMode.name,
  });

  TournamentLoaded copyWith({
    List<Tournament>? tournaments,
    String? activeTab,
    String? searchTerm,
    List<String>? selectedFormats,
    List<String>? selectedAccessLevels,
    TournamentSearchMode? searchMode,
  }) {
    return TournamentLoaded(
      tournaments: tournaments ?? this.tournaments,
      activeTab: activeTab ?? this.activeTab,
      searchTerm: searchTerm ?? this.searchTerm,
      selectedFormats: selectedFormats ?? this.selectedFormats,
      selectedAccessLevels: selectedAccessLevels ?? this.selectedAccessLevels,
      searchMode: searchMode ?? this.searchMode,
    );
  }

  List<Tournament> get filteredTournaments {
    var filtered = tournaments;

    // Filter by tab
    switch (activeTab) {
      case 'Registered':
        filtered = filtered.where((t) => t.isRegistered).toList();
        break;
      case 'Available':
        filtered = filtered.where((t) => !t.isRegistered).toList();
        break;
      default: // 'All Tournament'
        break;
    }

    // Filter by search term
    if (searchTerm.isNotEmpty) {
      final lowerQuery = searchTerm.toLowerCase();
      filtered = filtered.where((tournament) {
        if (searchMode == TournamentSearchMode.location) {
          return tournament.address.toLowerCase().contains(lowerQuery);
        }
        return tournament.name.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    // Filter by format
    if (selectedFormats.isNotEmpty) {
      filtered = filtered.where((tournament) {
        return selectedFormats.contains(tournament.format);
      }).toList();
    }

    // Filter by access level (registration fee)
    if (selectedAccessLevels.contains('Under \$50')) {
      filtered = filtered
          .where((tournament) => tournament.regFee < 50)
          .toList();
    }

    return filtered;
  }

  @override
  List<Object?> get props => [
    tournaments,
    activeTab,
    searchTerm,
    selectedFormats,
    selectedAccessLevels,
    searchMode,
  ];
}

class TournamentError extends TournamentState {
  final String message;

  const TournamentError({required this.message});

  @override
  List<Object> get props => [message];
}

class TournamentRegistering extends TournamentState {
  final int tournamentId;

  const TournamentRegistering({required this.tournamentId});

  @override
  List<Object> get props => [tournamentId];
}

class TournamentRegistrationSuccess extends TournamentState {
  final Tournament tournament;
  final bool
  wasRegistered; // true if just registered, false if just unregistered

  const TournamentRegistrationSuccess({
    required this.tournament,
    required this.wasRegistered,
  });

  @override
  List<Object> get props => [tournament, wasRegistered];
}

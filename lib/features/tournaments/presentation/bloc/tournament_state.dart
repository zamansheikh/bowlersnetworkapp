import 'package:equatable/equatable.dart';
import '../../domain/entities/tournament.dart';
import '../../../../core/utils/location_utils.dart';

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
  final double? selectedLat; // Selected location latitude for filtering
  final double? selectedLng; // Selected location longitude for filtering
  final String? selectedLocationName; // Name of selected location for display

  const TournamentLoaded({
    required this.tournaments,
    this.activeTab = 'All Tournament',
    this.searchTerm = '',
    this.selectedFormats = const [],
    this.selectedAccessLevels = const [],
    this.searchMode = TournamentSearchMode.name,
    this.selectedLat,
    this.selectedLng,
    this.selectedLocationName,
  });

  TournamentLoaded copyWith({
    List<Tournament>? tournaments,
    String? activeTab,
    String? searchTerm,
    List<String>? selectedFormats,
    List<String>? selectedAccessLevels,
    TournamentSearchMode? searchMode,
    double? selectedLat,
    double? selectedLng,
    String? selectedLocationName,
  }) {
    return TournamentLoaded(
      tournaments: tournaments ?? this.tournaments,
      activeTab: activeTab ?? this.activeTab,
      searchTerm: searchTerm ?? this.searchTerm,
      selectedFormats: selectedFormats ?? this.selectedFormats,
      selectedAccessLevels: selectedAccessLevels ?? this.selectedAccessLevels,
      searchMode: searchMode ?? this.searchMode,
      selectedLat: selectedLat ?? this.selectedLat,
      selectedLng: selectedLng ?? this.selectedLng,
      selectedLocationName: selectedLocationName ?? this.selectedLocationName,
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
          // If we have selected coordinates, filter by distance
          if (selectedLat != null && selectedLng != null) {
            // Parse tournament coordinates
            final tournamentLat = double.tryParse(tournament.lat ?? '0');
            final tournamentLng = double.tryParse(tournament.long ?? '0');

            if (tournamentLat != null && tournamentLng != null) {
              // Check if tournament is within 10 miles
              final isWithin10Miles = LocationUtils.isWithinRadius(
                selectedLat!,
                selectedLng!,
                tournamentLat,
                tournamentLng,
                10.0, // 10 miles radius
              );

              // Also check if address matches search term for additional filtering
              final addressMatches = tournament.address.toLowerCase().contains(
                lowerQuery,
              );
              return isWithin10Miles && (lowerQuery.isEmpty || addressMatches);
            }
          }
          // Fallback to address search if no coordinates
          return tournament.address.toLowerCase().contains(lowerQuery);
        }
        return tournament.name.toLowerCase().contains(lowerQuery);
      }).toList();
    } else if (searchMode == TournamentSearchMode.location &&
        selectedLat != null &&
        selectedLng != null) {
      // If no search term but location is selected, show all tournaments within 10 miles
      filtered = filtered.where((tournament) {
        final tournamentLat = double.tryParse(tournament.lat ?? '0');
        final tournamentLng = double.tryParse(tournament.long ?? '0');

        if (tournamentLat != null && tournamentLng != null) {
          return LocationUtils.isWithinRadius(
            selectedLat!,
            selectedLng!,
            tournamentLat,
            tournamentLng,
            10.0, // 10 miles radius
          );
        }
        return false; // Exclude tournaments without valid coordinates
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
    selectedLat,
    selectedLng,
    selectedLocationName,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/get_tournaments.dart';
import '../../domain/usecases/get_calendar_events.dart';
import '../../domain/usecases/toggle_interest.dart';
import '../../../../core/utils/location_utils.dart';
import 'events_state.dart';

@injectable
class EventsCubit extends Cubit<EventsState> {
  final GetTournaments getTournaments;
  final GetCalendarEvents getCalendarEvents;
  final ToggleInterest toggleInterestUseCase;

  EventsCubit({
    required this.getTournaments,
    required this.getCalendarEvents,
    required this.toggleInterestUseCase,
  }) : super(EventsInitial());

  Future<void> loadEvents() async {
    try {
      emit(EventsLoading());

      debugPrint('🏆 EventsCubit: Loading events...');

      // final tournaments = await getTournaments();
      final events = await getCalendarEvents();

      // debugPrint('🏆 EventsCubit: Loaded ${tournaments.length} tournaments');
      debugPrint('🏆 EventsCubit: Loaded ${events.length} events');

      emit(
        EventsLoaded(
          tournaments: [], // Tournaments are now part of events feed
          events: events,
          currentDate: DateTime.now(),
          searchMode: EventSearchMode.eventName,
        ),
      );
    } catch (e) {
      debugPrint('🏆 EventsCubit: Error loading events: $e');
      emit(EventsError('Failed to load events: $e'));
    }
  }

  void selectDate(DateTime date) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      emit(current.copyWith(selectedDate: date));
    }
  }

  void clearSelectedDate() {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      emit(current.copyWith(clearSelectedDate: true));
    }
  }

  void navigateMonth(bool next) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      final newDate = DateTime(
        current.currentDate.year,
        current.currentDate.month + (next ? 1 : -1),
        1,
      );
      emit(current.copyWith(currentDate: newDate));
    }
  }

  void setCurrentDate(DateTime date) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      emit(current.copyWith(currentDate: date));
    }
  }

  void updateSearch(String searchTerm, {double? lat, double? lng}) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      emit(
        current.copyWith(
          searchTerm: searchTerm,
          selectedLat: lat,
          selectedLng: lng,
        ),
      );
    }
  }

  void updateSearchMode(EventSearchMode mode) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      emit(
        current.copyWith(
          searchMode: mode,
          searchTerm: '',
          clearLocation: true,
          clearSelectedDate: true, // Reset date selection when switching modes
        ),
      );
    }
  }

  void updateFilter(EventType? filterType) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      emit(current.copyWith(filterType: filterType));
    }
  }

  void clearFilter() {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      emit(current.copyWith(clearFilterType: true));
    }
  }

  List<CalendarEvent> getEventsForDate(DateTime date) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      final dateString = date.toIso8601String().split('T')[0];
      return current.events.where((event) => event.date == dateString).toList();
    }
    return [];
  }

  List<CalendarEvent> getFilteredEvents(DateTime? selectedDate) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;

      List<CalendarEvent> filteredEvents = current.events;

      // Filter by selected date
      if (selectedDate != null) {
        final dateString = selectedDate.toIso8601String().split('T')[0];
        filteredEvents = filteredEvents
            .where((event) => event.date == dateString)
            .toList();
      }

      // Filter by type
      if (current.filterType != null) {
        filteredEvents = filteredEvents
            .where((event) => event.type == current.filterType)
            .toList();
      }

      // Filter by search term
      if (current.searchTerm.isNotEmpty) {
        final searchLower = current.searchTerm.toLowerCase();
        if (current.searchMode == EventSearchMode.eventName) {
          filteredEvents = filteredEvents
              .where(
                (event) =>
                    event.title.toLowerCase().contains(searchLower) ||
                    event.description.toLowerCase().contains(searchLower),
              )
              .toList();
        } else {
          filteredEvents = filteredEvents
              .where(
                (event) => event.location.toLowerCase().contains(searchLower),
              )
              .toList();
        }
      }

      return filteredEvents;
    }
    return [];
  }

  List<String> getSearchSuggestions(String query) {
    if (state is! EventsLoaded || query.isEmpty) return const [];

    final current = state as EventsLoaded;
    final lowerQuery = query.toLowerCase();
    final suggestions = <String>[];

    if (current.searchMode == EventSearchMode.location) {
      // Add unique tournament addresses
      final tournamentAddresses = current.tournaments
          .where((t) => t.address.trim().isNotEmpty)
          .map((t) => t.address.trim())
          .toSet()
          .toList();

      for (final address in tournamentAddresses) {
        if (address.toLowerCase().contains(lowerQuery)) {
          suggestions.add(address);
        }
        if (suggestions.length >= 10) break;
      }

      // Add event locations if needed
      if (suggestions.length < 10) {
        for (final event in current.events) {
          final location = event.location.trim();
          if (location.isEmpty) continue;
          final alreadyAdded = suggestions.any(
            (existing) => existing.toLowerCase() == location.toLowerCase(),
          );
          if (!alreadyAdded && location.toLowerCase().contains(lowerQuery)) {
            suggestions.add(location);
          }
          if (suggestions.length >= 10) break;
        }
      }
    } else {
      // Event name search
      final source = current.events.map((event) => event.title);
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
    }

    return suggestions;
  }

  int getEventCountForMonth(DateTime date) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      return current.events.where((event) {
        final eventDate = DateTime.parse(event.date);
        return eventDate.year == date.year && eventDate.month == date.month;
      }).length;
    }
    return 0;
  }

  int getEventCountByType(EventType type, DateTime date) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      return current.events.where((event) {
        final eventDate = DateTime.parse(event.date);
        return event.type == type &&
            eventDate.year == date.year &&
            eventDate.month == date.month;
      }).length;
    }
    return 0;
  }

  Future<void> toggleInterest(String eventId) async {
    if (state is! EventsLoaded) return;

    final currentState = state as EventsLoaded;
    final events = List<CalendarEvent>.from(currentState.events);
    final index = events.indexWhere((e) => e.id == eventId);

    if (index == -1) return;

    final event = events[index];
    final wasInterested = event.isInterested;

    // Optimistic update
    events[index] = CalendarEvent(
      id: event.id,
      title: event.title,
      type: event.type,
      date: event.date,
      time: event.time,
      endTime: event.endTime,
      description: event.description,
      location: event.location,
      participants: event.participants,
      maxParticipants: event.maxParticipants,
      entryFee: event.entryFee,
      prizePool: event.prizePool,
      status: event.status,
      priority: event.priority,
      organizer: event.organizer,
      registrationDeadline: event.registrationDeadline,
      format: event.format,
      gameType: event.gameType,
      flyerUrl: event.flyerUrl,
      isInterested: !wasInterested,
      totalInterested: wasInterested
          ? (event.totalInterested > 0 ? event.totalInterested - 1 : 0)
          : event.totalInterested + 1,
      organizerJson: event.organizerJson,
      centerJson: event.centerJson,
    );

    emit(currentState.copyWith(events: events));

    try {
      await toggleInterestUseCase(eventId);
    } catch (e) {
      // Revert if failed
      events[index] = event; // original event
      emit(currentState.copyWith(events: events));
    }
  }

  /// Get filtered tournaments based on search criteria
  /// For location search with coordinates, filters by 50km (~31 miles) radius
  List<dynamic> getFilteredTournaments() {
    if (state is! EventsLoaded) return [];

    final current = state as EventsLoaded;
    var filtered = current.tournaments.toList();

    // Filter by search term
    if (current.searchTerm.isNotEmpty) {
      final searchLower = current.searchTerm.toLowerCase();

      if (current.searchMode == EventSearchMode.eventName) {
        // Filter by tournament name
        filtered = filtered
            .where((t) => t.name.toLowerCase().contains(searchLower))
            .toList();
      } else if (current.searchMode == EventSearchMode.location) {
        // Filter by location
        if (current.selectedLat != null && current.selectedLng != null) {
          // Location-based filtering with 50km radius (~31 miles)
          const radiusMiles = 31.0; // 50km
          final centerLat = current.selectedLat!;
          final centerLng = current.selectedLng!;

          filtered = filtered.where((tournament) {
            // Check if tournament has coordinates
            if (tournament.lat == null || tournament.long == null) {
              // Include if address matches search term (fallback)
              return tournament.address.toLowerCase().contains(searchLower);
            }

            try {
              final tournamentLat = double.parse(tournament.lat!);
              final tournamentLng = double.parse(tournament.long!);

              // Check if within radius
              return LocationUtils.isWithinRadius(
                centerLat,
                centerLng,
                tournamentLat,
                tournamentLng,
                radiusMiles,
              );
            } catch (e) {
              // If parsing fails, fallback to address matching
              return tournament.address.toLowerCase().contains(searchLower);
            }
          }).toList();
        } else {
          // No coordinates, just filter by address text
          filtered = filtered
              .where((t) => t.address.toLowerCase().contains(searchLower))
              .toList();
        }
      }
    }

    return filtered;
  }
}

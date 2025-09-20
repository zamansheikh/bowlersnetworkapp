import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/get_tournaments.dart';
import '../../domain/usecases/get_calendar_events.dart';
import 'events_state.dart';

@injectable
class EventsCubit extends Cubit<EventsState> {
  final GetTournaments getTournaments;
  final GetCalendarEvents getCalendarEvents;

  EventsCubit({required this.getTournaments, required this.getCalendarEvents})
    : super(EventsInitial());

  Future<void> loadEvents() async {
    try {
      emit(EventsLoading());

      print('🏆 EventsCubit: Loading events...');

      final tournaments = await getTournaments();
      final events = await getCalendarEvents();

      print('🏆 EventsCubit: Loaded ${tournaments.length} tournaments');
      print('🏆 EventsCubit: Loaded ${events.length} events');

      emit(
        EventsLoaded(
          tournaments: tournaments,
          events: events,
          currentDate: DateTime.now(),
        ),
      );
    } catch (e) {
      print('🏆 EventsCubit: Error loading events: $e');
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

  void updateSearch(String searchTerm) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      emit(current.copyWith(searchTerm: searchTerm));
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
        filteredEvents = filteredEvents
            .where(
              (event) =>
                  event.title.toLowerCase().contains(searchLower) ||
                  event.description.toLowerCase().contains(searchLower),
            )
            .toList();
      }

      return filteredEvents;
    }
    return [];
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
}

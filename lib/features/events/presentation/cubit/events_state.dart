import 'package:equatable/equatable.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/tournament.dart';

abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<Tournament> tournaments;
  final List<CalendarEvent> events;
  final DateTime currentDate;
  final DateTime? selectedDate;
  final String searchTerm;
  final EventType? filterType;

  const EventsLoaded({
    required this.tournaments,
    required this.events,
    required this.currentDate,
    this.selectedDate,
    this.searchTerm = '',
    this.filterType,
  });

  EventsLoaded copyWith({
    List<Tournament>? tournaments,
    List<CalendarEvent>? events,
    DateTime? currentDate,
    DateTime? selectedDate,
    String? searchTerm,
    EventType? filterType,
    bool clearSelectedDate = false,
    bool clearFilterType = false,
  }) {
    return EventsLoaded(
      tournaments: tournaments ?? this.tournaments,
      events: events ?? this.events,
      currentDate: currentDate ?? this.currentDate,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      searchTerm: searchTerm ?? this.searchTerm,
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
    );
  }

  @override
  List<Object?> get props => [
        tournaments,
        events,
        currentDate,
        selectedDate,
        searchTerm,
        filterType,
      ];
}

class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);

  @override
  List<Object> get props => [message];
}
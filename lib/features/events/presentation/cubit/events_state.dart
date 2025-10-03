import 'package:equatable/equatable.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/tournament.dart';

enum EventSearchMode { eventName, location }

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
  final EventSearchMode searchMode;
  final double? selectedLat;
  final double? selectedLng;

  const EventsLoaded({
    required this.tournaments,
    required this.events,
    required this.currentDate,
    this.selectedDate,
    this.searchTerm = '',
    this.filterType,
    this.searchMode = EventSearchMode.eventName,
    this.selectedLat,
    this.selectedLng,
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
    EventSearchMode? searchMode,
    double? selectedLat,
    double? selectedLng,
    bool clearLocation = false,
  }) {
    return EventsLoaded(
      tournaments: tournaments ?? this.tournaments,
      events: events ?? this.events,
      currentDate: currentDate ?? this.currentDate,
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
      searchTerm: searchTerm ?? this.searchTerm,
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
      searchMode: searchMode ?? this.searchMode,
      selectedLat: clearLocation ? null : (selectedLat ?? this.selectedLat),
      selectedLng: clearLocation ? null : (selectedLng ?? this.selectedLng),
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
    searchMode,
    selectedLat,
    selectedLng,
  ];
}

class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);

  @override
  List<Object> get props => [message];
}

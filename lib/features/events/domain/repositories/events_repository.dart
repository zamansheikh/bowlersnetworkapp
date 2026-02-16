import '../../domain/entities/tournament.dart';
import '../../domain/entities/calendar_event.dart';

abstract class EventsRepository {
  Future<List<Tournament>> getTournaments();
  Future<List<CalendarEvent>> getCalendarEvents();
  Future<void> toggleInterest(String eventId);
  Future<void> registerForTournament(int tournamentId);
  Future<void> unregisterFromTournament(int tournamentId);
}

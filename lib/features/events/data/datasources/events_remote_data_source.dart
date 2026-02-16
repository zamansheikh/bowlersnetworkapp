import '../models/tournament_model.dart';
import '../models/calendar_event_model.dart';

abstract class EventsRemoteDataSource {
  Future<List<TournamentModel>> getTournaments();
  Future<List<CalendarEventModel>> getEventsFeed();
  Future<void> toggleInterest(String eventId);
  Future<void> registerForTournament(int tournamentId);
  Future<void> unregisterFromTournament(int tournamentId);
}

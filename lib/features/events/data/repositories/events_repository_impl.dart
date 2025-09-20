import 'package:injectable/injectable.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_remote_data_source.dart';
import '../models/calendar_event_model.dart';

@LazySingleton(as: EventsRepository)
class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDataSource remoteDataSource;

  EventsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Tournament>> getTournaments() async {
    try {
      final tournamentModels = await remoteDataSource.getTournaments();
      return tournamentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch tournaments: $e');
    }
  }

  @override
  Future<List<CalendarEvent>> getCalendarEvents() async {
    try {
      final tournaments = await getTournaments();
      // Convert tournaments to calendar events
      return tournaments
          .map((tournament) => CalendarEventModel.fromTournament(tournament))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch calendar events: $e');
    }
  }

  @override
  Future<void> registerForTournament(int tournamentId) async {
    try {
      await remoteDataSource.registerForTournament(tournamentId);
    } catch (e) {
      throw Exception('Failed to register for tournament: $e');
    }
  }

  @override
  Future<void> unregisterFromTournament(int tournamentId) async {
    try {
      await remoteDataSource.unregisterFromTournament(tournamentId);
    } catch (e) {
      throw Exception('Failed to unregister from tournament: $e');
    }
  }
}
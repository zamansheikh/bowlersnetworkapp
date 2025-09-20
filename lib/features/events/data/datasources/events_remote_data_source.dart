import '../models/tournament_model.dart';

abstract class EventsRemoteDataSource {
  Future<List<TournamentModel>> getTournaments();
  Future<void> registerForTournament(int tournamentId);
  Future<void> unregisterFromTournament(int tournamentId);
}

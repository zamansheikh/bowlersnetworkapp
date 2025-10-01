import '../../domain/entities/tournament.dart';

abstract class TournamentRemoteDataSource {
  Future<List<Tournament>> getTournaments();
  Future<Tournament> getTournamentById(int id);
  Future<void> registerForTournament(int tournamentId);
  Future<void> unregisterFromTournament(int tournamentId);
  Future<Tournament> createTournament({
    required String name,
    required String startDate,
    required String regDeadline,
    required String regFee,
    required String address,
    required String format,
    required int participantsCount,
    required String accessType,
  });
  Future<List<Tournament>> getUserRegisteredTournaments();
  Future<List<Tournament>> getAvailableTournaments();
}

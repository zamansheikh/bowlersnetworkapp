import 'package:injectable/injectable.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../datasources/tournament_remote_data_source.dart';

@Injectable(as: TournamentRepository)
class TournamentRepositoryImpl implements TournamentRepository {
  final TournamentRemoteDataSource remoteDataSource;

  TournamentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Tournament>> getTournaments() async {
    try {
      return await remoteDataSource.getTournaments();
    } catch (e) {
      throw Exception('Failed to fetch tournaments: $e');
    }
  }

  @override
  Future<Tournament> getTournamentById(int id) async {
    try {
      return await remoteDataSource.getTournamentById(id);
    } catch (e) {
      throw Exception('Failed to fetch tournament: $e');
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

  @override
  Future<Tournament> createTournament({
    required String name,
    required String startDate,
    required String regDeadline,
    required String regFee,
    required String address,
    String? lat,
    String? long,
    required int participantsCount,
    required String accessType,
    required String tournamentType,
    double? average,
    double? percentage,
  }) async {
    try {
      return await remoteDataSource.createTournament(
        name: name,
        startDate: startDate,
        regDeadline: regDeadline,
        regFee: regFee,
        address: address,
        lat: lat,
        long: long,
        participantsCount: participantsCount,
        accessType: accessType,
        tournamentType: tournamentType,
        average: average,
        percentage: percentage,
      );
    } catch (e) {
      throw Exception('Failed to create tournament: $e');
    }
  }

  @override
  Future<List<Tournament>> getUserRegisteredTournaments() async {
    try {
      return await remoteDataSource.getUserRegisteredTournaments();
    } catch (e) {
      throw Exception('Failed to fetch registered tournaments: $e');
    }
  }

  @override
  Future<List<Tournament>> getAvailableTournaments() async {
    try {
      return await remoteDataSource.getAvailableTournaments();
    } catch (e) {
      throw Exception('Failed to fetch available tournaments: $e');
    }
  }

  @override
  Future<void> registerSinglesForTournament(
    int tournamentId,
    int playerId,
  ) async {
    try {
      return await remoteDataSource.registerSinglesForTournament(
        tournamentId,
        playerId,
      );
    } catch (e) {
      throw Exception('Failed to register for singles tournament: $e');
    }
  }

  @override
  Future<void> registerTeamForTournament(int tournamentId, int teamId) async {
    try {
      return await remoteDataSource.registerTeamForTournament(
        tournamentId,
        teamId,
      );
    } catch (e) {
      throw Exception('Failed to register team for tournament: $e');
    }
  }
}

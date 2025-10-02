import 'package:injectable/injectable.dart';
import '../entities/tournament.dart';
import '../repositories/tournament_repository.dart';

@injectable
class GetTournamentsUseCase {
  final TournamentRepository repository;

  GetTournamentsUseCase({required this.repository});

  Future<List<Tournament>> call() async {
    return await repository.getTournaments();
  }
}

@injectable
class GetTournamentByIdUseCase {
  final TournamentRepository repository;

  GetTournamentByIdUseCase({required this.repository});

  Future<Tournament> call(int id) async {
    return await repository.getTournamentById(id);
  }
}

@injectable
class RegisterForTournamentUseCase {
  final TournamentRepository repository;

  RegisterForTournamentUseCase({required this.repository});

  Future<void> call(int tournamentId) async {
    return await repository.registerForTournament(tournamentId);
  }
}

@injectable
class UnregisterFromTournamentUseCase {
  final TournamentRepository repository;

  UnregisterFromTournamentUseCase({required this.repository});

  Future<void> call(int tournamentId) async {
    return await repository.unregisterFromTournament(tournamentId);
  }
}

@injectable
class CreateTournamentUseCase {
  final TournamentRepository repository;

  CreateTournamentUseCase({required this.repository});

  Future<Tournament> call({
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
    return await repository.createTournament(
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
  }
}

@injectable
class GetUserRegisteredTournamentsUseCase {
  final TournamentRepository repository;

  GetUserRegisteredTournamentsUseCase({required this.repository});

  Future<List<Tournament>> call() async {
    return await repository.getUserRegisteredTournaments();
  }
}

@injectable
class GetAvailableTournamentsUseCase {
  final TournamentRepository repository;

  GetAvailableTournamentsUseCase({required this.repository});

  Future<List<Tournament>> call() async {
    return await repository.getAvailableTournaments();
  }
}

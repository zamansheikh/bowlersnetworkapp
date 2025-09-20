import 'package:injectable/injectable.dart';
import '../../domain/entities/tournament.dart';
import '../../domain/repositories/events_repository.dart';

@injectable
class GetTournaments {
  final EventsRepository repository;

  GetTournaments(this.repository);

  Future<List<Tournament>> call() async {
    return await repository.getTournaments();
  }
}

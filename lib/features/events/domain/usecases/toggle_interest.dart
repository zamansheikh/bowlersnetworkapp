import 'package:injectable/injectable.dart';
import '../repositories/events_repository.dart';

@lazySingleton
class ToggleInterest {
  final EventsRepository repository;

  ToggleInterest(this.repository);

  Future<void> call(String eventId) async {
    return repository.toggleInterest(eventId);
  }
}

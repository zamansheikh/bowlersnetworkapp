import 'package:injectable/injectable.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/events_repository.dart';

@injectable
class GetCalendarEvents {
  final EventsRepository repository;

  GetCalendarEvents(this.repository);

  Future<List<CalendarEvent>> call() async {
    return await repository.getCalendarEvents();
  }
}

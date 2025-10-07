import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/tournament.dart';
import 'package:intl/intl.dart';

class CalendarEventModel extends CalendarEvent {
  const CalendarEventModel({
    required super.id,
    required super.title,
    required super.type,
    required super.date,
    required super.time,
    super.endTime,
    required super.description,
    required super.location,
    required super.participants,
    super.maxParticipants,
    super.entryFee,
    super.prizePool,
    required super.status,
    required super.priority,
    required super.organizer,
    super.registrationDeadline,
    super.format,
    super.gameType,
  });

  // Convert Tournament to CalendarEvent
  factory CalendarEventModel.fromTournament(Tournament tournament) {
    final startDate = DateTime.parse(tournament.startDate);
    final regDeadline = DateTime.parse(tournament.regDeadline);
    final now = DateTime.now();

    return CalendarEventModel(
      id: tournament.id.toString(),
      title: tournament.name,
      type: EventType.tournament,
      date: tournament.startDate.split('T')[0], // Extract date part
      time: DateFormat('h:mm a').format(startDate),
      endTime: DateFormat('h:mm a').format(regDeadline),
      description:
          '${tournament.format} tournament. Registration fee: \$${tournament.regFee}',
      location: tournament.address.isNotEmpty
          ? tournament.address
          : 'Location TBD',
      participants: tournament.alreadyEnrolled,
      maxParticipants: tournament.participantsCount,
      entryFee: tournament.regFee,
      prizePool: null, // Not available in tournament data
      status: regDeadline.isAfter(now)
          ? EventStatus.upcoming
          : EventStatus.completed,
      priority: tournament.regFee > 50
          ? EventPriority.high
          : EventPriority.medium,
      organizer: 'Tournament Committee',
      registrationDeadline: tournament.regDeadline.split(
        'T',
      )[0], // Extract date part
      format: tournament.format,
      gameType: 'Tournament',
    );
  }

  CalendarEvent toEntity() => CalendarEvent(
    id: id,
    title: title,
    type: type,
    date: date,
    time: time,
    endTime: endTime,
    description: description,
    location: location,
    participants: participants,
    maxParticipants: maxParticipants,
    entryFee: entryFee,
    prizePool: prizePool,
    status: status,
    priority: priority,
    organizer: organizer,
    registrationDeadline: registrationDeadline,
    format: format,
    gameType: gameType,
  );
}

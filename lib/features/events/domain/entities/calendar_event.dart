import 'package:equatable/equatable.dart';

enum EventType { tournament, league, special, practice, maintenance }

enum EventStatus { upcoming, ongoing, completed, cancelled }

enum EventPriority { high, medium, low }

class CalendarEvent extends Equatable {
  final String id;
  final String title;
  final EventType type;
  final String date;
  final String time;
  final String? endTime;
  final String description;
  final String location;
  final int participants;
  final int? maxParticipants;
  final double? entryFee;
  final double? prizePool;
  final EventStatus status;
  final EventPriority priority;
  final String organizer;
  final String? registrationDeadline;
  final String? format;
  final String? gameType;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.time,
    this.endTime,
    required this.description,
    required this.location,
    required this.participants,
    this.maxParticipants,
    this.entryFee,
    this.prizePool,
    required this.status,
    required this.priority,
    required this.organizer,
    this.registrationDeadline,
    this.format,
    this.gameType,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    type,
    date,
    time,
    endTime,
    description,
    location,
    participants,
    maxParticipants,
    entryFee,
    prizePool,
    status,
    priority,
    organizer,
    registrationDeadline,
    format,
    gameType,
  ];
}

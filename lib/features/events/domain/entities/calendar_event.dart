import 'package:equatable/equatable.dart';

enum EventType { tournament, league, special, practice, maintenance, userEvent }

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
  final String? flyerUrl;
  final bool isInterested;
  final int totalInterested;
  final Map<String, dynamic>? organizerJson;
  final Map<String, dynamic>? centerJson;
  final double? lat;
  final double? lng;

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
    this.flyerUrl,
    this.isInterested = false,
    this.totalInterested = 0,
    this.organizerJson,
    this.centerJson,
    this.lat,
    this.lng,
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
    flyerUrl,
    isInterested,
    totalInterested,
    organizerJson,
    centerJson,
    lat,
    lng,
  ];
}

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
    super.flyerUrl,
    super.isInterested,
    super.totalInterested = 0,
    super.organizerJson,
    super.centerJson,
    super.lat,
    super.lng,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    // Parse event date time
    final eventDateTime = DateTime.parse(json['event_datetime']);
    final now = DateTime.now();
    final isPast = eventDateTime.isBefore(now);

    // Determine location string and coordinates
    String locationStr = 'Unknown Location';
    double? latitude;
    double? longitude;

    if (json['location'] != null) {
      locationStr = json['location']['address_str'] ?? '';
      latitude = double.tryParse(json['location']['lat']?.toString() ?? '');
      longitude = double.tryParse(json['location']['long']?.toString() ?? '');
    } else if (json['center'] != null) {
      locationStr =
          '${json['center']['name'] ?? ''}, ${json['center']['address'] ?? ''}';
      latitude = double.tryParse(json['center']['lat']?.toString() ?? '');
      longitude = double.tryParse(json['center']['long']?.toString() ?? '');
    }

    // Determine event type
    EventType eventType = EventType.userEvent;
    final meta = json['meta'];
    if (meta != null && meta['event_type'] != null) {
      final typeStr = meta['event_type'].toString().toLowerCase();
      if (typeStr.contains('tournament')) {
        eventType = EventType.tournament;
      } else if (typeStr.contains('league')) {
        eventType = EventType.league;
      } else if (typeStr.contains('practice')) {
        eventType = EventType.practice;
      } else if (typeStr.contains('special')) {
        eventType = EventType.special;
      } else if (typeStr.contains('maintenance')) {
        eventType = EventType.maintenance;
      }
    }

    return CalendarEventModel(
      id: json['event_id'].toString(),
      title: json['title'] ?? '',
      type: eventType,
      date: DateFormat('yyyy-MM-dd').format(eventDateTime),
      time: DateFormat('h:mm a').format(eventDateTime),
      endTime: null, // Feed doesn't seem to have end time in this root
      description: json['description'] ?? '',
      location: locationStr,
      participants: (json['total_interested'] as num?)?.toInt() ?? 0,
      status: isPast ? EventStatus.completed : EventStatus.upcoming,
      priority: EventPriority.medium,
      organizer: json['user']?['name'] ?? 'Unknown',
      flyerUrl: json['flyer_url'],
      isInterested: json['is_interested'] as bool? ?? false,
      totalInterested: (json['total_interested'] as num?)?.toInt() ?? 0,
      organizerJson: json['user'],
      centerJson: json['center'],
      lat: latitude,
      lng: longitude,
    );
  }

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
      lat: double.tryParse(tournament.lat ?? ''),
      lng: double.tryParse(tournament.long ?? ''),
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

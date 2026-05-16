import 'package:equatable/equatable.dart';

class EventOrganiser extends Equatable {
  const EventOrganiser({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.rankDisplay,
    this.badgeIconUrl,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final bool isPro;
  final String? rankDisplay;
  final String? badgeIconUrl;

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? username : full;
  }

  @override
  List<Object?> get props => [
        id,
        username,
        firstName,
        lastName,
        profilePictureUrl,
        isPro,
        rankDisplay,
        badgeIconUrl,
      ];
}

class EventCenter extends Equatable {
  const EventCenter({
    required this.id,
    required this.name,
    this.logo,
    this.lanes,
  });
  final int id;
  final String name;
  final String? logo;
  final int? lanes;
  @override
  List<Object?> get props => [id, name, logo, lanes];
}

class EventLocation extends Equatable {
  const EventLocation({
    required this.isCenter,
    this.center,
    this.address = '',
    this.zipCode = '',
    this.latitude,
    this.longitude,
  });

  final bool isCenter;
  final EventCenter? center;
  final String address;
  final String zipCode;
  final double? latitude;
  final double? longitude;

  /// Human-readable single-line label for cards. Prefers the center
  /// name, falls back to street address, then "TBA".
  String get displayLabel {
    if (center != null && center!.name.isNotEmpty) return center!.name;
    if (address.isNotEmpty) return address;
    return 'TBA';
  }

  @override
  List<Object?> get props =>
      [isCenter, center, address, zipCode, latitude, longitude];
}

class EventType extends Equatable {
  const EventType({required this.id, required this.name});
  final int id;
  final String name;
  @override
  List<Object?> get props => [id, name];
}

/// Invitation status the viewer has on a given event. `none` = not
/// invited (or backend returned null).
enum EventInvitationStatus {
  none,
  pending,
  accepted,
  declined;

  static EventInvitationStatus fromString(String? s) {
    switch (s) {
      case 'pending':
        return EventInvitationStatus.pending;
      case 'accepted':
        return EventInvitationStatus.accepted;
      case 'declined':
        return EventInvitationStatus.declined;
      default:
        return EventInvitationStatus.none;
    }
  }
}

class Event extends Equatable {
  const Event({
    required this.uid,
    required this.title,
    this.description = '',
    this.eventType,
    this.creator,
    this.flyerUrl,
    this.isOnline = false,
    this.eventDate,
    this.location,
    this.interestedCount = 0,
    this.goingCount = 0,
    this.notesCount = 0,
    this.isInterested,
    this.invitationStatus = EventInvitationStatus.none,
    this.isCreator,
    this.createdAt,
  });

  final String uid;
  final String title;
  final String description;
  final EventType? eventType;
  final EventOrganiser? creator;
  final String? flyerUrl;
  final bool isOnline;
  final DateTime? eventDate;
  final EventLocation? location;
  final int interestedCount;
  final int goingCount;
  final int notesCount;
  final bool? isInterested;
  final EventInvitationStatus invitationStatus;
  final bool? isCreator;
  final DateTime? createdAt;

  /// Used by the detail bloc for optimistic interest toggling.
  Event withInterest({required bool isInterested, required int count}) =>
      Event(
        uid: uid,
        title: title,
        description: description,
        eventType: eventType,
        creator: creator,
        flyerUrl: flyerUrl,
        isOnline: isOnline,
        eventDate: eventDate,
        location: location,
        interestedCount: count,
        goingCount: goingCount,
        notesCount: notesCount,
        isInterested: isInterested,
        invitationStatus: invitationStatus,
        isCreator: isCreator,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        uid,
        title,
        description,
        eventType,
        creator,
        flyerUrl,
        isOnline,
        eventDate,
        location,
        interestedCount,
        goingCount,
        notesCount,
        isInterested,
        invitationStatus,
        isCreator,
        createdAt,
      ];
}

/// Tabs at the top of the events list, mirroring the web hub. v1 ships
/// the four backend-supported categories; calendar / nearby get their
/// own tabs (with custom infra) in a follow-up.
enum EventCategory {
  trending('trending', 'Trending'),
  upcoming('upcoming', 'Upcoming'),
  joined('joined', 'Joined'),
  created('created', 'Created');

  const EventCategory(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

/// Result of an interest-toggle call.
class EventInterestResult {
  const EventInterestResult({
    required this.isInterested,
    required this.interestedCount,
  });
  final bool isInterested;
  final int interestedCount;
}

/// One Q&A note on an event. `reply` is empty until the event creator
/// answers, at which point `repliedAt` also populates.
class EventNote extends Equatable {
  const EventNote({
    required this.id,
    this.author,
    this.content = '',
    this.reply = '',
    this.repliedAt,
    this.isByCreator = false,
    this.createdAt,
  });

  final int id;
  final EventOrganiser? author;
  final String content;
  final String reply;
  final DateTime? repliedAt;
  final bool isByCreator;
  final DateTime? createdAt;

  bool get hasReply => reply.isNotEmpty;

  EventNote withReply({required String reply, DateTime? repliedAt}) =>
      EventNote(
        id: id,
        author: author,
        content: content,
        reply: reply,
        repliedAt: repliedAt ?? DateTime.now(),
        isByCreator: isByCreator,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        author,
        content,
        reply,
        repliedAt,
        isByCreator,
        createdAt,
      ];
}

/// Status of an invitation in the viewer's inbox.
enum InvitationStatus {
  pending('pending', 'Pending'),
  accepted('accepted', 'Accepted'),
  declined('declined', 'Declined');

  const InvitationStatus(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static InvitationStatus fromString(String? s) {
    switch (s) {
      case 'accepted':
        return InvitationStatus.accepted;
      case 'declined':
        return InvitationStatus.declined;
      default:
        return InvitationStatus.pending;
    }
  }
}

/// One invitation the viewer has received. [eventUid] + [eventTitle]
/// are the thin reference embedded in the invitation payload; full
/// detail loads on tap.
class EventInvitation extends Equatable {
  const EventInvitation({
    required this.id,
    required this.eventUid,
    required this.eventTitle,
    this.eventDate,
    this.status = InvitationStatus.pending,
    this.createdAt,
    this.respondedAt,
  });

  final int id;
  final String eventUid;
  final String eventTitle;
  final DateTime? eventDate;
  final InvitationStatus status;
  final DateTime? createdAt;
  final DateTime? respondedAt;

  EventInvitation withStatus({
    required InvitationStatus status,
    DateTime? respondedAt,
  }) =>
      EventInvitation(
        id: id,
        eventUid: eventUid,
        eventTitle: eventTitle,
        eventDate: eventDate,
        status: status,
        createdAt: createdAt,
        respondedAt: respondedAt ?? DateTime.now(),
      );

  @override
  List<Object?> get props =>
      [id, eventUid, eventTitle, eventDate, status, createdAt, respondedAt];
}

/// Body for `POST /api/events` and `PUT /api/events/{uid}/update`. All
/// location fields are conditional — when `isOnline` is true the
/// backend ignores them; otherwise either [centerId] OR
/// ([latitude]+[longitude]) is required.
class EventEditorDraft extends Equatable {
  const EventEditorDraft({
    required this.title,
    required this.description,
    required this.eventTypeId,
    required this.eventDate,
    this.flyerUrl,
    this.isOnline = false,
    this.centerId,
    this.latitude,
    this.longitude,
    this.addressStr,
    this.zipcode,
  });

  final String title;
  final String description;
  final int eventTypeId;
  final DateTime eventDate;
  final String? flyerUrl;
  final bool isOnline;
  final int? centerId;
  final double? latitude;
  final double? longitude;
  final String? addressStr;
  final String? zipcode;

  /// JSON body forwarded by the repository. Null fields are omitted so
  /// PUT does true partial updates.
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'event_type_id': eventTypeId,
        'event_date': eventDate.toUtc().toIso8601String(),
        'is_online': isOnline,
        'flyer_url': ?flyerUrl,
        'center_id': ?centerId,
        'latitude': ?latitude,
        'longitude': ?longitude,
        'address_str': ?addressStr,
        'zipcode': ?zipcode,
      };

  @override
  List<Object?> get props => [
        title,
        description,
        eventTypeId,
        eventDate,
        flyerUrl,
        isOnline,
        centerId,
        latitude,
        longitude,
        addressStr,
        zipcode,
      ];
}

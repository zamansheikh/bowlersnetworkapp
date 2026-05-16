import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/event.dart';

abstract class EventsRepository {
  // ── Browse ───────────────────────────────────────────────────────────────

  Future<Either<Failure, ({List<Event> events, bool hasMore})>>
      getEventsFeed({
    required EventCategory category,
    int page = 1,
    int pageSize = 20,
  });

  /// Events the viewer has created.
  Future<Either<Failure, ({List<Event> events, bool hasMore})>>
      getMyEvents({
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, List<EventType>>> getEventTypes();

  Future<Either<Failure, Event>> getEvent(String uid);

  // ── CRUD ─────────────────────────────────────────────────────────────────

  Future<Either<Failure, Event>> createEvent(EventEditorDraft draft);

  Future<Either<Failure, Event>> updateEvent({
    required String uid,
    required EventEditorDraft draft,
  });

  Future<Either<Failure, Unit>> deleteEvent(String uid);

  // ── Interest / attendees ─────────────────────────────────────────────────

  Future<Either<Failure, EventInterestResult>> toggleInterest(String uid);

  Future<Either<Failure, ({List<EventOrganiser> users, bool hasMore})>>
      getInterestedUsers({
    required String uid,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, ({List<EventOrganiser> users, bool hasMore})>>
      getGoingUsers({
    required String uid,
    int page = 1,
    int pageSize = 20,
  });

  // ── Invitations ──────────────────────────────────────────────────────────

  /// Viewer's invitation inbox (all statuses, newest first).
  Future<Either<Failure, ({List<EventInvitation> invitations, bool hasMore})>>
      getInvitations({
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, EventInvitation>> respondToInvitation({
    required int invitationId,
    required InvitationStatus status,
  });

  /// Send invitations to a list of user ids. Returns the count the
  /// backend actually created (already-invited users are silently
  /// skipped).
  Future<Either<Failure, int>> sendInvitations({
    required String uid,
    required List<int> userIds,
  });

  /// Slim list of users the creator can invite. No filters in v1.
  Future<Either<Failure, List<EventOrganiser>>> discoverInviteCandidates(
    String uid,
  );

  // ── Notes (Q&A) ──────────────────────────────────────────────────────────

  Future<Either<Failure, ({List<EventNote> notes, bool hasMore})>> getNotes({
    required String uid,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, EventNote>> createNote({
    required String uid,
    required String content,
  });

  Future<Either<Failure, EventNote>> replyToNote({
    required int noteId,
    required String content,
  });

  Future<Either<Failure, Unit>> deleteNote(int noteId);
}

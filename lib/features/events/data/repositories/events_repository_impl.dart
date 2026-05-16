import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';
import '../datasources/events_remote_datasource.dart';
import '../models/event_dtos.dart';

@LazySingleton(as: EventsRepository)
class EventsRepositoryImpl implements EventsRepository {
  EventsRepositoryImpl(this._remote);

  final EventsRemoteDatasource _remote;

  @override
  Future<Either<Failure, ({List<Event> events, bool hasMore})>>
      getEventsFeed({
    required EventCategory category,
    int page = 1,
    int pageSize = 20,
  }) =>
          _guard(() async {
            final res = await _remote.getEventsFeed(
              category: category.apiValue,
              page: page,
              pageSize: pageSize,
            );
            final events =
                res.events.map(_toEvent).toList(growable: false);
            return (events: events, hasMore: events.length >= pageSize);
          });

  @override
  Future<Either<Failure, Event>> getEvent(String uid) =>
      _guard(() async => _toEvent(await _remote.getEvent(uid)));

  @override
  Future<Either<Failure, EventInterestResult>> toggleInterest(String uid) =>
      _guard(() async {
        final res = await _remote.toggleInterest(uid);
        return EventInterestResult(
          isInterested: res.isInterested,
          interestedCount: res.interestedCount,
        );
      });

  @override
  Future<Either<Failure, ({List<Event> events, bool hasMore})>>
      getMyEvents({int page = 1, int pageSize = 20}) =>
          _guard(() async {
            final res = await _remote.getMyEvents(
              page: page,
              pageSize: pageSize,
            );
            final events =
                res.events.map(_toEvent).toList(growable: false);
            return (events: events, hasMore: events.length >= pageSize);
          });

  @override
  Future<Either<Failure, List<EventType>>> getEventTypes() =>
      _guard(() async {
        final res = await _remote.getEventTypes();
        return res
            .map((t) => EventType(id: t.id, name: t.name))
            .toList(growable: false);
      });

  @override
  Future<Either<Failure, Event>> createEvent(EventEditorDraft draft) =>
      _guard(() async => _toEvent(await _remote.createEvent(draft.toJson())));

  @override
  Future<Either<Failure, Event>> updateEvent({
    required String uid,
    required EventEditorDraft draft,
  }) =>
      _guard(() async =>
          _toEvent(await _remote.updateEvent(uid, draft.toJson())));

  @override
  Future<Either<Failure, Unit>> deleteEvent(String uid) => _guard(() async {
        await _remote.deleteEvent(uid);
        return unit;
      });

  @override
  Future<Either<Failure, ({List<EventOrganiser> users, bool hasMore})>>
      getInterestedUsers({
    required String uid,
    int page = 1,
    int pageSize = 20,
  }) =>
          _guard(() async {
            final res = await _remote.getInterestedUsers(
              uid,
              page: page,
              pageSize: pageSize,
            );
            final users = res.users
                .map(_organiser)
                .whereType<EventOrganiser>()
                .toList(growable: false);
            return (users: users, hasMore: users.length >= pageSize);
          });

  @override
  Future<Either<Failure, ({List<EventOrganiser> users, bool hasMore})>>
      getGoingUsers({
    required String uid,
    int page = 1,
    int pageSize = 20,
  }) =>
          _guard(() async {
            final res = await _remote.getGoingUsers(
              uid,
              page: page,
              pageSize: pageSize,
            );
            final users = res.users
                .map(_organiser)
                .whereType<EventOrganiser>()
                .toList(growable: false);
            return (users: users, hasMore: users.length >= pageSize);
          });

  @override
  Future<
      Either<Failure,
          ({List<EventInvitation> invitations, bool hasMore})>> getInvitations({
    int page = 1,
    int pageSize = 20,
  }) =>
      _guard(() async {
        final res =
            await _remote.getInvitations(page: page, pageSize: pageSize);
        final invitations = res.invitations
            .map(_toInvitation)
            .toList(growable: false);
        return (
          invitations: invitations,
          hasMore: invitations.length >= pageSize,
        );
      });

  @override
  Future<Either<Failure, EventInvitation>> respondToInvitation({
    required int invitationId,
    required InvitationStatus status,
  }) =>
      _guard(() async {
        final res = await _remote.respondToInvitation(
          invitationId,
          {'status': status.apiValue},
        );
        return _toInvitation(res);
      });

  @override
  Future<Either<Failure, int>> sendInvitations({
    required String uid,
    required List<int> userIds,
  }) =>
      _guard(() async {
        final res = await _remote.sendInvitations(uid, {'user_ids': userIds});
        return res.invitationsSent;
      });

  @override
  Future<Either<Failure, List<EventOrganiser>>> discoverInviteCandidates(
    String uid,
  ) =>
      _guard(() async {
        final res = await _remote.discoverInviteCandidates(uid);
        return res.users
            .map(_organiser)
            .whereType<EventOrganiser>()
            .toList(growable: false);
      });

  @override
  Future<Either<Failure, ({List<EventNote> notes, bool hasMore})>> getNotes({
    required String uid,
    int page = 1,
    int pageSize = 20,
  }) =>
      _guard(() async {
        final res = await _remote.getNotes(
          uid,
          page: page,
          pageSize: pageSize,
        );
        final notes = res.notes.map(_toNote).toList(growable: false);
        return (notes: notes, hasMore: notes.length >= pageSize);
      });

  @override
  Future<Either<Failure, EventNote>> createNote({
    required String uid,
    required String content,
  }) =>
      _guard(() async => _toNote(
            await _remote.createNote(uid, {'content': content}),
          ));

  @override
  Future<Either<Failure, EventNote>> replyToNote({
    required int noteId,
    required String content,
  }) =>
      _guard(() async => _toNote(
            await _remote.replyToNote(noteId, {'content': content}),
          ));

  @override
  Future<Either<Failure, Unit>> deleteNote(int noteId) => _guard(() async {
        await _remote.deleteNote(noteId);
        return unit;
      });

  // ── mappers ────────────────────────────────────────────────────────────────

  EventOrganiser? _organiser(EventUserDto? dto) => dto == null
      ? null
      : EventOrganiser(
          id: dto.id,
          username: dto.username,
          firstName: dto.firstName,
          lastName: dto.lastName,
          profilePictureUrl: dto.profilePictureUrl,
          isPro: dto.isPro,
          rankDisplay: dto.rankDisplay,
          badgeIconUrl: dto.badgeIconUrl,
        );

  EventLocation? _location(EventLocationDto? dto) {
    if (dto == null) return null;
    return EventLocation(
      isCenter: dto.isCenter,
      center: dto.center == null
          ? null
          : EventCenter(
              id: dto.center!.id,
              name: dto.center!.name,
              logo: dto.center!.logo,
              lanes: dto.center!.lanes,
            ),
      address: dto.address,
      zipCode: dto.zipCode,
      latitude: dto.latitude,
      longitude: dto.longitude,
    );
  }

  EventNote _toNote(EventNoteDto dto) => EventNote(
        id: dto.id,
        author: _organiser(dto.author),
        content: dto.content,
        reply: dto.reply,
        repliedAt: dto.repliedAt == null
            ? null
            : DateTime.tryParse(dto.repliedAt!),
        isByCreator: dto.isByCreator,
        createdAt: dto.createdAt == null
            ? null
            : DateTime.tryParse(dto.createdAt!),
      );

  EventInvitation _toInvitation(EventInvitationDto dto) {
    final event = dto.event;
    return EventInvitation(
      id: dto.id,
      eventUid: event?.uid ?? '',
      eventTitle: event?.title ?? '',
      eventDate: event?.eventDate == null
          ? null
          : DateTime.tryParse(event!.eventDate!),
      status: InvitationStatus.fromString(dto.status),
      createdAt: dto.createdAt == null
          ? null
          : DateTime.tryParse(dto.createdAt!),
      respondedAt: dto.respondedAt == null
          ? null
          : DateTime.tryParse(dto.respondedAt!),
    );
  }

  Event _toEvent(EventDto dto) => Event(
        uid: dto.uid,
        title: dto.title,
        description: dto.description,
        eventType: dto.eventType == null
            ? null
            : EventType(id: dto.eventType!.id, name: dto.eventType!.name),
        creator: _organiser(dto.creator),
        flyerUrl: dto.flyerUrl,
        isOnline: dto.isOnline,
        eventDate: dto.eventDate == null
            ? null
            : DateTime.tryParse(dto.eventDate!),
        location: _location(dto.location),
        interestedCount: dto.interestedCount,
        goingCount: dto.goingCount,
        notesCount: dto.notesCount,
        isInterested: dto.isInterested,
        invitationStatus:
            EventInvitationStatus.fromString(dto.invitationStatus),
        isCreator: dto.isCreator,
        createdAt: dto.createdAt == null
            ? null
            : DateTime.tryParse(dto.createdAt!),
      );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DioException catch (e) {
      final parsed = e.error;
      if (parsed is NetworkException) return const Left(NetworkFailure());
      if (parsed is ApiException) {
        if (parsed.statusCode == 401) {
          return Left(UnauthorizedFailure(messages: parsed.messages));
        }
        return Left(ServerFailure(
          messages: parsed.messages,
          statusCode: parsed.statusCode,
        ));
      }
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/event_dtos.dart';

part 'events_remote_datasource.g.dart';

/// Wire to `/api/events/*`. Covers the full CRUD + engagement loop:
/// types, create / update / delete, my events, interest toggle,
/// interested + going attendee lists, invitations (list + respond +
/// send + discover), and Q&A notes. Calendar / nearby views get their
/// own datasources when they ship.
@injectable
@RestApi()
abstract class EventsRemoteDatasource {
  @factoryMethod
  factory EventsRemoteDatasource(Dio dio) = _EventsRemoteDatasource;

  // ── Browse ────────────────────────────────────────────────────────────────

  @GET(Endpoints.eventsFeed)
  Future<EventsFeedDto> getEventsFeed({
    @Query('category') String? category,
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET(Endpoints.eventsMy)
  Future<EventsFeedDto> getMyEvents({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET(Endpoints.eventsTypes)
  Future<List<EventTypeListItemDto>> getEventTypes();

  @GET('/api/events/{uid}')
  Future<EventDto> getEvent(@Path('uid') String uid);

  // ── CRUD ──────────────────────────────────────────────────────────────────

  @POST(Endpoints.eventsCreate)
  Future<EventDto> createEvent(@Body() Map<String, dynamic> body);

  @PUT('/api/events/{uid}/update')
  Future<EventDto> updateEvent(
    @Path('uid') String uid,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/events/{uid}/delete')
  Future<void> deleteEvent(@Path('uid') String uid);

  // ── Interest / attendees ──────────────────────────────────────────────────

  @POST('/api/events/{uid}/interest')
  Future<EventInterestToggleDto> toggleInterest(@Path('uid') String uid);

  @GET('/api/events/{uid}/interested')
  Future<EventUserListPageDto> getInterestedUsers(
    @Path('uid') String uid, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @GET('/api/events/{uid}/going')
  Future<EventUserListPageDto> getGoingUsers(
    @Path('uid') String uid, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  // ── Invitations ───────────────────────────────────────────────────────────

  @POST('/api/events/{uid}/invite')
  Future<EventInviteSentDto> sendInvitations(
    @Path('uid') String uid,
    @Body() Map<String, dynamic> body,
  );

  @GET('/api/events/{uid}/invite/discover')
  Future<EventInviteDiscoverDto> discoverInviteCandidates(
    @Path('uid') String uid, {
    @Query('gender') String? gender,
    @Query('min_age') int? minAge,
    @Query('max_age') int? maxAge,
    @Query('min_average') double? minAverage,
    @Query('max_average') double? maxAverage,
    @Query('min_experience') int? minExperience,
    @Query('max_experience') int? maxExperience,
    @Query('radius_km') double? radiusKm,
  });

  @GET(Endpoints.eventInvitationsList)
  Future<EventInvitationsPageDto> getInvitations({
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @POST('/api/events/invitations/{id}/respond')
  Future<EventInvitationDto> respondToInvitation(
    @Path('id') int invitationId,
    @Body() Map<String, dynamic> body,
  );

  // ── Notes (Q&A) ───────────────────────────────────────────────────────────

  @GET('/api/events/{uid}/notes')
  Future<EventNotesPageDto> getNotes(
    @Path('uid') String uid, {
    @Query('page') int? page,
    @Query('page_size') int? pageSize,
  });

  @POST('/api/events/{uid}/notes')
  Future<EventNoteDto> createNote(
    @Path('uid') String uid,
    @Body() Map<String, dynamic> body,
  );

  @POST('/api/events/notes/{id}/reply')
  Future<EventNoteDto> replyToNote(
    @Path('id') int noteId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/events/notes/{id}/delete')
  Future<void> deleteNote(@Path('id') int noteId);
}

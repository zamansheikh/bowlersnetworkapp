import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/team_dtos.dart';

part 'teams_remote_datasource.g.dart';

/// Wire to `/api/teams/*`. Mirrors the web frontend's Teams surface —
/// create / list / detail / members / invitations / leave / delete +
/// per-member role / jersey edits. Logo upload (presigned-URL flow) is
/// owned by the cloud datasource and called separately.
@injectable
@RestApi()
abstract class TeamsRemoteDatasource {
  @factoryMethod
  factory TeamsRemoteDatasource(Dio dio) = _TeamsRemoteDatasource;

  // ── Browse ────────────────────────────────────────────────────────────────

  @GET(Endpoints.teamsMy)
  Future<List<TeamDto>> getMyTeams();

  @GET(Endpoints.teamInvitations)
  Future<TeamInvitationsBundleDto> getInvitations();

  @GET(Endpoints.teamsValidateName)
  Future<TeamNameValidationDto> validateName(@Query('name') String name);

  // ── Team CRUD ─────────────────────────────────────────────────────────────

  @POST(Endpoints.teamsCreate)
  Future<TeamDto> createTeam(@Body() Map<String, dynamic> body);

  @PUT('/api/teams/{teamId}')
  Future<TeamDto> updateTeam(
    @Path('teamId') int teamId,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/api/teams/{teamId}')
  Future<TeamSimpleAckDto> deleteTeam(@Path('teamId') int teamId);

  @POST('/api/teams/{teamId}/logo')
  Future<TeamDto> updateLogo(
    @Path('teamId') int teamId,
    @Body() Map<String, dynamic> body,
  );

  // ── Detail + membership ───────────────────────────────────────────────────

  @GET('/api/teams/{teamId}/members')
  Future<TeamDto> getTeam(@Path('teamId') int teamId);

  @POST('/api/teams/{teamId}/leave')
  Future<TeamSimpleAckDto> leaveTeam(@Path('teamId') int teamId);

  @DELETE('/api/teams/{teamId}/members/{userId}')
  Future<TeamSimpleAckDto> removeMember(
    @Path('teamId') int teamId,
    @Path('userId') int userId,
  );

  @POST('/api/teams/{teamId}/members/{userId}/role')
  Future<TeamMemberDto> setMemberRole(
    @Path('teamId') int teamId,
    @Path('userId') int userId,
    @Body() Map<String, dynamic> body,
  );

  @POST('/api/teams/{teamId}/members/{userId}/jersey')
  Future<TeamMemberDto> setMemberJersey(
    @Path('teamId') int teamId,
    @Path('userId') int userId,
    @Body() Map<String, dynamic> body,
  );

  // ── Invitations ───────────────────────────────────────────────────────────

  @POST(Endpoints.teamInvite)
  Future<TeamInviteResponseDto> sendInvitations(
    @Body() Map<String, dynamic> body,
  );

  @POST('/api/teams/invitations/{id}/accept')
  Future<TeamInvitationDto> acceptInvitation(@Path('id') int id);

  @POST('/api/teams/invitations/{id}/decline')
  Future<TeamSimpleAckDto> declineInvitation(@Path('id') int id);

  @DELETE('/api/teams/invitations/{id}')
  Future<TeamSimpleAckDto> cancelInvitation(@Path('id') int id);
}

part of 'teams_bloc.dart';

sealed class TeamsEvent extends Equatable {
  const TeamsEvent();
  @override
  List<Object?> get props => const [];
}

class TeamsLoadRequested extends TeamsEvent {
  const TeamsLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class TeamsRefreshRequested extends TeamsEvent {
  const TeamsRefreshRequested();
}

class TeamInvitationAcceptRequested extends TeamsEvent {
  const TeamInvitationAcceptRequested(this.invitationId);
  final int invitationId;
  @override
  List<Object?> get props => [invitationId];
}

class TeamInvitationDeclineRequested extends TeamsEvent {
  const TeamInvitationDeclineRequested(this.invitationId);
  final int invitationId;
  @override
  List<Object?> get props => [invitationId];
}

class TeamInvitationCancelRequested extends TeamsEvent {
  const TeamInvitationCancelRequested(this.invitationId);
  final int invitationId;
  @override
  List<Object?> get props => [invitationId];
}

/// Fired by the Create Team modal after a successful POST so the list
/// inserts the new team without waiting for /my to refetch.
class TeamCreated extends TeamsEvent {
  const TeamCreated(this.team);
  final Team team;
  @override
  List<Object?> get props => [team];
}

/// Fired by the detail screen after Leave / Delete so the list view
/// drops the team immediately on return.
class TeamRemovedLocally extends TeamsEvent {
  const TeamRemovedLocally(this.teamId);
  final int teamId;
  @override
  List<Object?> get props => [teamId];
}

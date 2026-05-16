part of 'team_detail_bloc.dart';

sealed class TeamDetailEvent extends Equatable {
  const TeamDetailEvent();
  @override
  List<Object?> get props => const [];
}

class TeamDetailLoadRequested extends TeamDetailEvent {
  const TeamDetailLoadRequested(this.teamId);
  final int teamId;
  @override
  List<Object?> get props => [teamId];
}

class TeamDetailRefreshRequested extends TeamDetailEvent {
  const TeamDetailRefreshRequested();
}

class TeamMemberRoleSet extends TeamDetailEvent {
  const TeamMemberRoleSet({required this.userId, required this.role});
  final int userId;
  final TeamRole role;
  @override
  List<Object?> get props => [userId, role];
}

class TeamMemberJerseySet extends TeamDetailEvent {
  const TeamMemberJerseySet({required this.userId, required this.jerseyNumber});
  final int userId;
  final int? jerseyNumber;
  @override
  List<Object?> get props => [userId, jerseyNumber];
}

class TeamMemberRemoved extends TeamDetailEvent {
  const TeamMemberRemoved(this.userId);
  final int userId;
  @override
  List<Object?> get props => [userId];
}

class TeamLeftByViewer extends TeamDetailEvent {
  const TeamLeftByViewer();
}

class TeamDeletedByCreator extends TeamDetailEvent {
  const TeamDeletedByCreator();
}

/// Fired after the invite sheet sends invitations so the bloc can
/// refresh the member list (catches edge cases like auto-accepted
/// invitees).
class TeamInvitationsAfterSend extends TeamDetailEvent {
  const TeamInvitationsAfterSend();
}

import 'package:equatable/equatable.dart';
import '../../domain/entities/team.dart';
import '../../domain/entities/team_invitation.dart';
import '../../domain/entities/team_member.dart';
import '../../data/models/available_member_model.dart';

abstract class TeamsState extends Equatable {
  const TeamsState();

  @override
  List<Object> get props => [];
}

class TeamsInitial extends TeamsState {}

class TeamsLoading extends TeamsState {}

class TeamsLoaded extends TeamsState {
  final List<Team> teams;

  const TeamsLoaded({required this.teams});

  @override
  List<Object> get props => [teams];
}

class TeamsError extends TeamsState {
  final String message;

  const TeamsError({required this.message});

  @override
  List<Object> get props => [message];
}

// Team Details States
class TeamDetailsLoading extends TeamsState {}

class TeamDetailsLoaded extends TeamsState {
  final Team team;
  final List<TeamMember> members;

  const TeamDetailsLoaded({required this.team, required this.members});

  @override
  List<Object> get props => [team, members];
}

class TeamDetailsError extends TeamsState {
  final String message;

  const TeamDetailsError({required this.message});

  @override
  List<Object> get props => [message];
}

// Team Creation States
class TeamCreationLoading extends TeamsState {}

class TeamCreationSuccess extends TeamsState {
  final Team createdTeam;

  const TeamCreationSuccess({required this.createdTeam});

  @override
  List<Object> get props => [createdTeam];
}

class TeamCreationError extends TeamsState {
  final String message;

  const TeamCreationError({required this.message});

  @override
  List<Object> get props => [message];
}

// Team Invitations States
class TeamInvitationsLoading extends TeamsState {}

class TeamInvitationsLoaded extends TeamsState {
  final List<TeamInvitation> invitations;

  const TeamInvitationsLoaded({required this.invitations});

  @override
  List<Object> get props => [invitations];
}

class TeamInvitationsError extends TeamsState {
  final String message;

  const TeamInvitationsError({required this.message});

  @override
  List<Object> get props => [message];
}

// Available Members States
class AvailableMembersLoading extends TeamsState {}

class AvailableMembersLoaded extends TeamsState {
  final List<AvailableMemberModel> availableMembers;

  const AvailableMembersLoaded({required this.availableMembers});

  @override
  List<Object> get props => [availableMembers];
}

class AvailableMembersError extends TeamsState {
  final String message;

  const AvailableMembersError({required this.message});

  @override
  List<Object> get props => [message];
}

// Generic Action States (for invite, remove, respond actions)
class TeamsActionLoading extends TeamsState {}

class TeamsActionSuccess extends TeamsState {
  final String message;

  const TeamsActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class TeamsActionError extends TeamsState {
  final String message;

  const TeamsActionError({required this.message});

  @override
  List<Object> get props => [message];
}

import 'package:equatable/equatable.dart';
import 'team_member.dart';
import 'team.dart';

class TeamInvitation extends Equatable {
  final int invitationId;
  final TeamMemberInfo invitedUser;
  final Team team;

  const TeamInvitation({
    required this.invitationId,
    required this.invitedUser,
    required this.team,
  });

  TeamInvitation copyWith({
    int? invitationId,
    TeamMemberInfo? invitedUser,
    Team? team,
  }) {
    return TeamInvitation(
      invitationId: invitationId ?? this.invitationId,
      invitedUser: invitedUser ?? this.invitedUser,
      team: team ?? this.team,
    );
  }

  @override
  List<Object?> get props => [invitationId, invitedUser, team];
}

class TeamInvitations extends Equatable {
  final List<TeamInvitation> received;
  final List<TeamInvitation> sent;

  const TeamInvitations({
    required this.received,
    required this.sent,
  });

  TeamInvitations copyWith({
    List<TeamInvitation>? received,
    List<TeamInvitation>? sent,
  }) {
    return TeamInvitations(
      received: received ?? this.received,
      sent: sent ?? this.sent,
    );
  }

  @override
  List<Object?> get props => [received, sent];
}

class AvailableMember extends Equatable {
  final int userId;
  final String username;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePictureUrl;

  const AvailableMember({
    required this.userId,
    required this.username,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePictureUrl,
  });

  String get fullName => '$firstName $lastName';

  String get initials => 
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
      .toUpperCase();

  @override
  List<Object?> get props => [
        userId,
        username,
        name,
        firstName,
        lastName,
        email,
        profilePictureUrl,
      ];
}
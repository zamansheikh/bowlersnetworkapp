import '../../domain/entities/team_invitation.dart';
import 'team_model.dart';
import 'team_member_model.dart';

class TeamInvitationModel extends TeamInvitation {
  const TeamInvitationModel({
    required int invitationId,
    required TeamMemberInfoModel invitedUser,
    required TeamModel team,
  }) : super(
         invitationId: invitationId,
         invitedUser: invitedUser,
         team: team,
       );

  factory TeamInvitationModel.fromJson(Map<String, dynamic> json) {
    return TeamInvitationModel(
      invitationId: json['invitation_id'] as int,
      invitedUser: TeamMemberInfoModel.fromJson(json['invited_user'] as Map<String, dynamic>),
      team: TeamModel.fromJson(json['team'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invitation_id': invitationId,
      'invited_user': (invitedUser as TeamMemberInfoModel).toJson(),
      'team': (team as TeamModel).toJson(),
    };
  }

  TeamInvitation toEntity() => TeamInvitation(
    invitationId: invitationId,
    invitedUser: invitedUser,
    team: team,
  );
}

class TeamInvitationsModel extends TeamInvitations {
  const TeamInvitationsModel({
    required List<TeamInvitationModel> received,
    required List<TeamInvitationModel> sent,
  }) : super(
         received: received,
         sent: sent,
       );

  factory TeamInvitationsModel.fromJson(Map<String, dynamic> json) {
    final receivedList = json['received'] as List<dynamic>? ?? [];
    final sentList = json['sent'] as List<dynamic>? ?? [];
    
    return TeamInvitationsModel(
      received: receivedList
          .map((invitation) => TeamInvitationModel.fromJson(invitation as Map<String, dynamic>))
          .toList(),
      sent: sentList
          .map((invitation) => TeamInvitationModel.fromJson(invitation as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'received': received
          .map((invitation) => (invitation as TeamInvitationModel).toJson())
          .toList(),
      'sent': sent
          .map((invitation) => (invitation as TeamInvitationModel).toJson())
          .toList(),
    };
  }

  TeamInvitations toEntity() => TeamInvitations(
    received: received,
    sent: sent,
  );
}

class AvailableMemberModel extends AvailableMember {
  const AvailableMemberModel({
    required int userId,
    required String username,
    required String name,
    required String firstName,
    required String lastName,
    required String email,
    String? profilePictureUrl,
  }) : super(
         userId: userId,
         username: username,
         name: name,
         firstName: firstName,
         lastName: lastName,
         email: email,
         profilePictureUrl: profilePictureUrl,
       );

  factory AvailableMemberModel.fromJson(Map<String, dynamic> json) {
    return AvailableMemberModel(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      name: json['name'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'profile_picture_url': profilePictureUrl,
    };
  }

  AvailableMember toEntity() => AvailableMember(
    userId: userId,
    username: username,
    name: name,
    firstName: firstName,
    lastName: lastName,
    email: email,
    profilePictureUrl: profilePictureUrl,
  );
}
import 'package:equatable/equatable.dart';

class TeamMember extends Equatable {
  final int memberId;
  final TeamMemberInfo member;
  final bool isCreator;

  const TeamMember({
    required this.memberId,
    required this.member,
    required this.isCreator,
  });

  TeamMember copyWith({
    int? memberId,
    TeamMemberInfo? member,
    bool? isCreator,
  }) {
    return TeamMember(
      memberId: memberId ?? this.memberId,
      member: member ?? this.member,
      isCreator: isCreator ?? this.isCreator,
    );
  }

  String get displayRole => isCreator ? 'Creator' : 'Member';

  @override
  List<Object?> get props => [memberId, member, isCreator];
}

class TeamMemberInfo extends Equatable {
  final int userId;
  final String username;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePictureUrl;
  final String? introVideoUrl;
  final String? coverPhotoUrl;
  final int xp;
  final int level;
  final String? cardTheme;

  const TeamMemberInfo({
    required this.userId,
    required this.username,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.xp,
    required this.level,
    this.profilePictureUrl,
    this.introVideoUrl,
    this.coverPhotoUrl,
    this.cardTheme,
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
        introVideoUrl,
        coverPhotoUrl,
        xp,
        level,
        cardTheme,
      ];
}

class TeamDetails extends Equatable {
  final int teamId;
  final String name;
  final String? logoUrl;
  final TeamMemberInfo createdBy;
  final String createdAt;
  final int? teamChatRoomId;
  final TeamMembersData members;

  const TeamDetails({
    required this.teamId,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    required this.members,
    this.logoUrl,
    this.teamChatRoomId,
  });

  bool get hasChatRoom => teamChatRoomId != null && teamChatRoomId! > 0;

  @override
  List<Object?> get props => [
        teamId,
        name,
        logoUrl,
        createdBy,
        createdAt,
        teamChatRoomId,
        members,
      ];
}

class TeamMembersData extends Equatable {
  final int memberCount;
  final List<TeamMember> members;

  const TeamMembersData({
    required this.memberCount,
    required this.members,
  });

  @override
  List<Object?> get props => [memberCount, members];
}
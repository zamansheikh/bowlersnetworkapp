import '../../domain/entities/team_member.dart';

class TeamMemberModel extends TeamMember {
  const TeamMemberModel({
    required super.memberId,
    required TeamMemberInfoModel super.member,
    required super.isCreator,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberModel(
      memberId: json['member_id'] as int,
      member: TeamMemberInfoModel.fromJson(
        json['member'] as Map<String, dynamic>,
      ),
      isCreator: json['is_creator'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'member': (member as TeamMemberInfoModel).toJson(),
      'is_creator': isCreator,
    };
  }

  TeamMember toEntity() =>
      TeamMember(memberId: memberId, member: member, isCreator: isCreator);
}

class TeamMemberInfoModel extends TeamMemberInfo {
  const TeamMemberInfoModel({
    required super.userId,
    required super.username,
    required super.name,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.xp,
    required super.level,
    super.profilePictureUrl,
    super.introVideoUrl,
    super.coverPhotoUrl,
    super.cardTheme,
  });

  factory TeamMemberInfoModel.fromJson(Map<String, dynamic> json) {
    return TeamMemberInfoModel(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      name: json['name'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      xp: json['xp'] as int,
      level: json['level'] as int,
      profilePictureUrl: json['profile_picture_url'] as String?,
      introVideoUrl: json['intro_video_url'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      cardTheme: json['card_theme'] as String?,
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
      'xp': xp,
      'level': level,
      'profile_picture_url': profilePictureUrl,
      'intro_video_url': introVideoUrl,
      'cover_photo_url': coverPhotoUrl,
      'card_theme': cardTheme,
    };
  }

  TeamMemberInfo toEntity() => TeamMemberInfo(
    userId: userId,
    username: username,
    name: name,
    firstName: firstName,
    lastName: lastName,
    email: email,
    xp: xp,
    level: level,
    profilePictureUrl: profilePictureUrl,
    introVideoUrl: introVideoUrl,
    coverPhotoUrl: coverPhotoUrl,
    cardTheme: cardTheme,
  );
}

class TeamDetailsModel extends TeamDetails {
  const TeamDetailsModel({
    required super.teamId,
    required super.name,
    required TeamMemberInfoModel super.createdBy,
    required super.createdAt,
    required TeamMembersDataModel super.members,
    super.logoUrl,
    super.teamChatRoomId,
  });

  factory TeamDetailsModel.fromJson(Map<String, dynamic> json) {
    return TeamDetailsModel(
      teamId: json['team_id'] as int,
      name: json['name'] as String,
      createdBy: TeamMemberInfoModel.fromJson(
        json['created_by'] as Map<String, dynamic>,
      ),
      createdAt: json['created_at'] as String,
      members: TeamMembersDataModel.fromJson(
        json['members'] as Map<String, dynamic>,
      ),
      logoUrl: json['logo_url'] as String?,
      teamChatRoomId: json['team_chat_room_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'name': name,
      'created_by': (createdBy as TeamMemberInfoModel).toJson(),
      'created_at': createdAt,
      'members': (members as TeamMembersDataModel).toJson(),
      'logo_url': logoUrl,
      'team_chat_room_id': teamChatRoomId,
    };
  }

  TeamDetails toEntity() => TeamDetails(
    teamId: teamId,
    name: name,
    createdBy: createdBy,
    createdAt: createdAt,
    members: members,
    logoUrl: logoUrl,
    teamChatRoomId: teamChatRoomId,
  );
}

class TeamMembersDataModel extends TeamMembersData {
  const TeamMembersDataModel({
    required super.memberCount,
    required List<TeamMemberModel> super.members,
  });

  factory TeamMembersDataModel.fromJson(Map<String, dynamic> json) {
    final membersList = json['members'] as List<dynamic>;
    return TeamMembersDataModel(
      memberCount: json['member_count'] as int,
      members: membersList
          .map(
            (member) =>
                TeamMemberModel.fromJson(member as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_count': memberCount,
      'members': members
          .map((member) => (member as TeamMemberModel).toJson())
          .toList(),
    };
  }

  TeamMembersData toEntity() =>
      TeamMembersData(memberCount: memberCount, members: members);
}

import '../../domain/entities/team.dart';

class TeamModel extends Team {
  const TeamModel({
    required super.teamId,
    required super.name,
    required TeamCreatorModel super.createdBy,
    required super.createdAt,
    super.logoUrl,
    super.teamChatRoomId,
    super.memberCount,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      teamId: json['team_id'] as int,
      name: json['name'] as String,
      createdBy: TeamCreatorModel.fromJson(
        json['created_by'] as Map<String, dynamic>,
      ),
      createdAt: json['created_at'] as String,
      logoUrl: json['logo_url'] as String?,
      teamChatRoomId: json['team_chat_room_id'] as int?,
      memberCount: json['member_count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'name': name,
      'created_by': (createdBy as TeamCreatorModel).toJson(),
      'created_at': createdAt,
      'logo_url': logoUrl,
      'team_chat_room_id': teamChatRoomId,
      'member_count': memberCount,
    };
  }

  Team toEntity() => Team(
    teamId: teamId,
    name: name,
    createdBy: createdBy,
    createdAt: createdAt,
    logoUrl: logoUrl,
    teamChatRoomId: teamChatRoomId,
    memberCount: memberCount,
  );
}

class TeamCreatorModel extends TeamCreator {
  const TeamCreatorModel({
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

  factory TeamCreatorModel.fromJson(Map<String, dynamic> json) {
    return TeamCreatorModel(
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

  TeamCreator toEntity() => TeamCreator(
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

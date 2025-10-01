import '../../domain/entities/team.dart';

class TeamModel extends Team {
  const TeamModel({
    required int teamId,
    required String name,
    required TeamCreatorModel createdBy,
    required String createdAt,
    String? logoUrl,
    int? teamChatRoomId,
    int? memberCount,
  }) : super(
         teamId: teamId,
         name: name,
         createdBy: createdBy,
         createdAt: createdAt,
         logoUrl: logoUrl,
         teamChatRoomId: teamChatRoomId,
         memberCount: memberCount,
       );

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      teamId: json['team_id'] as int,
      name: json['name'] as String,
      createdBy: TeamCreatorModel.fromJson(json['created_by'] as Map<String, dynamic>),
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
    required int userId,
    required String username,
    required String name,
    required String firstName,
    required String lastName,
    required String email,
    required int xp,
    required int level,
    String? profilePictureUrl,
    String? introVideoUrl,
    String? coverPhotoUrl,
    String? cardTheme,
  }) : super(
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
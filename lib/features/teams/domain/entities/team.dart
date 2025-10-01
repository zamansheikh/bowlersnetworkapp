import 'package:equatable/equatable.dart';
import '../../../../core/utils/date_utils.dart' as date_utils;

class Team extends Equatable {
  final int teamId;
  final String name;
  final String? logoUrl;
  final TeamCreator createdBy;
  final String createdAt;
  final int? teamChatRoomId;
  final int? memberCount;

  const Team({
    required this.teamId,
    required this.name,
    required this.createdBy,
    required this.createdAt,
    this.logoUrl,
    this.teamChatRoomId,
    this.memberCount,
  });

  Team copyWith({
    int? teamId,
    String? name,
    String? logoUrl,
    TeamCreator? createdBy,
    String? createdAt,
    int? teamChatRoomId,
    int? memberCount,
  }) {
    return Team(
      teamId: teamId ?? this.teamId,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      teamChatRoomId: teamChatRoomId ?? this.teamChatRoomId,
      memberCount: memberCount ?? this.memberCount,
    );
  }

  DateTime get createdAtDateTime => date_utils.DateUtils.parseDate(createdAt);

  bool get hasChatRoom => teamChatRoomId != null && teamChatRoomId! > 0;

  String get displayMemberCount => memberCount != null 
      ? '$memberCount ${memberCount == 1 ? 'Member' : 'Members'}'
      : '0 Members';

  @override
  List<Object?> get props => [
        teamId,
        name,
        logoUrl,
        createdBy,
        createdAt,
        teamChatRoomId,
        memberCount,
      ];
}

class TeamCreator extends Equatable {
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

  const TeamCreator({
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
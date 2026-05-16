import 'package:json_annotation/json_annotation.dart';

part 'team_dtos.g.dart';

/// User minimal shape returned in every Teams response.
@JsonSerializable(createToJson: false)
class TeamUserDto {
  const TeamUserDto({
    this.id = 0,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.level,
    this.rank,
    this.tier,
    this.rankDisplay,
    this.badgeIconUrl,
    this.totalXp,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String username;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'is_pro', defaultValue: false)
  final bool isPro;
  final int? level;
  final String? rank;
  final String? tier;
  @JsonKey(name: 'rank_display')
  final String? rankDisplay;
  @JsonKey(name: 'badge_icon_url')
  final String? badgeIconUrl;
  @JsonKey(name: 'total_xp')
  final int? totalXp;

  factory TeamUserDto.fromJson(Map<String, dynamic> json) =>
      _$TeamUserDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TeamHomeCenterDto {
  const TeamHomeCenterDto({this.id = 0, this.name = '', this.logo});
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  final String? logo;
  factory TeamHomeCenterDto.fromJson(Map<String, dynamic> json) =>
      _$TeamHomeCenterDtoFromJson(json);
}

/// Per-member row in /teams/{id}/members. `members` in the team payload
/// is a list of these.
@JsonSerializable(createToJson: false)
class TeamMemberDto {
  const TeamMemberDto({
    this.id = 0,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.level,
    this.rank,
    this.tier,
    this.rankDisplay,
    this.badgeIconUrl,
    this.totalXp,
    this.isFollowing,
    this.joinedAt,
    this.role,
    this.jerseyNumber,
    this.isPro = false,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String username;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  final int? level;
  final String? rank;
  final String? tier;
  @JsonKey(name: 'rank_display')
  final String? rankDisplay;
  @JsonKey(name: 'badge_icon_url')
  final String? badgeIconUrl;
  @JsonKey(name: 'total_xp')
  final int? totalXp;
  @JsonKey(name: 'is_following')
  final bool? isFollowing;
  @JsonKey(name: 'joined_at')
  final String? joinedAt;

  /// Returned by /set-role / /set-jersey endpoints (per-member single object
  /// responses) but NOT by /members which inlines role into the user object
  /// itself. Optional so both shapes deserialise.
  final String? role;
  @JsonKey(name: 'jersey_number')
  final int? jerseyNumber;
  @JsonKey(name: 'is_pro', defaultValue: false)
  final bool isPro;

  factory TeamMemberDto.fromJson(Map<String, dynamic> json) =>
      _$TeamMemberDtoFromJson(json);
}

/// Generic team payload — returned by create / update / detail / /my list
/// items. `members` only populated by /teams/{id}/members.
@JsonSerializable(createToJson: false)
class TeamDto {
  const TeamDto({
    this.teamId = 0,
    this.name = '',
    this.description = '',
    this.logoUrl = '',
    this.maxSize = 5,
    this.isActive = true,
    this.homeCenter,
    this.createdBy,
    this.memberCount = 0,
    this.conversationUid = '',
    this.createdAt,
    this.members = const [],
  });

  @JsonKey(name: 'team_id', defaultValue: 0)
  final int teamId;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(defaultValue: '')
  final String description;
  @JsonKey(name: 'logo_url', defaultValue: '')
  final String logoUrl;
  @JsonKey(name: 'max_size', defaultValue: 5)
  final int maxSize;
  @JsonKey(name: 'is_active', defaultValue: true)
  final bool isActive;
  @JsonKey(name: 'home_center')
  final TeamHomeCenterDto? homeCenter;
  @JsonKey(name: 'created_by')
  final TeamUserDto? createdBy;
  @JsonKey(name: 'member_count', defaultValue: 0)
  final int memberCount;
  @JsonKey(name: 'conversation_uid', defaultValue: '')
  final String conversationUid;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(defaultValue: [])
  final List<TeamMemberDto> members;

  factory TeamDto.fromJson(Map<String, dynamic> json) =>
      _$TeamDtoFromJson(json);
}

/// Team stub inside an invitation payload — id + name + logo only.
@JsonSerializable(createToJson: false)
class TeamInvitationTeamDto {
  const TeamInvitationTeamDto({
    this.teamId = 0,
    this.name = '',
    this.logoUrl = '',
  });
  @JsonKey(name: 'team_id', defaultValue: 0)
  final int teamId;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(name: 'logo_url', defaultValue: '')
  final String logoUrl;

  factory TeamInvitationTeamDto.fromJson(Map<String, dynamic> json) =>
      _$TeamInvitationTeamDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TeamInvitationDto {
  const TeamInvitationDto({
    this.invitationId = 0,
    this.team,
    this.invitedUser,
    this.invitedBy,
    this.isAccepted = false,
    this.createdAt,
  });

  @JsonKey(name: 'invitation_id', defaultValue: 0)
  final int invitationId;
  final TeamInvitationTeamDto? team;
  @JsonKey(name: 'invited_user')
  final TeamUserDto? invitedUser;
  @JsonKey(name: 'invited_by')
  final TeamUserDto? invitedBy;
  @JsonKey(name: 'is_accepted', defaultValue: false)
  final bool isAccepted;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  factory TeamInvitationDto.fromJson(Map<String, dynamic> json) =>
      _$TeamInvitationDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TeamInvitationsBundleDto {
  const TeamInvitationsBundleDto({
    this.received = const [],
    this.sent = const [],
  });
  @JsonKey(defaultValue: [])
  final List<TeamInvitationDto> received;
  @JsonKey(defaultValue: [])
  final List<TeamInvitationDto> sent;

  factory TeamInvitationsBundleDto.fromJson(Map<String, dynamic> json) =>
      _$TeamInvitationsBundleDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TeamInviteSkipDto {
  const TeamInviteSkipDto({this.userId = 0, this.reason = ''});
  @JsonKey(name: 'user_id', defaultValue: 0)
  final int userId;
  @JsonKey(defaultValue: '')
  final String reason;

  factory TeamInviteSkipDto.fromJson(Map<String, dynamic> json) =>
      _$TeamInviteSkipDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TeamInviteResponseDto {
  const TeamInviteResponseDto({this.sent = const [], this.skipped = const []});
  @JsonKey(defaultValue: [])
  final List<TeamInvitationDto> sent;
  @JsonKey(defaultValue: [])
  final List<TeamInviteSkipDto> skipped;

  factory TeamInviteResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TeamInviteResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TeamNameValidationDto {
  const TeamNameValidationDto({this.isAvailable = false, this.reason = ''});
  @JsonKey(name: 'is_available', defaultValue: false)
  final bool isAvailable;
  @JsonKey(defaultValue: '')
  final String reason;

  factory TeamNameValidationDto.fromJson(Map<String, dynamic> json) =>
      _$TeamNameValidationDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class TeamSimpleAckDto {
  const TeamSimpleAckDto({
    this.deleted,
    this.left,
    this.removed,
    this.declined,
    this.cancelled,
  });
  final bool? deleted;
  final bool? left;
  final bool? removed;
  final bool? declined;
  final bool? cancelled;

  factory TeamSimpleAckDto.fromJson(Map<String, dynamic> json) =>
      _$TeamSimpleAckDtoFromJson(json);
}

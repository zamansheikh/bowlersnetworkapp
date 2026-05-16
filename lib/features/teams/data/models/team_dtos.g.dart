// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamUserDto _$TeamUserDtoFromJson(Map<String, dynamic> json) => TeamUserDto(
  id: (json['id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  firstName: json['first_name'] as String? ?? '',
  lastName: json['last_name'] as String? ?? '',
  profilePictureUrl: json['profile_picture_url'] as String?,
  isPro: json['is_pro'] as bool? ?? false,
  level: (json['level'] as num?)?.toInt(),
  rank: json['rank'] as String?,
  tier: json['tier'] as String?,
  rankDisplay: json['rank_display'] as String?,
  badgeIconUrl: json['badge_icon_url'] as String?,
  totalXp: (json['total_xp'] as num?)?.toInt(),
);

TeamHomeCenterDto _$TeamHomeCenterDtoFromJson(Map<String, dynamic> json) =>
    TeamHomeCenterDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
    );

TeamMemberDto _$TeamMemberDtoFromJson(Map<String, dynamic> json) =>
    TeamMemberDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      profilePictureUrl: json['profile_picture_url'] as String?,
      level: (json['level'] as num?)?.toInt(),
      rank: json['rank'] as String?,
      tier: json['tier'] as String?,
      rankDisplay: json['rank_display'] as String?,
      badgeIconUrl: json['badge_icon_url'] as String?,
      totalXp: (json['total_xp'] as num?)?.toInt(),
      isFollowing: json['is_following'] as bool?,
      joinedAt: json['joined_at'] as String?,
      role: json['role'] as String?,
      jerseyNumber: (json['jersey_number'] as num?)?.toInt(),
      isPro: json['is_pro'] as bool? ?? false,
    );

TeamDto _$TeamDtoFromJson(Map<String, dynamic> json) => TeamDto(
  teamId: (json['team_id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  logoUrl: json['logo_url'] as String? ?? '',
  maxSize: (json['max_size'] as num?)?.toInt() ?? 5,
  isActive: json['is_active'] as bool? ?? true,
  homeCenter: json['home_center'] == null
      ? null
      : TeamHomeCenterDto.fromJson(json['home_center'] as Map<String, dynamic>),
  createdBy: json['created_by'] == null
      ? null
      : TeamUserDto.fromJson(json['created_by'] as Map<String, dynamic>),
  memberCount: (json['member_count'] as num?)?.toInt() ?? 0,
  conversationUid: json['conversation_uid'] as String? ?? '',
  createdAt: json['created_at'] as String?,
  members:
      (json['members'] as List<dynamic>?)
          ?.map((e) => TeamMemberDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

TeamInvitationTeamDto _$TeamInvitationTeamDtoFromJson(
  Map<String, dynamic> json,
) => TeamInvitationTeamDto(
  teamId: (json['team_id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  logoUrl: json['logo_url'] as String? ?? '',
);

TeamInvitationDto _$TeamInvitationDtoFromJson(Map<String, dynamic> json) =>
    TeamInvitationDto(
      invitationId: (json['invitation_id'] as num?)?.toInt() ?? 0,
      team: json['team'] == null
          ? null
          : TeamInvitationTeamDto.fromJson(
              json['team'] as Map<String, dynamic>,
            ),
      invitedUser: json['invited_user'] == null
          ? null
          : TeamUserDto.fromJson(json['invited_user'] as Map<String, dynamic>),
      invitedBy: json['invited_by'] == null
          ? null
          : TeamUserDto.fromJson(json['invited_by'] as Map<String, dynamic>),
      isAccepted: json['is_accepted'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );

TeamInvitationsBundleDto _$TeamInvitationsBundleDtoFromJson(
  Map<String, dynamic> json,
) => TeamInvitationsBundleDto(
  received:
      (json['received'] as List<dynamic>?)
          ?.map((e) => TeamInvitationDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  sent:
      (json['sent'] as List<dynamic>?)
          ?.map((e) => TeamInvitationDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

TeamInviteSkipDto _$TeamInviteSkipDtoFromJson(Map<String, dynamic> json) =>
    TeamInviteSkipDto(
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? '',
    );

TeamInviteResponseDto _$TeamInviteResponseDtoFromJson(
  Map<String, dynamic> json,
) => TeamInviteResponseDto(
  sent:
      (json['sent'] as List<dynamic>?)
          ?.map((e) => TeamInvitationDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  skipped:
      (json['skipped'] as List<dynamic>?)
          ?.map((e) => TeamInviteSkipDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

TeamNameValidationDto _$TeamNameValidationDtoFromJson(
  Map<String, dynamic> json,
) => TeamNameValidationDto(
  isAvailable: json['is_available'] as bool? ?? false,
  reason: json['reason'] as String? ?? '',
);

TeamSimpleAckDto _$TeamSimpleAckDtoFromJson(Map<String, dynamic> json) =>
    TeamSimpleAckDto(
      deleted: json['deleted'] as bool?,
      left: json['left'] as bool?,
      removed: json['removed'] as bool?,
      declined: json['declined'] as bool?,
      cancelled: json['cancelled'] as bool?,
    );

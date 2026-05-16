import 'package:equatable/equatable.dart';

/// Member role inside a team. Captain mirrors event captains — can manage
/// jersey numbers + member roles (but not delete the team itself).
enum TeamRole {
  captain('captain', 'Captain'),
  player('player', 'Player'),
  substitute('substitute', 'Substitute');

  const TeamRole(this.wire, this.label);

  /// Backend wire value (matches `TEAM_ROLE_CHOICES`).
  final String wire;
  final String label;

  static TeamRole fromWire(String? value) {
    if (value == null) return TeamRole.player;
    final lower = value.toLowerCase();
    for (final role in TeamRole.values) {
      if (role.wire == lower) return role;
    }
    return TeamRole.player;
  }
}

/// Minimal user shape returned in every Teams response. Same field set
/// the rest of the app uses for chips / avatars.
class TeamUser extends Equatable {
  const TeamUser({
    required this.id,
    required this.username,
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

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final bool isPro;
  final int? level;
  final String? rank;
  final String? tier;
  final String? rankDisplay;
  final String? badgeIconUrl;
  final int? totalXp;

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? username : full;
  }

  @override
  List<Object?> get props => [
        id,
        username,
        firstName,
        lastName,
        profilePictureUrl,
        isPro,
        level,
        rank,
        tier,
        rankDisplay,
        badgeIconUrl,
        totalXp,
      ];
}

class TeamHomeCenter extends Equatable {
  const TeamHomeCenter({required this.id, required this.name, this.logo});
  final int id;
  final String name;
  final String? logo;
  @override
  List<Object?> get props => [id, name, logo];
}

/// Top-level team shape used in /teams/my + create + update responses.
/// `members` is only populated by /teams/{id}/members — list responses
/// leave it empty.
class Team extends Equatable {
  const Team({
    required this.id,
    required this.name,
    required this.createdBy,
    this.description = '',
    this.logoUrl = '',
    this.maxSize = 5,
    this.isActive = true,
    this.homeCenter,
    this.memberCount = 0,
    this.conversationUid = '',
    this.createdAt,
    this.members = const [],
  });

  final int id;
  final String name;
  final String description;
  final String logoUrl;
  final int maxSize;
  final bool isActive;
  final TeamHomeCenter? homeCenter;
  final TeamUser createdBy;
  final int memberCount;

  /// UID of the auto-created group conversation. Empty when the backend
  /// hasn't yet provisioned one (rare — should only happen mid-creation).
  final String conversationUid;
  final DateTime? createdAt;

  /// Populated only by /teams/{id}/members. List endpoints return [].
  final List<TeamMember> members;

  bool get isFull => memberCount >= maxSize;
  bool isCreatedBy(int userId) => createdBy.id == userId;

  Team copyWith({
    String? name,
    String? description,
    String? logoUrl,
    int? maxSize,
    bool? isActive,
    TeamHomeCenter? homeCenter,
    bool clearHomeCenter = false,
    TeamUser? createdBy,
    int? memberCount,
    String? conversationUid,
    DateTime? createdAt,
    List<TeamMember>? members,
  }) {
    return Team(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      maxSize: maxSize ?? this.maxSize,
      isActive: isActive ?? this.isActive,
      homeCenter: clearHomeCenter ? null : (homeCenter ?? this.homeCenter),
      createdBy: createdBy ?? this.createdBy,
      memberCount: memberCount ?? this.memberCount,
      conversationUid: conversationUid ?? this.conversationUid,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        logoUrl,
        maxSize,
        isActive,
        homeCenter,
        createdBy,
        memberCount,
        conversationUid,
        createdAt,
        members,
      ];
}

/// One member row in the /teams/{id}/members response. `user` is the
/// public-facing chip data; `joinedAt` is when the user accepted the
/// invitation (or when the team was created, for the creator).
class TeamMember extends Equatable {
  const TeamMember({
    required this.user,
    this.role = TeamRole.player,
    this.jerseyNumber,
    this.joinedAt,
  });

  final TeamUser user;
  final TeamRole role;
  final int? jerseyNumber;
  final DateTime? joinedAt;

  bool get isCaptain => role == TeamRole.captain;

  @override
  List<Object?> get props => [user, role, jerseyNumber, joinedAt];
}

/// One invitation row from /teams/invitations (received + sent buckets).
/// `team` is a stub (no members / homeCenter); for full detail navigate
/// to /teams/{id}.
class TeamInvitation extends Equatable {
  const TeamInvitation({
    required this.id,
    required this.team,
    required this.invitedUser,
    this.invitedBy,
    this.isAccepted = false,
    this.createdAt,
  });

  final int id;

  /// Minimal team info — name + logo + id only.
  final TeamInvitationTeam team;

  final TeamUser invitedUser;
  final TeamUser? invitedBy;
  final bool isAccepted;
  final DateTime? createdAt;

  @override
  List<Object?> get props =>
      [id, team, invitedUser, invitedBy, isAccepted, createdAt];
}

class TeamInvitationTeam extends Equatable {
  const TeamInvitationTeam({
    required this.id,
    required this.name,
    this.logoUrl = '',
  });
  final int id;
  final String name;
  final String logoUrl;
  @override
  List<Object?> get props => [id, name, logoUrl];
}

/// Outcome of POST /teams/invite. `sent` are the freshly-created
/// invitations; `skipped` lists user ids the backend refused (already a
/// member, duplicate invite, etc.) with a human-readable reason.
class TeamInviteResult extends Equatable {
  const TeamInviteResult({this.sent = const [], this.skipped = const []});
  final List<TeamInvitation> sent;
  final List<TeamInviteSkip> skipped;

  bool get isEmpty => sent.isEmpty && skipped.isEmpty;

  @override
  List<Object?> get props => [sent, skipped];
}

class TeamInviteSkip extends Equatable {
  const TeamInviteSkip({required this.userId, required this.reason});
  final int userId;
  final String reason;
  @override
  List<Object?> get props => [userId, reason];
}

/// Both buckets of /teams/invitations in a single payload so the list
/// screen can render received + sent from one fetch.
class TeamInvitationsBundle extends Equatable {
  const TeamInvitationsBundle({
    this.received = const [],
    this.sent = const [],
  });
  final List<TeamInvitation> received;
  final List<TeamInvitation> sent;
  @override
  List<Object?> get props => [received, sent];
}

/// Outcome of GET /teams/validate-name — the create modal uses this to
/// gate the submit button while the user types.
class TeamNameAvailability extends Equatable {
  const TeamNameAvailability({required this.available, this.reason = ''});
  final bool available;
  final String reason;
  @override
  List<Object?> get props => [available, reason];
}

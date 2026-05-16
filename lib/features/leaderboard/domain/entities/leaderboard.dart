import 'package:equatable/equatable.dart';

/// The 3 leaderboard scopes the backend recognises (board_type query param).
/// The "ranks" tab is presentation-only — it pulls from `/api/xp/ranks` and
/// doesn't paginate, so it isn't part of this enum.
enum LeaderboardBoardType {
  weekly('weekly', 'Weekly', 'this week'),
  monthly('monthly', 'Monthly', 'this month'),
  global('global', 'Global', 'all time');

  const LeaderboardBoardType(this.apiValue, this.label, this.periodLabel);

  final String apiValue;
  final String label;
  final String periodLabel;
}

class LeaderboardUser extends Equatable {
  const LeaderboardUser({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.totalXp,
    this.level,
    this.rankDisplay,
    this.badgeIconUrl,
    this.isFollowing = false,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final bool isPro;
  final int? totalXp;
  final int? level;
  final String? rankDisplay;
  final String? badgeIconUrl;
  final bool isFollowing;

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? username : full;
  }

  /// First name + last initial — matches the web podium label.
  String get podiumName {
    final last = lastName.isEmpty ? '' : ' ${lastName.substring(0, 1)}.';
    final name = '$firstName$last'.trim();
    return name.isEmpty ? username : name;
  }

  @override
  List<Object?> get props => [
        id,
        username,
        firstName,
        lastName,
        profilePictureUrl,
        isPro,
        totalXp,
        level,
        rankDisplay,
        badgeIconUrl,
        isFollowing,
      ];
}

class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.position,
    required this.user,
    required this.xpEarned,
    this.rankDisplay = '',
  });

  final int position;
  final LeaderboardUser user;
  final int xpEarned;
  final String rankDisplay;

  @override
  List<Object?> get props => [position, user, xpEarned, rankDisplay];
}

class MyLeaderboardPosition extends Equatable {
  const MyLeaderboardPosition({
    required this.position,
    required this.xpEarned,
  });

  final int position;
  final int xpEarned;

  @override
  List<Object?> get props => [position, xpEarned];
}

class LeaderboardPage extends Equatable {
  const LeaderboardPage({
    this.entries = const [],
    this.myPosition,
    this.totalEntries = 0,
    this.hasNext = false,
  });

  final List<LeaderboardEntry> entries;
  final MyLeaderboardPosition? myPosition;
  final int totalEntries;
  final bool hasNext;

  @override
  List<Object?> get props => [entries, myPosition, totalEntries, hasNext];
}

/// One rank-group from `/api/xp/ranks` — a Rank (e.g. "Bronze") and the
/// ordered Tiers under it (I/II/III, each with a level + XP threshold).
class RankGroup extends Equatable {
  const RankGroup({required this.rank, this.tiers = const []});

  final Rank rank;
  final List<RankTier> tiers;

  @override
  List<Object?> get props => [rank, tiers];
}

class Rank extends Equatable {
  const Rank({
    required this.id,
    required this.name,
    this.order = 0,
    this.phase = '',
  });

  final int id;
  final String name;
  final int order;
  final String phase;

  @override
  List<Object?> get props => [id, name, order, phase];
}

class RankTier extends Equatable {
  const RankTier({
    this.tier,
    required this.level,
    this.badgeIconUrl = '',
    this.pointsRequired = 0,
  });

  final Tier? tier;
  final int level;
  final String badgeIconUrl;
  final int pointsRequired;

  @override
  List<Object?> get props => [tier, level, badgeIconUrl, pointsRequired];
}

class Tier extends Equatable {
  const Tier({
    required this.id,
    required this.name,
    this.order = 0,
    this.badgeIconUrl = '',
  });

  final int id;
  final String name;
  final int order;
  final String badgeIconUrl;

  @override
  List<Object?> get props => [id, name, order, badgeIconUrl];
}

/// Lightweight viewer-XP snapshot returned by `/api/xp/dashboard` (and
/// loosely a superset of `/level-info`). The leaderboard's "Your Position"
/// card and the Ranks tab's row highlight both pull from here.
class XpDashboard extends Equatable {
  const XpDashboard({
    this.level = 1,
    this.totalXp = 0,
    this.weeklyXp = 0,
    this.monthlyXp = 0,
    this.weeklyXpChange = 0,
    this.progressPercentage = 0,
    this.xpRemaining,
    this.last7DaysXp = 0,
    this.weeklyLeaderboardPosition,
    this.rankDisplay,
    this.badgeIconUrl,
  });

  final int level;
  final int totalXp;
  final int weeklyXp;
  final int monthlyXp;
  final int weeklyXpChange;
  final double progressPercentage;
  final int? xpRemaining;
  final int last7DaysXp;
  final int? weeklyLeaderboardPosition;
  final String? rankDisplay;
  final String? badgeIconUrl;

  @override
  List<Object?> get props => [
        level,
        totalXp,
        weeklyXp,
        monthlyXp,
        weeklyXpChange,
        progressPercentage,
        xpRemaining,
        last7DaysXp,
        weeklyLeaderboardPosition,
        rankDisplay,
        badgeIconUrl,
      ];
}

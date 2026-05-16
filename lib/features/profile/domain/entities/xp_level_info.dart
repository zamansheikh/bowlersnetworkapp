import 'package:equatable/equatable.dart';

/// Lightweight XP snapshot for the profile rank card + home XP hero.
/// Mirrors web's `XPHeroCard` payload shape exactly.
class XpLevelInfo extends Equatable {
  const XpLevelInfo({
    required this.level,
    required this.totalXp,
    required this.progressPercentage,
    this.rank,
    this.tier,
    this.rankDisplay,
    this.badgeIconUrl,
    this.weeklyXpChange,
    this.xpToNextLevel,
    this.nextLevel,
    this.nextRankDisplay,
    this.nextBadgeIconUrl,
  });

  final int level;
  final int totalXp;

  /// 0-100.
  final num progressPercentage;

  final String? rank;
  final String? tier;

  /// Combined `rank + tier` string, e.g. "Silver II".
  final String? rankDisplay;
  final String? badgeIconUrl;

  /// XP gained or lost this week (can be negative). `null` until the user
  /// has any XP at all.
  final int? weeklyXpChange;

  /// XP remaining to the next level.
  final int? xpToNextLevel;

  /// Next level number (current + 1).
  final int? nextLevel;

  /// Next level's rank display (e.g. "Newcomer Silver").
  final String? nextRankDisplay;

  /// Next level's badge icon URL.
  final String? nextBadgeIconUrl;

  bool get hasRecord => level > 0 || totalXp > 0;

  @override
  List<Object?> get props => [
        level,
        totalXp,
        progressPercentage,
        rank,
        tier,
        rankDisplay,
        badgeIconUrl,
        weeklyXpChange,
        xpToNextLevel,
        nextLevel,
        nextRankDisplay,
        nextBadgeIconUrl,
      ];
}

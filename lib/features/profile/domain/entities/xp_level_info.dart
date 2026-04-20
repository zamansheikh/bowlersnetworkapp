import 'package:equatable/equatable.dart';

/// Lightweight XP snapshot for the profile rank card.
class XpLevelInfo extends Equatable {
  const XpLevelInfo({
    required this.level,
    required this.totalXp,
    required this.progressPercentage,
    this.rank,
    this.tier,
    this.rankDisplay,
    this.badgeIconUrl,
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
      ];
}

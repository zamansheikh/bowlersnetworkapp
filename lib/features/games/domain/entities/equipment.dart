import 'package:equatable/equatable.dart';

/// Catalog-spec for a bowling ball (the canonical ball, not the user's
/// instance). Returned by `/api/balls` and nested inside each [UserBall].
class CatalogBall extends Equatable {
  const CatalogBall({
    required this.id,
    required this.name,
    this.brand,
    this.core = '',
    this.surface = '',
    this.rg = '',
    this.diff = '',
    this.intDiff = '',
    this.arc = '',
    this.ballImage = '',
  });

  final int id;
  final String name;
  final BallBrand? brand;
  final String core;
  final String surface;
  final String rg;
  final String diff;
  final String intDiff;
  final String arc;
  final String ballImage;

  @override
  List<Object?> get props =>
      [id, name, brand, core, surface, rg, diff, intDiff, arc, ballImage];
}

class BallBrand extends Equatable {
  const BallBrand({required this.id, required this.name, this.logoUrl});

  final int id;
  final String name;
  final String? logoUrl;

  @override
  List<Object?> get props => [id, name, logoUrl];
}

/// One row in the user's loadout — pairs a catalog [ball] with the
/// [weight] they bowl with.
class UserBall extends Equatable {
  const UserBall({
    required this.id,
    required this.ball,
    required this.weight,
    this.createdAt,
  });

  final int id;
  final CatalogBall ball;
  final int weight;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, ball, weight, createdAt];
}

/// Per-ball usage stats returned by `/api/games/equipment/stats`.
class BallStats extends Equatable {
  const BallStats({
    required this.userBallId,
    this.gamesPlayed = 0,
    this.framesThrown = 0,
    this.firstBallCount = 0,
    this.firstBallAvg = 0,
    this.strikeRate = 0,
  });

  final int userBallId;
  final int gamesPlayed;
  final int framesThrown;
  final int firstBallCount;
  final double firstBallAvg;
  final double strikeRate;

  bool get hasUsage => framesThrown > 0;

  @override
  List<Object?> get props => [
        userBallId,
        gamesPlayed,
        framesThrown,
        firstBallCount,
        firstBallAvg,
        strikeRate,
      ];
}

/// Standard weight options shown in the ball picker (matches web's WEIGHTS).
const List<int> ballWeightOptions = [
  6, 8, 10, 11, 12, 13, 14, 15, 16,
];

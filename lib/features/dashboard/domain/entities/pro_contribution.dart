import 'package:equatable/equatable.dart';

/// Response of /api/pro/contribution. Cold-start users (no snapshot yet)
/// get `hasData: false` with all numeric fields zeroed — the UI shows a
/// "Your contribution is being calculated" hint.
class ProContribution extends Equatable {
  const ProContribution({
    this.hasData = false,
    this.window = '',
    this.date,
    this.poolSize = 0,
    this.rank = 0,
    this.poolPercentage = 0,
    this.personalScore = 0,
    this.contentScore = 0,
    this.socialScore = 0,
    this.growthScore = 0,
    this.deltas = const ContributionDeltas(),
  });

  final bool hasData;
  final String window;
  final DateTime? date;
  final int poolSize;
  final int rank;
  final double poolPercentage;
  final double personalScore;
  final double contentScore;
  final double socialScore;
  final double growthScore;
  final ContributionDeltas deltas;

  @override
  List<Object?> get props => [
        hasData,
        window,
        date,
        poolSize,
        rank,
        poolPercentage,
        personalScore,
        contentScore,
        socialScore,
        growthScore,
        deltas,
      ];
}

class ContributionDeltas extends Equatable {
  const ContributionDeltas({
    this.poolPercentageChange,
    this.rankChange,
    this.personalScoreChange,
  });

  final double? poolPercentageChange;

  /// +N means improved (the backend computes `prior.rank - today.rank`,
  /// so smaller numerical rank = better).
  final int? rankChange;
  final double? personalScoreChange;

  @override
  List<Object?> get props =>
      [poolPercentageChange, rankChange, personalScoreChange];
}

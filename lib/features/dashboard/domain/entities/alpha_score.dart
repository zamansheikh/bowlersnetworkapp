import 'package:equatable/equatable.dart';

/// Response of /api/dashboard/insights/alpha — the "impact score" card.
/// Tips are actionable nudges shown beneath the score.
class AlphaScore extends Equatable {
  const AlphaScore({
    this.score = 0,
    this.impactLevel = '',
    this.tips = const [],
  });

  final int score;
  final String impactLevel;
  final List<AlphaTip> tips;

  @override
  List<Object?> get props => [score, impactLevel, tips];
}

class AlphaTip extends Equatable {
  const AlphaTip({required this.text, this.action = ''});
  final String text;
  final String action;
  @override
  List<Object?> get props => [text, action];
}

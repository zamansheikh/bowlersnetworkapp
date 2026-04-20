import 'package:equatable/equatable.dart';

/// Audience visibility for a new post. Mirrors backend constants (`public`,
/// `followers`, `center`, `private`).
enum PostAudience {
  public('public', 'Public'),
  followers('followers', 'Followers'),
  center('center', 'Center'),
  private('private', 'Only me');

  const PostAudience(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

/// Backend game-type enum for score posts.
enum GameType {
  practice('practice', 'Practice'),
  league('league', 'League'),
  tournament('tournament', 'Tournament');

  const GameType(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

/// A single poll option the user is drafting.
class PollOptionDraft extends Equatable {
  const PollOptionDraft({required this.text});
  final String text;

  @override
  List<Object?> get props => [text];
}

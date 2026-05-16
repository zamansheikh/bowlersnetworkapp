import 'package:equatable/equatable.dart';

/// Categories accepted by `POST /api/feedback/submit`. Apply the
/// `apiValue` straight into the payload.
enum FeedbackCategory {
  bug('bug', 'Bug'),
  suggestion('suggestion', 'Suggestion'),
  featureRequest('feature_request', 'Feature request'),
  complaint('complaint', 'Complaint'),
  question('question', 'Question');

  const FeedbackCategory(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

/// Feature-area buckets the backend recognises. Mostly map 1:1 to
/// sidebar items. `other` is the default fallback.
enum FeedbackArea {
  newsfeed('newsfeed', 'Newsfeed'),
  chatter('chatter', 'Chatter'),
  media('media', 'Media'),
  cards('cards', 'Cards'),
  games('games', 'Games'),
  events('events', 'Events'),
  teams('teams', 'Teams'),
  messages('messages', 'Messages'),
  profiles('profiles', 'Profiles'),
  xp('xp', 'XP'),
  dashboard('dashboard', 'Dashboard'),
  search('search', 'Search'),
  notifications('notifications', 'Notifications'),
  other('other', 'Other');

  const FeedbackArea(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

/// Result of a successful submit — used by the UI to flash a
/// confirmation toast and clear the form.
class FeedbackSubmitted extends Equatable {
  const FeedbackSubmitted({required this.uid, required this.title});
  final String? uid;
  final String title;
  @override
  List<Object?> get props => [uid, title];
}

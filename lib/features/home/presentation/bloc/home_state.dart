part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState({
    this.feedPreview = const [],
    this.leaderboardPreview = const [],
    this.discussionsPreview = const [],
    this.mediaPreview = const [],
    this.eventsPreview = const [],
    this.livePreview = const [],
    this.loading = false,
    this.refreshing = false,
  });

  /// Up to 5 latest posts — used to build the "Your Feed" preview rows.
  final List<Post> feedPreview;

  /// Top 5 weekly leaderboard entries.
  final List<LeaderboardEntry> leaderboardPreview;

  /// Top 3 discussions for the "Top Discussions" bento.
  final List<DiscussionPreview> discussionsPreview;

  /// Up to 4 videos + splits for the "Trending Media" grid.
  final List<MediaPreview> mediaPreview;

  /// Next 3 upcoming events.
  final List<EventPreview> eventsPreview;

  /// Live broadcasts from people the user follows.
  final List<LiveBroadcastPreview> livePreview;

  final bool loading;
  final bool refreshing;

  HomeState copyWith({
    List<Post>? feedPreview,
    List<LeaderboardEntry>? leaderboardPreview,
    List<DiscussionPreview>? discussionsPreview,
    List<MediaPreview>? mediaPreview,
    List<EventPreview>? eventsPreview,
    List<LiveBroadcastPreview>? livePreview,
    bool? loading,
    bool? refreshing,
  }) {
    return HomeState(
      feedPreview: feedPreview ?? this.feedPreview,
      leaderboardPreview: leaderboardPreview ?? this.leaderboardPreview,
      discussionsPreview: discussionsPreview ?? this.discussionsPreview,
      mediaPreview: mediaPreview ?? this.mediaPreview,
      eventsPreview: eventsPreview ?? this.eventsPreview,
      livePreview: livePreview ?? this.livePreview,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
    );
  }

  @override
  List<Object?> get props => [
        feedPreview,
        leaderboardPreview,
        discussionsPreview,
        mediaPreview,
        eventsPreview,
        livePreview,
        loading,
        refreshing,
      ];
}

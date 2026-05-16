part of 'leaderboard_bloc.dart';

class LeaderboardState extends Equatable {
  const LeaderboardState({
    this.tab = LeaderboardTab.weekly,
    this.entries = const [],
    this.myPosition,
    this.totalEntries = 0,
    this.hasMore = false,
    this.page = 1,
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.ranks = const [],
    this.ranksLoading = false,
    this.errors = const [],
  });

  final LeaderboardTab tab;
  final List<LeaderboardEntry> entries;
  final MyLeaderboardPosition? myPosition;
  final int totalEntries;
  final bool hasMore;
  final int page;
  final bool loading;
  final bool refreshing;
  final bool loadingMore;
  final List<RankGroup> ranks;
  final bool ranksLoading;
  final List<String> errors;

  LeaderboardState copyWith({
    LeaderboardTab? tab,
    List<LeaderboardEntry>? entries,
    MyLeaderboardPosition? myPosition,
    int? totalEntries,
    bool? hasMore,
    int? page,
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    List<RankGroup>? ranks,
    bool? ranksLoading,
    List<String>? errors,
  }) {
    return LeaderboardState(
      tab: tab ?? this.tab,
      entries: entries ?? this.entries,
      myPosition: myPosition ?? this.myPosition,
      totalEntries: totalEntries ?? this.totalEntries,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      ranks: ranks ?? this.ranks,
      ranksLoading: ranksLoading ?? this.ranksLoading,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        tab,
        entries,
        myPosition,
        totalEntries,
        hasMore,
        page,
        loading,
        refreshing,
        loadingMore,
        ranks,
        ranksLoading,
        errors,
      ];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../leaderboard/domain/entities/leaderboard.dart';
import '../../../leaderboard/domain/repositories/leaderboard_repository.dart';
import '../../../newsfeed/domain/entities/post.dart';
import '../../../newsfeed/domain/repositories/newsfeed_repository.dart';
import '../../domain/entities/home_previews.dart';
import '../../domain/repositories/home_preview_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Aggregates every section the home screen previews — feed, leaderboard,
/// top discussions, trending media, upcoming events, live-now strip. All
/// fired in parallel; each section can fail independently (matches web's
/// `Promise.allSettled` pattern).
///
/// XP and profile data are already on ProfileBloc — no duplication here.
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._feed, this._leaderboard, this._previews)
      : super(const HomeState()) {
    on<HomeLoadRequested>(_onLoad);
    on<HomeRefreshRequested>(_onRefresh);
  }

  final NewsfeedRepository _feed;
  final LeaderboardRepository _leaderboard;
  final HomePreviewRepository _previews;

  Future<void> _onLoad(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    if (state.feedPreview.isNotEmpty || state.leaderboardPreview.isNotEmpty) {
      return;
    }
    emit(state.copyWith(loading: true));
    await _fetch(emit);
  }

  Future<void> _onRefresh(
    HomeRefreshRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(refreshing: true));
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<HomeState> emit) async {
    final results = await Future.wait<dynamic>([
      _feed.getFeed(pageSize: 5),
      _leaderboard.getLeaderboard(
        boardType: LeaderboardBoardType.weekly,
        pageSize: 5,
      ),
      _previews.getTopDiscussions(),
      _previews.getTrendingMedia(),
      _previews.getUpcomingEvents(),
      _previews.getLiveFromFollowing(),
    ]);

    final feedRes = results[0] as Either<Failure, FeedPage>;
    final lbRes = results[1] as Either<Failure, LeaderboardPage>;
    final discRes = results[2] as Either<Failure, List<DiscussionPreview>>;
    final mediaRes = results[3] as Either<Failure, List<MediaPreview>>;
    final eventsRes = results[4] as Either<Failure, List<EventPreview>>;
    final liveRes =
        results[5] as Either<Failure, List<LiveBroadcastPreview>>;

    emit(state.copyWith(
      loading: false,
      refreshing: false,
      feedPreview: feedRes.fold<List<Post>>(
        (_) => state.feedPreview,
        (page) => page.posts,
      ),
      leaderboardPreview: lbRes.fold<List<LeaderboardEntry>>(
        (_) => state.leaderboardPreview,
        (page) => page.entries,
      ),
      discussionsPreview: discRes.fold<List<DiscussionPreview>>(
        (_) => state.discussionsPreview,
        (l) => l,
      ),
      mediaPreview: mediaRes.fold<List<MediaPreview>>(
        (_) => state.mediaPreview,
        (l) => l,
      ),
      eventsPreview: eventsRes.fold<List<EventPreview>>(
        (_) => state.eventsPreview,
        (l) => l,
      ),
      livePreview: liveRes.fold<List<LiveBroadcastPreview>>(
        (_) => state.livePreview,
        (l) => l,
      ),
    ));
  }
}

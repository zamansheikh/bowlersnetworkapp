import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/chatter.dart';
import '../../domain/repositories/chatter_repository.dart';

part 'chatter_list_event.dart';
part 'chatter_list_state.dart';

/// Drives the /chatter screen: topic filter, sort tab, paginated list +
/// pull-to-refresh. Topics are loaded once on first attach; subsequent
/// filter/sort changes only re-fetch discussions.
@injectable
class ChatterListBloc extends Bloc<ChatterListEvent, ChatterListState> {
  ChatterListBloc(this._repository) : super(const ChatterListState()) {
    on<ChatterListLoadRequested>(_onLoad);
    on<ChatterListRefreshRequested>(_onRefresh);
    on<ChatterListTopicChanged>(_onTopicChanged);
    on<ChatterListSortChanged>(_onSortChanged);
    on<ChatterListNextPageRequested>(_onNextPage);
  }

  final ChatterRepository _repository;

  Future<void> _onLoad(
    ChatterListLoadRequested event,
    Emitter<ChatterListState> emit,
  ) async {
    if (state.discussions.isNotEmpty && !event.force) return;
    emit(state.copyWith(loading: true, errors: const []));
    // Topics in parallel with the first page. Topic failures aren't fatal
    // — the chip row just stays empty.
    final results = await Future.wait<dynamic>([
      _repository.getTopics(),
      _repository.getDiscussions(
        topicId: state.topicId,
        sort: state.sort,
        page: 1,
      ),
    ], eagerError: false);

    final topicsRes = results[0] as dynamic;
    final discussionsRes = results[1] as dynamic;

    final topics = topicsRes.fold<List<Topic>>(
      (_) => const <Topic>[],
      (list) => list as List<Topic>,
    );
    discussionsRes.fold(
      (f) => emit(state.copyWith(
        loading: false,
        topics: topics,
        errors: f.messages,
      )),
      (page) => emit(state.copyWith(
        loading: false,
        topics: topics,
        discussions: page.discussions,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onRefresh(
    ChatterListRefreshRequested event,
    Emitter<ChatterListState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    final res = await _repository.getDiscussions(
      topicId: state.topicId,
      sort: state.sort,
      page: 1,
    );
    res.fold(
      (f) => emit(state.copyWith(refreshing: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        refreshing: false,
        discussions: page.discussions,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onTopicChanged(
    ChatterListTopicChanged event,
    Emitter<ChatterListState> emit,
  ) async {
    if (event.topicId == state.topicId) return;
    emit(state.copyWith(
      topicId: event.topicId,
      clearTopic: event.topicId == null,
      loading: true,
      discussions: const [],
      page: 1,
      hasMore: false,
      errors: const [],
    ));
    await _fetchFirstPage(emit);
  }

  Future<void> _onSortChanged(
    ChatterListSortChanged event,
    Emitter<ChatterListState> emit,
  ) async {
    if (event.sort == state.sort) return;
    emit(state.copyWith(
      sort: event.sort,
      loading: true,
      discussions: const [],
      page: 1,
      hasMore: false,
      errors: const [],
    ));
    await _fetchFirstPage(emit);
  }

  Future<void> _onNextPage(
    ChatterListNextPageRequested event,
    Emitter<ChatterListState> emit,
  ) async {
    if (state.loadingMore || !state.hasMore || state.loading) return;
    emit(state.copyWith(loadingMore: true));
    final next = state.page + 1;
    final res = await _repository.getDiscussions(
      topicId: state.topicId,
      sort: state.sort,
      page: next,
    );
    res.fold(
      (f) => emit(state.copyWith(loadingMore: false, errors: f.messages)),
      (pageRes) => emit(state.copyWith(
        loadingMore: false,
        discussions: [...state.discussions, ...pageRes.discussions],
        page: next,
        hasMore: pageRes.hasMore,
      )),
    );
  }

  Future<void> _fetchFirstPage(Emitter<ChatterListState> emit) async {
    final res = await _repository.getDiscussions(
      topicId: state.topicId,
      sort: state.sort,
      page: 1,
    );
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        loading: false,
        discussions: page.discussions,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }
}

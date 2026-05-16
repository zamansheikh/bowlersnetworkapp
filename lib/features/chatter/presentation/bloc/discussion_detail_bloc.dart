import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chatter.dart';
import '../../domain/repositories/chatter_repository.dart';

part 'discussion_detail_event.dart';
part 'discussion_detail_state.dart';

/// One per detail screen — NOT a singleton; the UID is locked at
/// construction. Owns the discussion entity + its paginated opinions
/// thread, plus optimistic upvote toggles on both.
class DiscussionDetailBloc
    extends Bloc<DiscussionDetailEvent, DiscussionDetailState> {
  DiscussionDetailBloc({
    required ChatterRepository repository,
    required String uid,
  })  : _repository = repository,
        _uid = uid,
        super(const DiscussionDetailState()) {
    on<DiscussionDetailLoadRequested>(_onLoad);
    on<DiscussionDetailRefreshRequested>(_onRefresh);
    on<DiscussionDetailUpvoteToggled>(_onUpvote);
    on<DiscussionDetailOpinionSortChanged>(_onSortChanged);
    on<DiscussionDetailOpinionsNextPageRequested>(_onNextPage);
    on<DiscussionDetailOpinionUpvoteToggled>(_onOpinionUpvote);
    on<DiscussionDetailOpinionPosted>(_onOpinionPosted);
  }

  final ChatterRepository _repository;
  final String _uid;

  Future<void> _onLoad(
    DiscussionDetailLoadRequested event,
    Emitter<DiscussionDetailState> emit,
  ) async {
    emit(state.copyWith(loading: true, errors: const []));
    final detailRes = await _repository.getDiscussion(_uid);
    await detailRes.fold(
      (f) async {
        emit(state.copyWith(loading: false, errors: f.messages));
      },
      (discussion) async {
        emit(state.copyWith(loading: false, discussion: discussion));
        // Kick off opinions in the background — failures degrade gracefully.
        final opRes = await _repository.getOpinions(
          discussion.id,
          sort: state.opinionSort,
          page: 1,
        );
        opRes.fold(
          (_) {/* leave opinions empty; the toolbar still works */},
          (page) => emit(state.copyWith(
            opinions: page.opinions,
            opinionsPage: 1,
            opinionsHasMore: page.hasMore,
          )),
        );
      },
    );
  }

  Future<void> _onRefresh(
    DiscussionDetailRefreshRequested event,
    Emitter<DiscussionDetailState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    final detailRes = await _repository.getDiscussion(_uid);
    await detailRes.fold(
      (f) async => emit(state.copyWith(refreshing: false, errors: f.messages)),
      (discussion) async {
        emit(state.copyWith(refreshing: false, discussion: discussion));
        final opRes = await _repository.getOpinions(
          discussion.id,
          sort: state.opinionSort,
          page: 1,
        );
        opRes.fold(
          (_) {},
          (page) => emit(state.copyWith(
            opinions: page.opinions,
            opinionsPage: 1,
            opinionsHasMore: page.hasMore,
          )),
        );
      },
    );
  }

  Future<void> _onUpvote(
    DiscussionDetailUpvoteToggled event,
    Emitter<DiscussionDetailState> emit,
  ) async {
    final d = state.discussion;
    if (d == null || state.upvoteBusy) return;
    if (d.isMine == true) return; // backend rejects voting on own content

    final wasUpvoted = d.hasUpvoted == true;
    final optimistic = d.withUpvote(
      hasUpvoted: !wasUpvoted,
      upvoteCount: (d.upvoteCount + (wasUpvoted ? -1 : 1)).clamp(0, 1 << 31),
    );
    emit(state.copyWith(discussion: optimistic, upvoteBusy: true));

    final res = await _repository.upvoteDiscussion(d.id);
    res.fold(
      (f) => emit(state.copyWith(
        discussion: d, // rollback
        upvoteBusy: false,
        errors: f.messages,
      )),
      (result) {
        // Backend says authoritative state. Translate add/remove/changed
        // to a concrete (hasUpvoted, count) tuple.
        final nowUpvoted = !result.wasRemoved && result.isUpvote;
        final delta = nowUpvoted == wasUpvoted
            ? 0 // no net change (shouldn't normally happen)
            : (nowUpvoted ? 1 : -1);
        emit(state.copyWith(
          discussion: d.withUpvote(
            hasUpvoted: nowUpvoted,
            upvoteCount: (d.upvoteCount + delta).clamp(0, 1 << 31),
          ),
          upvoteBusy: false,
        ));
      },
    );
  }

  Future<void> _onSortChanged(
    DiscussionDetailOpinionSortChanged event,
    Emitter<DiscussionDetailState> emit,
  ) async {
    final d = state.discussion;
    if (d == null || event.sort == state.opinionSort) return;
    emit(state.copyWith(
      opinionSort: event.sort,
      opinions: const [],
      opinionsPage: 1,
      opinionsHasMore: false,
      opinionsLoading: true,
    ));
    final res = await _repository.getOpinions(
      d.id,
      sort: event.sort,
      page: 1,
    );
    res.fold(
      (f) => emit(state.copyWith(
        opinionsLoading: false,
        errors: f.messages,
      )),
      (page) => emit(state.copyWith(
        opinionsLoading: false,
        opinions: page.opinions,
        opinionsPage: 1,
        opinionsHasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onNextPage(
    DiscussionDetailOpinionsNextPageRequested event,
    Emitter<DiscussionDetailState> emit,
  ) async {
    final d = state.discussion;
    if (d == null ||
        state.opinionsLoadingMore ||
        !state.opinionsHasMore ||
        state.opinionsLoading) {
      return;
    }
    emit(state.copyWith(opinionsLoadingMore: true));
    final next = state.opinionsPage + 1;
    final res = await _repository.getOpinions(
      d.id,
      sort: state.opinionSort,
      page: next,
    );
    res.fold(
      (f) => emit(state.copyWith(
        opinionsLoadingMore: false,
        errors: f.messages,
      )),
      (page) => emit(state.copyWith(
        opinionsLoadingMore: false,
        opinions: [...state.opinions, ...page.opinions],
        opinionsPage: next,
        opinionsHasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onOpinionUpvote(
    DiscussionDetailOpinionUpvoteToggled event,
    Emitter<DiscussionDetailState> emit,
  ) async {
    final idx = state.opinions.indexWhere((o) => o.id == event.opinionId);
    if (idx == -1) return;
    final o = state.opinions[idx];
    if (o.isMine == true) return;
    if (state.opinionUpvoteBusyIds.contains(o.id)) return;

    final wasUpvoted = o.hasUpvoted == true;
    final optimistic = o.withUpvote(
      hasUpvoted: !wasUpvoted,
      upvoteCount: (o.upvoteCount + (wasUpvoted ? -1 : 1)).clamp(0, 1 << 31),
    );
    final nextList = [...state.opinions]..[idx] = optimistic;
    emit(state.copyWith(
      opinions: nextList,
      opinionUpvoteBusyIds: {...state.opinionUpvoteBusyIds, o.id},
    ));

    final res = await _repository.upvoteOpinion(o.id);
    res.fold(
      (f) {
        // Rollback this one item.
        final rollback = [...state.opinions]..[idx] = o;
        emit(state.copyWith(
          opinions: rollback,
          opinionUpvoteBusyIds:
              state.opinionUpvoteBusyIds.where((id) => id != o.id).toSet(),
          errors: f.messages,
        ));
      },
      (result) {
        final nowUpvoted = !result.wasRemoved && result.isUpvote;
        final delta = nowUpvoted == wasUpvoted
            ? 0
            : (nowUpvoted ? 1 : -1);
        final reconciled = o.withUpvote(
          hasUpvoted: nowUpvoted,
          upvoteCount: (o.upvoteCount + delta).clamp(0, 1 << 31),
        );
        final reconciledList = [...state.opinions]..[idx] = reconciled;
        emit(state.copyWith(
          opinions: reconciledList,
          opinionUpvoteBusyIds:
              state.opinionUpvoteBusyIds.where((id) => id != o.id).toSet(),
        ));
      },
    );
  }

  Future<void> _onOpinionPosted(
    DiscussionDetailOpinionPosted event,
    Emitter<DiscussionDetailState> emit,
  ) async {
    final d = state.discussion;
    final body = event.body.trim();
    if (d == null || body.isEmpty || state.posting) return;
    emit(state.copyWith(posting: true, errors: const []));
    final res = await _repository.postOpinion(
      discussionId: d.id,
      body: body,
      parentId: event.parentId,
    );
    res.fold(
      (f) => emit(state.copyWith(posting: false, errors: f.messages)),
      (newOpinion) {
        // Prepend top-level opinions so the user sees their reply
        // immediately. Replies (parent_id != null) don't appear inline
        // since we don't render reply threads in this iteration.
        final nextOpinions = event.parentId == null
            ? [newOpinion, ...state.opinions]
            : state.opinions;
        emit(state.copyWith(
          posting: false,
          opinions: nextOpinions,
          discussion: d.withOpinionCount(d.opinionCount + 1),
        ));
      },
    );
  }
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/follow_user.dart';
import '../../domain/repositories/follow_repository.dart';

part 'follow_list_event.dart';
part 'follow_list_state.dart';

/// Source of the list — keeps the bloc generic across the four list flavours
/// (my followers/followings, another user's followers/followings).
enum FollowListSource { myFollowers, myFollowings, userFollowers, userFollowings }

/// Per-screen bloc — scoped by the screen's `BlocProvider`. Not a singleton.
class FollowListBloc extends Bloc<FollowListEvent, FollowListState> {
  FollowListBloc({
    required FollowRepository repository,
    required this.source,
    this.userId,
  })  : _repository = repository,
        super(const FollowListState()) {
    on<FollowListLoadRequested>(_onLoad);
    on<FollowListRefreshRequested>(_onRefresh);
    on<FollowListFollowToggled>(_onToggle);
  }

  final FollowRepository _repository;
  final FollowListSource source;
  final int? userId;

  Future<void> _onLoad(
    FollowListLoadRequested event,
    Emitter<FollowListState> emit,
  ) async {
    if (state.users.isNotEmpty) return;
    emit(state.copyWith(loading: true, errors: const []));
    await _fetch(emit);
  }

  Future<void> _onRefresh(
    FollowListRefreshRequested event,
    Emitter<FollowListState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    await _fetch(emit, refresh: true);
  }

  Future<void> _fetch(
    Emitter<FollowListState> emit, {
    bool refresh = false,
  }) async {
    final res = await switch (source) {
      FollowListSource.myFollowers => _repository.getMyFollowers(),
      FollowListSource.myFollowings => _repository.getMyFollowings(),
      FollowListSource.userFollowers =>
        _repository.getUserFollowers(userId!),
      FollowListSource.userFollowings =>
        _repository.getUserFollowings(userId!),
    };
    res.fold(
      (f) => emit(state.copyWith(
        loading: false,
        refreshing: false,
        errors: f.messages,
      )),
      (list) => emit(state.copyWith(
        loading: false,
        refreshing: false,
        users: list,
        errors: const [],
      )),
    );
  }

  Future<void> _onToggle(
    FollowListFollowToggled event,
    Emitter<FollowListState> emit,
  ) async {
    final idx = state.users.indexWhere((u) => u.id == event.userId);
    if (idx < 0) return;
    final original = state.users[idx];
    // Optimistic flip.
    final flipped = List<FollowUser>.from(state.users);
    flipped[idx] = original.copyWith(isFollowing: !original.isFollowing);
    emit(state.copyWith(users: flipped));

    final res = await _repository.toggleFollow(event.userId);
    res.fold(
      (f) {
        final rollback = List<FollowUser>.from(state.users);
        rollback[idx] = original;
        emit(state.copyWith(users: rollback, errors: f.messages));
      },
      (result) {
        final authoritative = List<FollowUser>.from(state.users);
        authoritative[idx] =
            original.copyWith(isFollowing: result.isFollowing);
        emit(state.copyWith(users: authoritative));
      },
    );
  }
}

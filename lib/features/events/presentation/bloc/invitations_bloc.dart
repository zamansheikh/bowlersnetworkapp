import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/event.dart';
import '../../domain/repositories/events_repository.dart';

part 'invitations_event.dart';
part 'invitations_state.dart';

/// Drives /events/invitations — viewer's invitation inbox. Each
/// accept/decline is optimistic + per-row busy so the rest of the
/// list stays interactive while a single response flies.
@injectable
class InvitationsBloc extends Bloc<InvitationsEvent, InvitationsState> {
  InvitationsBloc(this._repository) : super(const InvitationsState()) {
    on<InvitationsLoadRequested>(_onLoad);
    on<InvitationsRefreshRequested>(_onRefresh);
    on<InvitationsNextPageRequested>(_onNextPage);
    on<InvitationRespondRequested>(_onRespond);
  }

  final EventsRepository _repository;

  Future<void> _onLoad(
    InvitationsLoadRequested event,
    Emitter<InvitationsState> emit,
  ) async {
    if (state.invitations.isNotEmpty && !event.force) return;
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _repository.getInvitations(page: 1);
    res.fold(
      (f) => emit(state.copyWith(loading: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        loading: false,
        invitations: page.invitations,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onRefresh(
    InvitationsRefreshRequested event,
    Emitter<InvitationsState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    final res = await _repository.getInvitations(page: 1);
    res.fold(
      (f) => emit(state.copyWith(refreshing: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        refreshing: false,
        invitations: page.invitations,
        page: 1,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onNextPage(
    InvitationsNextPageRequested event,
    Emitter<InvitationsState> emit,
  ) async {
    if (state.loadingMore || !state.hasMore || state.loading) return;
    emit(state.copyWith(loadingMore: true));
    final next = state.page + 1;
    final res = await _repository.getInvitations(page: next);
    res.fold(
      (f) => emit(state.copyWith(loadingMore: false, errors: f.messages)),
      (page) => emit(state.copyWith(
        loadingMore: false,
        invitations: [...state.invitations, ...page.invitations],
        page: next,
        hasMore: page.hasMore,
      )),
    );
  }

  Future<void> _onRespond(
    InvitationRespondRequested event,
    Emitter<InvitationsState> emit,
  ) async {
    final idx =
        state.invitations.indexWhere((i) => i.id == event.invitationId);
    if (idx == -1) return;
    if (state.busyIds.contains(event.invitationId)) return;
    final original = state.invitations[idx];
    final optimistic = original.withStatus(status: event.status);
    final next = List<EventInvitation>.from(state.invitations);
    next[idx] = optimistic;
    emit(state.copyWith(
      invitations: next,
      busyIds: {...state.busyIds, event.invitationId},
      errors: const [],
    ));

    final res = await _repository.respondToInvitation(
      invitationId: event.invitationId,
      status: event.status,
    );
    res.fold(
      (f) {
        final rollback = List<EventInvitation>.from(state.invitations);
        rollback[idx] = original;
        emit(state.copyWith(
          invitations: rollback,
          busyIds:
              state.busyIds.where((id) => id != event.invitationId).toSet(),
          errors: f.messages,
        ));
      },
      (authoritative) {
        final reconciled = List<EventInvitation>.from(state.invitations);
        reconciled[idx] = authoritative;
        emit(state.copyWith(
          invitations: reconciled,
          busyIds:
              state.busyIds.where((id) => id != event.invitationId).toSet(),
        ));
      },
    );
  }
}

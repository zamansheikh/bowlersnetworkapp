import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/team.dart';
import '../../domain/repositories/teams_repository.dart';

part 'teams_event.dart';
part 'teams_state.dart';

/// Drives the /teams list screen. Loads the viewer's teams + their
/// pending invitation buckets in a single shot, and handles the
/// invitation actions (accept / decline / cancel) inline with per-row
/// busy tracking so multiple actions can fly concurrently without
/// blocking each other.
@injectable
class TeamsBloc extends Bloc<TeamsEvent, TeamsState> {
  TeamsBloc(this._repository) : super(const TeamsState()) {
    on<TeamsLoadRequested>(_onLoad);
    on<TeamsRefreshRequested>(_onRefresh);
    on<TeamInvitationAcceptRequested>(_onAccept);
    on<TeamInvitationDeclineRequested>(_onDecline);
    on<TeamInvitationCancelRequested>(_onCancel);
    on<TeamCreated>(_onTeamCreated);
    on<TeamRemovedLocally>(_onTeamRemovedLocally);
  }

  final TeamsRepository _repository;

  Future<void> _onLoad(
    TeamsLoadRequested event,
    Emitter<TeamsState> emit,
  ) async {
    if (state.teams.isNotEmpty && !event.force) return;
    emit(state.copyWith(loading: true, errors: const []));
    await _fetch(emit);
  }

  Future<void> _onRefresh(
    TeamsRefreshRequested event,
    Emitter<TeamsState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    await _fetch(emit);
  }

  /// One load: teams + invitations in parallel. Either failure surfaces
  /// as a non-blocking error string; the list still renders whatever
  /// succeeded.
  Future<void> _fetch(Emitter<TeamsState> emit) async {
    final results = await Future.wait([
      _repository.getMyTeams(),
      _repository.getInvitations(),
    ]);
    final teamsRes = results[0];
    final invsRes = results[1];

    List<Team> teams = state.teams;
    TeamInvitationsBundle invs = state.invitations;
    final errors = <String>[];

    teamsRes.fold(
      (f) => errors.addAll(
        f.messages.isEmpty ? const ['Failed to load teams.'] : f.messages,
      ),
      (list) => teams = list as List<Team>,
    );
    invsRes.fold(
      (f) => errors.addAll(
        f.messages.isEmpty
            ? const ['Failed to load invitations.']
            : f.messages,
      ),
      (bundle) => invs = bundle as TeamInvitationsBundle,
    );

    emit(state.copyWith(
      loading: false,
      refreshing: false,
      teams: teams,
      invitations: invs,
      errors: errors,
    ));
  }

  Future<void> _onAccept(
    TeamInvitationAcceptRequested event,
    Emitter<TeamsState> emit,
  ) async {
    emit(state.withInvitationBusy(event.invitationId, true));
    final res = await _repository.acceptInvitation(event.invitationId);
    res.fold(
      (f) => emit(state
          .withInvitationBusy(event.invitationId, false)
          .copyWith(errors: _msgs(f.messages, 'Failed to accept invitation.'))),
      (_) {
        // Drop from received, then refetch in the background so the
        // teams list picks up the new membership without blocking UI.
        final next = state.invitations.received
            .where((i) => i.id != event.invitationId)
            .toList(growable: false);
        emit(state
            .withInvitationBusy(event.invitationId, false)
            .copyWith(
              invitations: TeamInvitationsBundle(
                received: next,
                sent: state.invitations.sent,
              ),
              errors: const [],
            ));
        add(const TeamsRefreshRequested());
      },
    );
  }

  Future<void> _onDecline(
    TeamInvitationDeclineRequested event,
    Emitter<TeamsState> emit,
  ) async {
    emit(state.withInvitationBusy(event.invitationId, true));
    final res = await _repository.declineInvitation(event.invitationId);
    res.fold(
      (f) => emit(state
          .withInvitationBusy(event.invitationId, false)
          .copyWith(errors: _msgs(f.messages, 'Failed to decline invitation.'))),
      (_) {
        final next = state.invitations.received
            .where((i) => i.id != event.invitationId)
            .toList(growable: false);
        emit(state
            .withInvitationBusy(event.invitationId, false)
            .copyWith(
              invitations: TeamInvitationsBundle(
                received: next,
                sent: state.invitations.sent,
              ),
              errors: const [],
            ));
      },
    );
  }

  Future<void> _onCancel(
    TeamInvitationCancelRequested event,
    Emitter<TeamsState> emit,
  ) async {
    emit(state.withInvitationBusy(event.invitationId, true));
    final res = await _repository.cancelInvitation(event.invitationId);
    res.fold(
      (f) => emit(state
          .withInvitationBusy(event.invitationId, false)
          .copyWith(errors: _msgs(f.messages, 'Failed to cancel invitation.'))),
      (_) {
        final next = state.invitations.sent
            .where((i) => i.id != event.invitationId)
            .toList(growable: false);
        emit(state
            .withInvitationBusy(event.invitationId, false)
            .copyWith(
              invitations: TeamInvitationsBundle(
                received: state.invitations.received,
                sent: next,
              ),
              errors: const [],
            ));
      },
    );
  }

  void _onTeamCreated(TeamCreated event, Emitter<TeamsState> emit) {
    // Prepend the new team so it appears at the top without waiting for a
    // round-trip refetch. Refresh in the background to pick up any sent
    // invitations the create flow produced.
    if (state.teams.any((t) => t.id == event.team.id)) return;
    emit(state.copyWith(
      teams: [event.team, ...state.teams],
      errors: const [],
    ));
    add(const TeamsRefreshRequested());
  }

  void _onTeamRemovedLocally(
    TeamRemovedLocally event,
    Emitter<TeamsState> emit,
  ) {
    final next = state.teams
        .where((t) => t.id != event.teamId)
        .toList(growable: false);
    emit(state.copyWith(teams: next, errors: const []));
  }

  List<String> _msgs(List<String> msgs, String fallback) =>
      msgs.isEmpty ? [fallback] : msgs;
}

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/team.dart';
import '../../domain/repositories/teams_repository.dart';

part 'team_detail_event.dart';
part 'team_detail_state.dart';

/// Drives /teams/:id. Owns the full team + members payload and the
/// in-flight set for per-member actions so multiple role / remove
/// requests can fly without blocking each other.
@injectable
class TeamDetailBloc extends Bloc<TeamDetailEvent, TeamDetailState> {
  TeamDetailBloc(this._repository) : super(const TeamDetailState()) {
    on<TeamDetailLoadRequested>(_onLoad);
    on<TeamDetailRefreshRequested>(_onRefresh);
    on<TeamMemberRoleSet>(_onSetRole);
    on<TeamMemberJerseySet>(_onSetJersey);
    on<TeamMemberRemoved>(_onRemoveMember);
    on<TeamInvitationsAfterSend>(_onInvitationsSent);
    on<TeamLeftByViewer>(_onLeave);
    on<TeamDeletedByCreator>(_onDelete);
  }

  final TeamsRepository _repository;

  Future<void> _onLoad(
    TeamDetailLoadRequested event,
    Emitter<TeamDetailState> emit,
  ) async {
    emit(state.copyWith(loading: true, errors: const []));
    final res = await _repository.getTeam(event.teamId);
    res.fold(
      (f) => emit(state.copyWith(
        loading: false,
        errors: f.messages.isEmpty
            ? const ['Failed to load team.']
            : f.messages,
      )),
      (team) => emit(state.copyWith(
        loading: false,
        team: team,
        errors: const [],
      )),
    );
  }

  Future<void> _onRefresh(
    TeamDetailRefreshRequested event,
    Emitter<TeamDetailState> emit,
  ) async {
    final team = state.team;
    if (team == null) return;
    emit(state.copyWith(refreshing: true, errors: const []));
    final res = await _repository.getTeam(team.id);
    res.fold(
      (f) => emit(state.copyWith(
        refreshing: false,
        errors: f.messages.isEmpty
            ? const ['Failed to refresh.']
            : f.messages,
      )),
      (next) =>
          emit(state.copyWith(refreshing: false, team: next, errors: const [])),
    );
  }

  Future<void> _onSetRole(
    TeamMemberRoleSet event,
    Emitter<TeamDetailState> emit,
  ) async {
    final team = state.team;
    if (team == null) return;
    emit(state.withMemberBusy(event.userId, true));
    final res = await _repository.setMemberRole(
      teamId: team.id,
      userId: event.userId,
      role: event.role,
    );
    res.fold(
      (f) => emit(state
          .withMemberBusy(event.userId, false)
          .copyWith(errors: _msgs(f.messages, 'Failed to set role.'))),
      (member) {
        final next = _replaceMember(team.members, event.userId, (existing) {
          // Backend's set-role response doesn't echo joinedAt — preserve
          // the value we already have so the row UI doesn't blink.
          return TeamMember(
            user: existing.user,
            role: member.role,
            jerseyNumber: member.jerseyNumber ?? existing.jerseyNumber,
            joinedAt: existing.joinedAt,
          );
        });
        emit(state
            .withMemberBusy(event.userId, false)
            .copyWith(team: team.copyWith(members: next), errors: const []));
      },
    );
  }

  Future<void> _onSetJersey(
    TeamMemberJerseySet event,
    Emitter<TeamDetailState> emit,
  ) async {
    final team = state.team;
    if (team == null) return;
    emit(state.withMemberBusy(event.userId, true));
    final res = await _repository.setMemberJersey(
      teamId: team.id,
      userId: event.userId,
      jerseyNumber: event.jerseyNumber,
    );
    res.fold(
      (f) => emit(state
          .withMemberBusy(event.userId, false)
          .copyWith(errors: _msgs(f.messages, 'Failed to update jersey.'))),
      (member) {
        final next = _replaceMember(team.members, event.userId, (existing) {
          return TeamMember(
            user: existing.user,
            role: existing.role,
            jerseyNumber: member.jerseyNumber,
            joinedAt: existing.joinedAt,
          );
        });
        emit(state
            .withMemberBusy(event.userId, false)
            .copyWith(team: team.copyWith(members: next), errors: const []));
      },
    );
  }

  Future<void> _onRemoveMember(
    TeamMemberRemoved event,
    Emitter<TeamDetailState> emit,
  ) async {
    final team = state.team;
    if (team == null) return;
    emit(state.withMemberBusy(event.userId, true));
    final res = await _repository.removeMember(
      teamId: team.id,
      userId: event.userId,
    );
    res.fold(
      (f) => emit(state
          .withMemberBusy(event.userId, false)
          .copyWith(errors: _msgs(f.messages, 'Failed to remove member.'))),
      (_) {
        final nextMembers = team.members
            .where((m) => m.user.id != event.userId)
            .toList(growable: false);
        emit(state.withMemberBusy(event.userId, false).copyWith(
              team: team.copyWith(
                members: nextMembers,
                memberCount: nextMembers.length,
              ),
              errors: const [],
            ));
      },
    );
  }

  Future<void> _onLeave(
    TeamLeftByViewer event,
    Emitter<TeamDetailState> emit,
  ) async {
    final team = state.team;
    if (team == null) return;
    emit(state.copyWith(processingExit: true, errors: const []));
    final res = await _repository.leaveTeam(team.id);
    res.fold(
      (f) => emit(state.copyWith(
        processingExit: false,
        errors: _msgs(f.messages, 'Failed to leave team.'),
      )),
      (_) => emit(state.copyWith(processingExit: false, exited: true)),
    );
  }

  Future<void> _onDelete(
    TeamDeletedByCreator event,
    Emitter<TeamDetailState> emit,
  ) async {
    final team = state.team;
    if (team == null) return;
    emit(state.copyWith(processingExit: true, errors: const []));
    final res = await _repository.deleteTeam(team.id);
    res.fold(
      (f) => emit(state.copyWith(
        processingExit: false,
        errors: _msgs(f.messages, 'Failed to delete team.'),
      )),
      (_) => emit(state.copyWith(processingExit: false, exited: true)),
    );
  }

  /// Called after the invite sheet returns — refresh so any auto-accepted
  /// members (rare, but possible) show up.
  void _onInvitationsSent(
    TeamInvitationsAfterSend event,
    Emitter<TeamDetailState> emit,
  ) {
    // Just trigger a refresh — the sheet itself already handled toasts
    // for sent + skipped counts.
    add(const TeamDetailRefreshRequested());
  }

  List<TeamMember> _replaceMember(
    List<TeamMember> members,
    int userId,
    TeamMember Function(TeamMember existing) transform,
  ) {
    final idx = members.indexWhere((m) => m.user.id == userId);
    if (idx == -1) return members;
    final next = List<TeamMember>.from(members);
    next[idx] = transform(members[idx]);
    return next;
  }

  List<String> _msgs(List<String> msgs, String fallback) =>
      msgs.isEmpty ? [fallback] : msgs;
}

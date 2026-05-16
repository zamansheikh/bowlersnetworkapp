part of 'teams_bloc.dart';

class TeamsState extends Equatable {
  const TeamsState({
    this.loading = false,
    this.refreshing = false,
    this.teams = const [],
    this.invitations = const TeamInvitationsBundle(),
    this.busyInvitationIds = const {},
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;
  final List<Team> teams;
  final TeamInvitationsBundle invitations;

  /// In-flight invitation actions (accept / decline / cancel). The UI
  /// disables just those rows so the rest of the list stays interactive.
  final Set<int> busyInvitationIds;
  final List<String> errors;

  bool isInvitationBusy(int invitationId) =>
      busyInvitationIds.contains(invitationId);

  TeamsState withInvitationBusy(int invitationId, bool busy) {
    final next = Set<int>.from(busyInvitationIds);
    if (busy) {
      next.add(invitationId);
    } else {
      next.remove(invitationId);
    }
    return copyWith(busyInvitationIds: next);
  }

  TeamsState copyWith({
    bool? loading,
    bool? refreshing,
    List<Team>? teams,
    TeamInvitationsBundle? invitations,
    Set<int>? busyInvitationIds,
    List<String>? errors,
  }) {
    return TeamsState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      teams: teams ?? this.teams,
      invitations: invitations ?? this.invitations,
      busyInvitationIds: busyInvitationIds ?? this.busyInvitationIds,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        refreshing,
        teams,
        invitations,
        busyInvitationIds,
        errors,
      ];
}

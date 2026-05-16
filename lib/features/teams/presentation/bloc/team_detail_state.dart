part of 'team_detail_bloc.dart';

class TeamDetailState extends Equatable {
  const TeamDetailState({
    this.team,
    this.loading = false,
    this.refreshing = false,
    this.processingExit = false,
    this.exited = false,
    this.busyMemberIds = const {},
    this.errors = const [],
  });

  final Team? team;
  final bool loading;
  final bool refreshing;

  /// True while the Leave / Delete call is in flight — disables the
  /// screen-level action bar.
  final bool processingExit;

  /// Set once the viewer leaves or deletes the team. The screen
  /// listens for this and pops + dispatches `TeamRemovedLocally` on the
  /// list bloc.
  final bool exited;

  /// In-flight per-member actions (role / jersey / remove).
  final Set<int> busyMemberIds;
  final List<String> errors;

  bool isMemberBusy(int userId) => busyMemberIds.contains(userId);

  TeamDetailState withMemberBusy(int userId, bool busy) {
    final next = Set<int>.from(busyMemberIds);
    if (busy) {
      next.add(userId);
    } else {
      next.remove(userId);
    }
    return copyWith(busyMemberIds: next);
  }

  TeamDetailState copyWith({
    Team? team,
    bool? loading,
    bool? refreshing,
    bool? processingExit,
    bool? exited,
    Set<int>? busyMemberIds,
    List<String>? errors,
  }) {
    return TeamDetailState(
      team: team ?? this.team,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      processingExit: processingExit ?? this.processingExit,
      exited: exited ?? this.exited,
      busyMemberIds: busyMemberIds ?? this.busyMemberIds,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        team,
        loading,
        refreshing,
        processingExit,
        exited,
        busyMemberIds,
        errors,
      ];
}

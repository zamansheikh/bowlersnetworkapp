part of 'invitations_bloc.dart';

class InvitationsState extends Equatable {
  const InvitationsState({
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.invitations = const [],
    this.page = 1,
    this.hasMore = false,
    this.busyIds = const {},
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;
  final bool loadingMore;
  final List<EventInvitation> invitations;
  final int page;
  final bool hasMore;

  /// IDs of invitations whose respond RPC is currently in flight —
  /// used to disable just that row's buttons without blocking the rest.
  final Set<int> busyIds;

  final List<String> errors;

  InvitationsState copyWith({
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    List<EventInvitation>? invitations,
    int? page,
    bool? hasMore,
    Set<int>? busyIds,
    List<String>? errors,
  }) {
    return InvitationsState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      invitations: invitations ?? this.invitations,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      busyIds: busyIds ?? this.busyIds,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        refreshing,
        loadingMore,
        invitations,
        page,
        hasMore,
        busyIds,
        errors,
      ];
}

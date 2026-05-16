part of 'follow_list_bloc.dart';

class FollowListState extends Equatable {
  const FollowListState({
    this.users = const [],
    this.loading = false,
    this.refreshing = false,
    this.errors = const [],
  });

  final List<FollowUser> users;
  final bool loading;
  final bool refreshing;
  final List<String> errors;

  FollowListState copyWith({
    List<FollowUser>? users,
    bool? loading,
    bool? refreshing,
    List<String>? errors,
  }) {
    return FollowListState(
      users: users ?? this.users,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [users, loading, refreshing, errors];
}

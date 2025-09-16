part of 'pro_players_cubit.dart';

abstract class ProPlayersState {}

class ProPlayersInitial extends ProPlayersState {}

class ProPlayersLoading extends ProPlayersState {}

class ProPlayersLoaded extends ProPlayersState {
  final List<ProPlayer> players;

  ProPlayersLoaded(this.players);
}

class ProPlayersError extends ProPlayersState {
  final String message;

  ProPlayersError(this.message);
}

class ProPlayerDetailLoading extends ProPlayersState {}

class ProPlayerDetailLoaded extends ProPlayersState {
  final ProPlayer player;
  final List<FeedPost>? posts;
  final bool isLoadingPosts;
  final String? postsError;

  ProPlayerDetailLoaded(
    this.player, {
    this.posts,
    this.isLoadingPosts = false,
    this.postsError,
  });
}

class ProPlayerDetailError extends ProPlayersState {
  final String message;

  ProPlayerDetailError(this.message);
}

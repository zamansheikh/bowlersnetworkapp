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

  ProPlayerDetailLoaded(this.player);
}

class ProPlayerDetailError extends ProPlayersState {
  final String message;

  ProPlayerDetailError(this.message);
}

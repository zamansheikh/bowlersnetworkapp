import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/utils/usecase.dart';
import '../../domain/entities/pro_player.dart';
import '../../domain/usecases/pro_players_usecases.dart';
import '../../data/models/pro_player_model.dart';
import '../../data/datasources/pro_players_remote_data_source.dart';
import '../../../home/data/models/feed_post.dart';

part 'pro_players_state.dart';

@injectable
class ProPlayersCubit extends Cubit<ProPlayersState> {
  final GetProPlayers getProPlayers;
  final GetProPlayerById getProPlayerById;
  final FollowPlayer followPlayer;
  final UnfollowPlayer unfollowPlayer;
  final ProPlayersRemoteDataSource remoteDataSource;

  ProPlayersCubit(
    this.getProPlayers,
    this.getProPlayerById,
    this.followPlayer,
    this.unfollowPlayer,
    this.remoteDataSource,
  ) : super(ProPlayersInitial());

  Future<void> loadProPlayers() async {
    emit(ProPlayersLoading());

    final result = await getProPlayers(NoParams());
    result.fold(
      (failure) => emit(ProPlayersError(failure.toString())),
      (players) => emit(ProPlayersLoaded(players)),
    );
  }

  Future<void> loadProPlayerById(String userId) async {
    emit(ProPlayerDetailLoading());

    final result = await getProPlayerById(userId);
    result.fold(
      (failure) => emit(ProPlayerDetailError(failure.toString())),
      (player) => emit(ProPlayerDetailLoaded(player)),
    );
  }

  Future<void> loadUserPosts(String userId) async {
    final currentState = state;
    if (currentState is ProPlayerDetailLoaded) {
      emit(
        ProPlayerDetailLoaded(
          currentState.player,
          posts: currentState.posts,
          isLoadingPosts: true,
        ),
      );

      try {
        final posts = await remoteDataSource.getUserPosts(userId);
        emit(
          ProPlayerDetailLoaded(
            currentState.player,
            posts: posts,
            isLoadingPosts: false,
          ),
        );
      } catch (e) {
        emit(
          ProPlayerDetailLoaded(
            currentState.player,
            posts: currentState.posts,
            isLoadingPosts: false,
            postsError: e.toString(),
          ),
        );
      }
    }
  }

  Future<void> toggleFollowPlayer(int userId) async {
    final currentState = state;

    if (currentState is ProPlayersLoaded) {
      // Find the player and create optimistic update
      final playerIndex = currentState.players.indexWhere(
        (p) => p.userId == userId,
      );
      if (playerIndex == -1) return;

      final player = currentState.players[playerIndex];
      final isCurrentlyFollowed = player.isFollowed;

      // Optimistic update
      final updatedPlayer = _updatePlayerFollowStatus(
        player,
        !isCurrentlyFollowed,
      );
      final updatedPlayers = List<ProPlayer>.from(currentState.players);
      updatedPlayers[playerIndex] = updatedPlayer;

      emit(ProPlayersLoaded(updatedPlayers));

      // Make API call
      final result = isCurrentlyFollowed
          ? await unfollowPlayer(userId)
          : await followPlayer(userId);

      result.fold(
        (failure) {
          // Revert optimistic update on failure
          final revertedPlayers = List<ProPlayer>.from(currentState.players);
          emit(ProPlayersLoaded(revertedPlayers));
          emit(ProPlayersError(failure.toString()));
        },
        (success) {
          // Keep the optimistic update since it was successful
        },
      );
    } else if (currentState is ProPlayerDetailLoaded) {
      // Handle follow/unfollow from detail page
      final player = currentState.player;
      final isCurrentlyFollowed = player.isFollowed;

      // Optimistic update
      final updatedPlayer = _updatePlayerFollowStatus(
        player,
        !isCurrentlyFollowed,
      );
      emit(ProPlayerDetailLoaded(updatedPlayer));

      // Make API call
      final result = isCurrentlyFollowed
          ? await unfollowPlayer(userId)
          : await followPlayer(userId);

      result.fold(
        (failure) {
          // Revert optimistic update on failure
          emit(ProPlayerDetailLoaded(player));
          emit(ProPlayerDetailError(failure.toString()));
        },
        (success) {
          // Keep the optimistic update since it was successful
        },
      );
    }
  }

  ProPlayer _updatePlayerFollowStatus(ProPlayer player, bool isFollowed) {
    // Since ProPlayer is immutable, we need to create a new instance
    // This would need to be implemented based on your ProPlayer constructor
    // For now, I'll assume we can update the fields we need
    if (player is ProPlayerModel) {
      return player.copyWith(
        isFollowed: isFollowed,
        followerCount: isFollowed
            ? player.followerCount + 1
            : player.followerCount - 1,
      );
    }

    // Fallback if not ProPlayerModel - this shouldn't happen in practice
    return player;
  }

  void resetState() {
    emit(ProPlayersInitial());
  }
}

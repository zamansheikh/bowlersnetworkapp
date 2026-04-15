import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/post.dart';

abstract class NewsfeedRepository {
  Future<Either<Failure, FeedPage>> getFeed({
    String? filter,
    int? cursor,
    int pageSize = 20,
  });

  Future<Either<Failure, Post>> getPost(String uid);

  /// Toggle reaction: sending the same reaction twice un-reacts; sending a
  /// different reaction swaps. Returns the updated reaction state
  /// (`null` when cleared).
  Future<Either<Failure, ReactionType?>> react(
    String postUid,
    ReactionType reaction,
  );

  /// Save/unsave toggle. Returns the new saved state.
  Future<Either<Failure, bool>> toggleSave(String postUid);

  /// Hide post from this user's feed.
  Future<Either<Failure, Unit>> hide(String postUid);
}

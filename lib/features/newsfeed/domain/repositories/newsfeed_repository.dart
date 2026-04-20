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

  Future<Either<Failure, Post>> createTextPost({
    required String caption,
    required String audience,
  });

  Future<Either<Failure, Post>> createPhotoPost({
    required String caption,
    required String audience,
    required List<String> mediaUrls,
  });

  Future<Either<Failure, Post>> createVideoPost({
    required String caption,
    required String audience,
    required String videoUrl,
    String? thumbnailUrl,
  });

  Future<Either<Failure, Post>> createScorePost({
    required String caption,
    required String audience,
    required int totalScore,
    required String gameType,
    double? strikePercentage,
    int? splitCount,
    String? templateStyle,
    String? mediaUrl,
  });

  Future<Either<Failure, Post>> createPollPost({
    required String caption,
    required String audience,
    required String question,
    required List<String> options,
    required int expiryHours,
    String pollType = 'single',
  });
}

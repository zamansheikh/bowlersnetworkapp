import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/comment.dart';
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

  /// Hide post from this user's feed. For an owner, the backend treats this
  /// as a delete (matches web's "Delete" button behaviour).
  Future<Either<Failure, Unit>> hide(String postUid);

  /// Toggle pin. Returns the new pinned state.
  Future<Either<Failure, bool>> togglePin(String postUid);

  /// Enable/disable comments (post owner only). Returns the new state.
  Future<Either<Failure, bool>> togglePostComments(
    String postUid, {
    required bool enabled,
  });

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

  // ── Comments ────────────────────────────────────────────────────────────────
  Future<Either<Failure, List<Comment>>> listComments(
    String postUid, {
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, Comment>> createComment({
    required String postUid,
    required String text,
    int? parentId,
    String? mediaUrl,
  });

  Future<Either<Failure, Comment>> editComment({
    required int commentId,
    required String text,
  });

  Future<Either<Failure, Unit>> deleteComment(int commentId);

  /// Returns the new `has_liked` state.
  Future<Either<Failure, bool>> toggleCommentLike(int commentId);

  /// Post-owner only. Returns the new pinned state.
  Future<Either<Failure, bool>> toggleCommentPin(int commentId);

  /// Post-owner only. Returns the new hidden state.
  Future<Either<Failure, bool>> toggleCommentHide(int commentId);

  Future<Either<Failure, List<Comment>>> listReplies(
    int parentId, {
    int page = 1,
    int pageSize = 20,
  });

  // ── Share ───────────────────────────────────────────────────────────────────
  /// Repost another post. Empty caption is valid. Returns the newly-created
  /// shared post (matches web: direct repost, no caption modal).
  Future<Either<Failure, Post>> sharePost({
    required String postUid,
    String caption = '',
  });

  // ── Report ─────────────────────────────────────────────────────────────────
  Future<Either<Failure, Unit>> submitReport({
    required String contentType,
    required int contentId,
    required String reason,
    String? detail,
  });
}

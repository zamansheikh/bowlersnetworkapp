import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/chatter.dart';

/// Result of a toggle-upvote call. `action` is one of `added`, `removed`,
/// or `changed`; `voteType` is `upvote` / `downvote` / `null`.
class VoteToggleResult {
  const VoteToggleResult({required this.action, this.voteType});
  final String action;
  final String? voteType;

  bool get isUpvote => voteType == 'upvote';
  bool get wasRemoved => action == 'removed';
}

abstract class ChatterRepository {
  Future<Either<Failure, List<Topic>>> getTopics();

  Future<Either<Failure, ({List<Discussion> discussions, bool hasMore})>>
      getDiscussions({
    int? topicId,
    DiscussionSort sort = DiscussionSort.recent,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, Discussion>> getDiscussion(String uid);

  Future<Either<Failure, VoteToggleResult>> upvoteDiscussion(int id);

  Future<Either<Failure, ({List<Opinion> opinions, bool hasMore})>> getOpinions(
    int discussionId, {
    OpinionSort sort = OpinionSort.top,
    int page = 1,
    int pageSize = 20,
  });

  /// Post a top-level opinion (or a reply when [parentId] is provided).
  /// Returns the newly-created [Opinion] so the bloc can prepend it.
  Future<Either<Failure, Opinion>> postOpinion({
    required int discussionId,
    required String body,
    int? parentId,
  });

  Future<Either<Failure, VoteToggleResult>> upvoteOpinion(int id);
}

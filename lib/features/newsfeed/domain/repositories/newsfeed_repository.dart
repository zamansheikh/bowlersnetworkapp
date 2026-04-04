import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/post_models.dart';

abstract class NewsfeedRepository {
  Future<Either<Failure, List<PostModel>>> getFeed({int? cursor, int pageSize, String? filter});
  Future<Either<Failure, PostModel>> createTextPost({required String caption, String audience});
  Future<Either<Failure, PostModel>> createPhotoPost({required List<String> mediaUrls, String caption, String audience});
  Future<Either<Failure, Map<String, dynamic>>> react(int postId, String reactionType);
  Future<Either<Failure, bool>> toggleSave(int postId);
  Future<Either<Failure, void>> hidePost(int postId);
  Future<Either<Failure, void>> deletePost(int postId);
  Future<Either<Failure, List<CommentModel>>> getComments(int postId, {int page, int pageSize});
  Future<Either<Failure, CommentModel>> createComment(int postId, {required String text, int? parentId});
  Future<Either<Failure, bool>> toggleCommentLike(int commentId);
  Future<Either<Failure, void>> votePoll(int postId, int optionId);
}

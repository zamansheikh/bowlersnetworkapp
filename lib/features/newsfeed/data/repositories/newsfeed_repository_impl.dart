import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/newsfeed_repository.dart';
import '../datasources/newsfeed_remote_datasource.dart';
import '../models/post_models.dart';

@LazySingleton(as: NewsfeedRepository)
class NewsfeedRepositoryImpl implements NewsfeedRepository {
  final NewsfeedRemoteDataSource _remote;

  NewsfeedRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<PostModel>>> getFeed({int? cursor, int pageSize = 20, String? filter}) async {
    try { return Right(await _remote.getFeed(cursor: cursor, pageSize: pageSize, filter: filter)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, PostModel>> createTextPost({required String caption, String audience = 'public'}) async {
    try { return Right(await _remote.createTextPost(caption: caption, audience: audience)); }
    on ValidationException catch (e) { return Left(ValidationFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, PostModel>> createPhotoPost({required List<String> mediaUrls, String caption = '', String audience = 'public'}) async {
    try { return Right(await _remote.createPhotoPost(mediaUrls: mediaUrls, caption: caption, audience: audience)); }
    on ValidationException catch (e) { return Left(ValidationFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> react(int postId, String reactionType) async {
    try { return Right(await _remote.react(postId, reactionType)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, bool>> toggleSave(int postId) async {
    try { return Right(await _remote.toggleSave(postId)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> hidePost(int postId) async {
    try { await _remote.hidePost(postId); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> deletePost(int postId) async {
    try { await _remote.deletePost(postId); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, List<CommentModel>>> getComments(int postId, {int page = 1, int pageSize = 20}) async {
    try { return Right(await _remote.getComments(postId, page: page, pageSize: pageSize)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, CommentModel>> createComment(int postId, {required String text, int? parentId}) async {
    try { return Right(await _remote.createComment(postId, text: text, parentId: parentId)); }
    on ValidationException catch (e) { return Left(ValidationFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, bool>> toggleCommentLike(int commentId) async {
    try { return Right(await _remote.toggleCommentLike(commentId)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }

  @override
  Future<Either<Failure, void>> votePoll(int postId, int optionId) async {
    try { await _remote.votePoll(postId, optionId); return const Right(null); }
    on ServerException catch (e) { return Left(ServerFailure(e.message, statusCode: e.statusCode)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
  }
}

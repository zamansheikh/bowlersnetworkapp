import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/chatter.dart';
import '../../domain/repositories/chatter_repository.dart';
import '../datasources/chatter_remote_datasource.dart';
import '../models/chatter_dtos.dart';

@LazySingleton(as: ChatterRepository)
class ChatterRepositoryImpl implements ChatterRepository {
  ChatterRepositoryImpl(this._remote);

  final ChatterRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<Topic>>> getTopics() => _guard(() async {
        final res = await _remote.getTopics();
        return res.topics.map(_topic).toList(growable: false);
      });

  @override
  Future<Either<Failure, ({List<Discussion> discussions, bool hasMore})>>
      getDiscussions({
    int? topicId,
    DiscussionSort sort = DiscussionSort.recent,
    int page = 1,
    int pageSize = 20,
  }) =>
          _guard(() async {
            final res = await _remote.getDiscussions(
              topicId: topicId,
              sort: sort.apiValue,
              page: page,
              pageSize: pageSize,
            );
            return (
              discussions: res.discussions.map(_discussion).toList(growable: false),
              // The list endpoint doesn't expose total / next — infer "more"
              // from a full page (we just got pageSize items, so probably
              // there's another page).
              hasMore: res.discussions.length >= pageSize,
            );
          });

  @override
  Future<Either<Failure, Discussion>> getDiscussion(String uid) =>
      _guard(() async => _discussion(await _remote.getDiscussion(uid)));

  @override
  Future<Either<Failure, VoteToggleResult>> upvoteDiscussion(int id) =>
      _guard(() async {
        final res = await _remote.upvoteDiscussion(id);
        return VoteToggleResult(action: res.action, voteType: res.voteType);
      });

  @override
  Future<Either<Failure, ({List<Opinion> opinions, bool hasMore})>> getOpinions(
    int discussionId, {
    OpinionSort sort = OpinionSort.top,
    int page = 1,
    int pageSize = 20,
  }) =>
      _guard(() async {
        final res = await _remote.getOpinions(
          discussionId,
          sort: sort.apiValue,
          page: page,
          pageSize: pageSize,
        );
        return (
          opinions: res.opinions.map(_opinion).toList(growable: false),
          hasMore: res.opinions.length >= pageSize,
        );
      });

  @override
  Future<Either<Failure, Opinion>> postOpinion({
    required int discussionId,
    required String body,
    int? parentId,
  }) =>
      _guard(() async {
        final res = await _remote.postOpinion(discussionId, {
          'body': body,
          'parent_id': ?parentId,
        });
        return _opinion(res);
      });

  @override
  Future<Either<Failure, VoteToggleResult>> upvoteOpinion(int id) =>
      _guard(() async {
        final res = await _remote.upvoteOpinion(id);
        return VoteToggleResult(action: res.action, voteType: res.voteType);
      });

  // ── mappers ────────────────────────────────────────────────────────────────

  ChatterAuthor? _author(ChatterAuthorDto? dto) => dto == null
      ? null
      : ChatterAuthor(
          id: dto.id,
          username: dto.username,
          firstName: dto.firstName,
          lastName: dto.lastName,
          profilePictureUrl: dto.profilePictureUrl,
          isPro: dto.isPro,
          isElite: dto.isElite,
          rankDisplay: dto.rankDisplay,
          badgeIconUrl: dto.badgeIconUrl,
        );

  Topic _topic(TopicDto dto) => Topic(
        id: dto.id,
        name: dto.name,
        description: dto.description,
        bannerUrl: dto.bannerUrl,
        threadCount: dto.threadCount,
      );

  Discussion _discussion(DiscussionFullDto dto) => Discussion(
        id: dto.id,
        uid: dto.uid,
        title: dto.title,
        body: dto.body,
        author: _author(dto.author),
        topic: dto.topic == null ? null : _topic(dto.topic!),
        tags: List<String>.from(dto.tags),
        upvoteCount: dto.upvoteCount,
        downvoteCount: dto.downvoteCount,
        opinionCount: dto.opinionCount,
        viewCount: dto.viewCount,
        saveCount: dto.saveCount,
        isResolved: dto.isResolved,
        isLocked: dto.isLocked,
        isPinned: dto.isPinned,
        isEdited: dto.isEdited,
        isMostRead: dto.isMostRead,
        createdAt:
            dto.createdAt == null ? null : DateTime.tryParse(dto.createdAt!),
        isMine: dto.isMine,
        hasUpvoted: dto.hasUpvoted,
        hasDownvoted: dto.hasDownvoted,
        hasSaved: dto.hasSaved,
      );

  Opinion _opinion(OpinionDto dto) => Opinion(
        id: dto.id,
        body: dto.body,
        author: _author(dto.author),
        upvoteCount: dto.upvoteCount,
        downvoteCount: dto.downvoteCount,
        netScore: dto.netScore,
        replyCount: dto.replyCount,
        isAcknowledged: dto.isAcknowledged,
        isPinned: dto.isPinned,
        isEdited: dto.isEdited,
        isHidden: dto.isHidden,
        createdAt:
            dto.createdAt == null ? null : DateTime.tryParse(dto.createdAt!),
        parentId: dto.parentId,
        isMine: dto.isMine,
        hasUpvoted: dto.hasUpvoted,
        hasDownvoted: dto.hasDownvoted,
      );

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DioException catch (e) {
      final parsed = e.error;
      if (parsed is NetworkException) return const Left(NetworkFailure());
      if (parsed is ApiException) {
        if (parsed.statusCode == 401) {
          return Left(UnauthorizedFailure(messages: parsed.messages));
        }
        return Left(ServerFailure(
          messages: parsed.messages,
          statusCode: parsed.statusCode,
        ));
      }
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/newsfeed_repository.dart';
import '../datasources/newsfeed_remote_datasource.dart';
import '../models/post_dto.dart';

@LazySingleton(as: NewsfeedRepository)
class NewsfeedRepositoryImpl implements NewsfeedRepository {
  NewsfeedRepositoryImpl(this._remote);

  final NewsfeedRemoteDatasource _remote;

  @override
  Future<Either<Failure, FeedPage>> getFeed({
    String? filter,
    int? cursor,
    int pageSize = 20,
  }) {
    return _guard(() async {
      final res = await _remote.getFeed(
        filter: filter,
        cursor: cursor,
        pageSize: pageSize,
      );
      final posts = res.posts.map(_toPost).toList(growable: false);
      // Backend uses lowest id as next cursor. No sentinel; empty page = done.
      final next = posts.isEmpty
          ? null
          : posts.map((p) => p.id).reduce((a, b) => a < b ? a : b);
      return FeedPage(
        posts: posts,
        nextCursor: posts.length < pageSize ? null : next,
      );
    });
  }

  @override
  Future<Either<Failure, Post>> getPost(String uid) =>
      _guard(() async => _toPost(await _remote.getPost(uid)));

  @override
  Future<Either<Failure, ReactionType?>> react(
    String postUid,
    ReactionType reaction,
  ) {
    return _guard(() async {
      final res = await _remote.react(
        postUid,
        ReactionRequestDto(reactionType: reaction.apiValue),
      );
      return ReactionType.fromString(res.reactionType);
    });
  }

  @override
  Future<Either<Failure, bool>> toggleSave(String postUid) {
    return _guard(() async {
      final res = await _remote.toggleSave(postUid);
      return res.saved;
    });
  }

  @override
  Future<Either<Failure, Unit>> hide(String postUid) {
    return _guard(() async {
      await _remote.hidePost(postUid);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Post>> createTextPost({
    required String caption,
    required String audience,
  }) =>
      _guard(() async => _toPost(await _remote.createTextPost({
            'caption': caption,
            'audience': audience,
          })));

  @override
  Future<Either<Failure, Post>> createPhotoPost({
    required String caption,
    required String audience,
    required List<String> mediaUrls,
  }) =>
      _guard(() async => _toPost(await _remote.createPhotoPost({
            'caption': caption,
            'audience': audience,
            'media_urls': mediaUrls,
          })));

  @override
  Future<Either<Failure, Post>> createVideoPost({
    required String caption,
    required String audience,
    required String videoUrl,
    String? thumbnailUrl,
  }) =>
      _guard(() async => _toPost(await _remote.createVideoPost({
            'caption': caption,
            'audience': audience,
            'video_url': videoUrl,
            'thumbnail_url': ?thumbnailUrl,
          })));

  @override
  Future<Either<Failure, Post>> createScorePost({
    required String caption,
    required String audience,
    required int totalScore,
    required String gameType,
    double? strikePercentage,
    int? splitCount,
    String? templateStyle,
    String? mediaUrl,
  }) =>
      _guard(() async => _toPost(await _remote.createScorePost({
            'caption': caption,
            'audience': audience,
            'total_score': totalScore,
            'game_type': gameType,
            'strike_percentage': ?strikePercentage,
            'split_count': ?splitCount,
            'template_style': ?templateStyle,
            'media_url': ?mediaUrl,
          })));

  @override
  Future<Either<Failure, Post>> createPollPost({
    required String caption,
    required String audience,
    required String question,
    required List<String> options,
    required int expiryHours,
    String pollType = 'single',
  }) =>
      _guard(() async => _toPost(await _remote.createPollPost({
            'caption': caption,
            'audience': audience,
            'question': question,
            'options': options.map((t) => {'text': t}).toList(),
            'expiry_hours': expiryHours,
            'poll_type': pollType,
          })));

  // ---------------------------------------------------------------------------
  Post _toPost(PostDto dto) {
    return Post(
      id: dto.id,
      uid: dto.uid,
      type: PostType.fromString(dto.postType),
      author: PostAuthor(
        id: dto.author.id,
        username: dto.author.username,
        firstName: dto.author.firstName,
        lastName: dto.author.lastName,
        profilePictureUrl: dto.author.profilePictureUrl,
        isPro: dto.author.isPro,
        level: dto.author.level,
        rank: dto.author.rank,
      ),
      createdAt: DateTime.tryParse(dto.createdAt) ?? DateTime.now(),
      caption: dto.caption,
      audience: dto.audience,
      isEdited: dto.isEdited,
      isPinned: dto.isPinned,
      isCommentsEnabled: dto.isCommentsEnabled,
      likesCount: dto.likesCount,
      commentsCount: dto.commentsCount,
      sharesCount: dto.sharesCount,
      savesCount: dto.savesCount,
      isMine: dto.isMine,
      hasReacted: dto.hasReacted,
      hasSaved: dto.hasSaved,
      reaction: ReactionType.fromString(dto.reactionType),
      typeData: dto.typeData,
    );
  }

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
        return Left(
          ServerFailure(
            messages: parsed.messages,
            statusCode: parsed.statusCode,
          ),
        );
      }
      return const Left(ServerFailure());
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}

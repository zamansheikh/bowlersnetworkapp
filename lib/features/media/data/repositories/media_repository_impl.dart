import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/media_item.dart';
import '../../domain/repositories/media_repository.dart';
import '../datasources/media_remote_datasource.dart';
import '../models/media_dtos.dart';

@LazySingleton(as: MediaRepository)
class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl(this._remote);

  final MediaRemoteDatasource _remote;

  @override
  Future<Either<Failure, ({List<MediaItem> items, bool hasMore})>>
      getUserVideos({
    required String username,
    int page = 1,
    int pageSize = 20,
  }) =>
          _guard(() async {
            final res = await _remote.getUserVideos(
              username,
              page: page,
              pageSize: pageSize,
            );
            final items =
                res.videos.map(_videoToItem).toList(growable: false);
            return (items: items, hasMore: items.length >= pageSize);
          });

  @override
  Future<Either<Failure, ({List<MediaItem> items, bool hasMore})>>
      getUserSplits({
    required String username,
    int page = 1,
    int pageSize = 20,
  }) =>
          _guard(() async {
            final res = await _remote.getUserSplits(
              username,
              page: page,
              pageSize: pageSize,
            );
            final items =
                res.splits.map(_splitToItem).toList(growable: false);
            return (items: items, hasMore: items.length >= pageSize);
          });

  @override
  Future<Either<Failure, ({List<MediaItem> items, bool hasMore})>>
      getGlobalVideos({int page = 1, int pageSize = 20}) =>
          _guard(() async {
            final res = await _remote.getGlobalVideos(
              page: page,
              pageSize: pageSize,
            );
            final items =
                res.videos.map(_videoToItem).toList(growable: false);
            return (items: items, hasMore: items.length >= pageSize);
          });

  @override
  Future<Either<Failure, ({List<MediaItem> items, bool hasMore})>>
      getGlobalSplits({int page = 1, int pageSize = 20}) =>
          _guard(() async {
            final res = await _remote.getGlobalSplits(
              page: page,
              pageSize: pageSize,
            );
            final items =
                res.splits.map(_splitToItem).toList(growable: false);
            return (items: items, hasMore: items.length >= pageSize);
          });

  MediaAuthor? _author(MediaAuthorDto? dto) => dto == null
      ? null
      : MediaAuthor(
          id: dto.id,
          username: dto.username,
          firstName: dto.firstName,
          lastName: dto.lastName,
          profilePictureUrl: dto.profilePictureUrl,
          isPro: dto.isPro,
        );

  MediaItem _videoToItem(VideoDto v) => MediaItem(
        id: v.id,
        uid: v.uid,
        kind: MediaKind.video,
        title: v.title,
        videoUrl: v.videoUrl,
        thumbnailUrl: v.thumbnailUrl,
        durationSeconds: v.durationSeconds,
        durationDisplay: v.durationDisplay,
        author: _author(v.author),
        likesCount: v.likesCount,
        commentsCount: v.commentsCount,
        viewsCount: v.viewsCount,
        savesCount: v.savesCount,
        isPinned: v.isPinned,
        createdAt: v.createdAt == null ? null : DateTime.tryParse(v.createdAt!),
        hasLiked: v.hasLiked,
        hasSaved: v.hasSaved,
        isMine: v.isMine,
      );

  MediaItem _splitToItem(SplitDto s) => MediaItem(
        id: s.id,
        uid: s.uid,
        kind: MediaKind.split,
        title: s.caption,
        videoUrl: s.videoUrl,
        thumbnailUrl: s.thumbnailUrl,
        durationSeconds: s.durationSeconds,
        durationDisplay: s.durationDisplay,
        author: _author(s.author),
        likesCount: s.likesCount,
        commentsCount: s.commentsCount,
        viewsCount: s.viewsCount,
        savesCount: s.savesCount,
        isPinned: s.isPinned,
        createdAt: s.createdAt == null ? null : DateTime.tryParse(s.createdAt!),
        hasLiked: s.hasLiked,
        hasSaved: s.hasSaved,
        isMine: s.isMine,
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

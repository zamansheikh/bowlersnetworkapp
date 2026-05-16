import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/home_previews.dart';
import '../../domain/repositories/home_preview_repository.dart';
import '../datasources/home_preview_datasource.dart';
import '../models/home_preview_dtos.dart';

@LazySingleton(as: HomePreviewRepository)
class HomePreviewRepositoryImpl implements HomePreviewRepository {
  HomePreviewRepositoryImpl(this._remote);

  final HomePreviewDatasource _remote;

  @override
  Future<Either<Failure, List<DiscussionPreview>>> getTopDiscussions({
    int pageSize = 3,
  }) =>
      _guard(() async {
        final res = await _remote.getDiscussions(page: 1, pageSize: pageSize);
        return res.discussions
            .map((d) => DiscussionPreview(
                  uid: d.uid,
                  title: d.title,
                  topic: d.topic?.name ?? '',
                  upvoteCount: d.upvoteCount,
                  opinionCount: d.opinionCount,
                  isResolved: d.isResolved,
                  author: _author(d.author),
                ))
            .toList(growable: false);
      });

  @override
  Future<Either<Failure, List<MediaPreview>>> getTrendingMedia({
    int limit = 4,
  }) =>
      _guard(() async {
        // Fetch both lists in parallel and interleave.
        final results = await Future.wait<dynamic>([
          _remote.getVideos(pageSize: limit),
          _remote.getSplits(pageSize: limit),
        ]);
        final videos = (results[0] as VideosPageDto)
            .videos
            .map((m) => _media(m, MediaKind.video));
        final splits = (results[1] as SplitsPageDto)
            .splits
            .map((m) => _media(m, MediaKind.split));
        return [...videos, ...splits].take(limit).toList(growable: false);
      });

  @override
  Future<Either<Failure, List<EventPreview>>> getUpcomingEvents({
    int pageSize = 3,
  }) =>
      _guard(() async {
        final res = await _remote.getEvents(
          page: 1,
          pageSize: pageSize,
          scope: 'upcoming',
        );
        return res.events.map(_event).toList(growable: false);
      });

  @override
  Future<Either<Failure, List<LiveBroadcastPreview>>>
      getLiveFromFollowing() => _guard(() async {
        final res = await _remote.getLiveBroadcasts(scope: 'following');
        return res.entries
            .map((e) => LiveBroadcastPreview(
                  id: e.id,
                  uid: e.uid,
                  title: e.title,
                  viewerCount: e.viewerCount,
                  interactionsCount: e.reactionsCount + e.commentsCount,
                  user: _author(e.user),
                ))
            .toList(growable: false);
      });

  // ── mappers ───────────────────────────────────────────────────────────────
  PreviewAuthor? _author(HomePreviewUserDto? dto) {
    if (dto == null) return null;
    return PreviewAuthor(
      id: dto.id,
      username: dto.username,
      firstName: dto.firstName,
      lastName: dto.lastName,
      profilePictureUrl: dto.profilePictureUrl,
      badgeIconUrl: dto.badgeIconUrl,
    );
  }

  MediaPreview _media(MediaItemDto dto, MediaKind kind) => MediaPreview(
        uid: dto.uid,
        kind: kind,
        title: dto.title,
        thumbnailUrl: dto.thumbnailUrl,
        viewsCount: dto.viewsCount,
        author: _author(dto.author),
      );

  EventPreview _event(EventItemDto dto) {
    // Web's location resolution: center.name → location.address → location.name
    // → "TBA" fallback.
    final loc = dto.location;
    String label;
    if (dto.isOnline) {
      label = 'Online Event';
    } else if (loc?.center?.name != null && loc!.center!.name!.isNotEmpty) {
      label = loc.center!.name!;
    } else if (loc?.address != null && loc!.address!.isNotEmpty) {
      label = loc.address!;
    } else if (loc?.name != null && loc!.name!.isNotEmpty) {
      label = loc.name!;
    } else {
      label = 'TBA';
    }
    return EventPreview(
      uid: dto.uid,
      title: dto.title,
      eventDate:
          dto.eventDate == null ? null : DateTime.tryParse(dto.eventDate!),
      eventTypeName: dto.eventType?.name ?? '',
      locationLabel: label,
      isOnline: dto.isOnline,
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

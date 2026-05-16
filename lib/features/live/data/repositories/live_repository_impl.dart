import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/live_broadcast.dart';
import '../../domain/entities/live_viewer.dart';
import '../../domain/repositories/live_repository.dart';
import '../datasources/live_remote_datasource.dart';
import '../models/live_dtos.dart';

@LazySingleton(as: LiveRepository)
class LiveRepositoryImpl implements LiveRepository {
  LiveRepositoryImpl(this._remote);

  final LiveRemoteDatasource _remote;

  @override
  Future<Either<Failure, LiveBroadcast>> startBroadcast({
    required String sessionUid,
    String title = '',
  }) =>
      _guard(() async {
        final dto = await _remote.start({
          'session_uid': sessionUid,
          if (title.isNotEmpty) 'title': title,
        });
        return _toEntity(dto);
      });

  @override
  Future<Either<Failure, Unit>> endBroadcast(int livescoreId) =>
      _guard(() async {
        await _remote.end(livescoreId);
        return unit;
      });

  @override
  Future<Either<Failure, LiveBroadcast?>> getMyActive() => _guard(() async {
        final wrapper = await _remote.myActive();
        return wrapper.active == null ? null : _toEntity(wrapper.active!);
      });

  // ── Viewer side ──────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ({List<LiveBroadcastListItem> items, int? nextCursorId})>>
      getLives({
    required LiveListScope scope,
    int? cursorId,
  }) =>
          _guard(() async {
            final dto = await _remote.list(
              scope: scope.wire,
              cursorId: cursorId,
            );
            return (
              items: dto.results
                  .map(_toListItem)
                  .toList(growable: false),
              nextCursorId: dto.nextCursorId,
            );
          });

  @override
  Future<Either<Failure, LiveBroadcastDetail>> getLiveByUid(String uid) =>
      _guard(() async => _toDetail(await _remote.getDetailByUid(uid)));

  @override
  Future<Either<Failure, LiveBroadcastDetail>> getLiveById(int id) =>
      _guard(() async => _toDetail(await _remote.getDetailById(id)));

  @override
  Future<Either<Failure, LiveCommentsPage>> getComments({
    required int liveId,
    int? cursorId,
  }) =>
      _guard(() async {
        final dto = await _remote.getComments(liveId, cursorId: cursorId);
        return LiveCommentsPage(
          comments: dto.results.map(_toComment).toList(growable: false),
          nextCursorId: dto.nextCursorId,
        );
      });

  @override
  Future<Either<Failure, LiveBroadcastComment>> postComment({
    required int liveId,
    required String body,
  }) =>
      _guard(() async {
        final dto = await _remote.postComment(liveId, {'body': body});
        return _toComment(dto);
      });

  @override
  Future<Either<Failure, Unit>> deleteComment({
    required int liveId,
    required int commentId,
  }) =>
      _guard(() async {
        await _remote.deleteComment(liveId, commentId);
        return unit;
      });

  @override
  Future<Either<Failure, LiveReactionType?>> react({
    required int liveId,
    required LiveReactionType type,
  }) =>
      _guard(() async {
        final res = await _remote.react(liveId, {'reaction_type': type.wire});
        return LiveReactionType.fromWire(res.reactionType);
      });

  @override
  Future<Either<Failure, Unit>> removeReaction(int liveId) =>
      _guard(() async {
        await _remote.removeReaction(liveId);
        return unit;
      });

  @override
  LiveGame parseLiveGame(Map<String, dynamic> raw) =>
      _toGame(LiveGameDto.fromJson(raw));

  @override
  LiveBroadcastComment parseLiveComment(Map<String, dynamic> raw) =>
      _toComment(LiveCommentDto.fromJson(raw));

  // ── Mappers ──────────────────────────────────────────────────────────────

  LiveBroadcastUser? _toUser(LiveBroadcastUserDto? dto) {
    if (dto == null) return null;
    return LiveBroadcastUser(
      id: dto.id,
      username: dto.username,
      firstName: dto.firstName,
      lastName: dto.lastName,
      profilePictureUrl: dto.profilePictureUrl,
      isPro: dto.isPro,
      level: dto.level,
      rankDisplay: dto.rankDisplay,
      badgeIconUrl: dto.badgeIconUrl,
      isFollowing: dto.isFollowing,
    );
  }

  LiveBroadcastListItem _toListItem(LiveBroadcastListItemDto dto) =>
      LiveBroadcastListItem(
        id: dto.id,
        uid: dto.uid,
        title: dto.title,
        status: LiveStatus.fromWire(dto.status),
        viewerCount: dto.viewerCount,
        viewerPeak: dto.viewerPeak,
        reactionsCount: dto.reactionsCount,
        commentsCount: dto.commentsCount,
        startedAt: dto.startedAt == null
            ? null
            : DateTime.tryParse(dto.startedAt!),
        user: _toUser(dto.user),
      );

  LiveBroadcastDetail _toDetail(LiveBroadcastDetailDto dto) =>
      LiveBroadcastDetail(
        id: dto.id,
        uid: dto.uid,
        title: dto.title,
        status: LiveStatus.fromWire(dto.status),
        endReason: LiveEndReason.fromWire(dto.endReason),
        viewerCount: dto.viewerCount,
        viewerPeak: dto.viewerPeak,
        reactionsCount: dto.reactionsCount,
        commentsCount: dto.commentsCount,
        invitesCount: dto.invitesCount,
        streamedMinutes: dto.streamedMinutes,
        startedAt: dto.startedAt == null
            ? null
            : DateTime.tryParse(dto.startedAt!),
        endedAt: dto.endedAt == null ? null : DateTime.tryParse(dto.endedAt!),
        lastFrameAt: dto.lastFrameAt == null
            ? null
            : DateTime.tryParse(dto.lastFrameAt!),
        sharePostUid: dto.sharePostUid,
        user: _toUser(dto.user),
        isOwner: dto.isOwner,
        myReaction: LiveReactionType.fromWire(dto.myReaction),
        reactionSummary: Map<String, int>.from(dto.reactionSummary),
        session: dto.session == null
            ? const LiveSession()
            : LiveSession(
                uid: dto.session!.uid,
                games: dto.session!.games
                    .map(_toGame)
                    .toList(growable: false),
              ),
      );

  LiveGame _toGame(LiveGameDto dto) => LiveGame(
        id: dto.id,
        gameNumber: dto.gameNumber,
        totalScore: dto.totalScore,
        isComplete: dto.isComplete,
        frames: dto.frames.map(_toFrame).toList(growable: false),
      );

  LiveGameFrame _toFrame(LiveGameFrameDto dto) => LiveGameFrame(
        frameNumber: dto.frameNumber,
        isStrike: dto.isStrike,
        isSpare: dto.isSpare,
        pinfall: dto.pinfall,
        frameScore: dto.frameScore,
        ball1PinsStanding: dto.ball1PinsStanding,
        ball2PinsStanding: dto.ball2PinsStanding,
        ball3PinsStanding: dto.ball3PinsStanding,
      );

  LiveBroadcastComment _toComment(LiveCommentDto dto) => LiveBroadcastComment(
        id: dto.id,
        body: dto.body,
        createdAt: dto.createdAt == null
            ? DateTime.now()
            : DateTime.tryParse(dto.createdAt!) ?? DateTime.now(),
        user: _toUser(dto.user),
      );

  LiveBroadcast _toEntity(LiveBroadcastDto dto) => LiveBroadcast(
        id: dto.id,
        uid: dto.uid,
        title: dto.title,
        viewerCount: dto.viewerCount,
        sessionUid: dto.sessionUid,
        currentGameId: dto.currentGame?.id,
        currentGameNumber: dto.currentGame?.gameNumber,
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

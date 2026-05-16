import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/live_broadcast.dart';
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

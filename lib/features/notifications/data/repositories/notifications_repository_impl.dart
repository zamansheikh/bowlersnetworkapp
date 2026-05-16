import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';
import '../models/notification_preferences_dto.dart';

@LazySingleton(as: NotificationsRepository)
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._remote);

  final NotificationsRemoteDatasource _remote;

  @override
  Future<Either<Failure, NotificationPreferences>> getPreferences() =>
      _guard(() async => _toEntity(await _remote.getPreferences()));

  @override
  Future<Either<Failure, NotificationPreferences>> setPreference({
    required NotificationKind kind,
    required bool value,
  }) =>
      _guard(() async {
        final res = await _remote.updatePreferences({kind.apiKey: value});
        return _toEntity(res);
      });

  NotificationPreferences _toEntity(NotificationPreferencesDto dto) =>
      NotificationPreferences(
        reactions: dto.reactions,
        comments: dto.comments,
        follows: dto.follows,
        chatterVotes: dto.chatterVotes,
        eventInvitations: dto.eventInvitations,
        teamInvitations: dto.teamInvitations,
        cardCollections: dto.cardCollections,
        messages: dto.messages,
        xpLevelUps: dto.xpLevelUps,
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

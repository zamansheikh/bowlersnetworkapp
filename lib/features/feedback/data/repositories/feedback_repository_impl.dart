import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/feedback_draft.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../datasources/feedback_remote_datasource.dart';

@LazySingleton(as: FeedbackRepository)
class FeedbackRepositoryImpl implements FeedbackRepository {
  FeedbackRepositoryImpl(this._remote);

  final FeedbackRemoteDatasource _remote;

  @override
  Future<Either<Failure, FeedbackSubmitted>> submit({
    required FeedbackCategory category,
    required String title,
    required String body,
    FeedbackArea area = FeedbackArea.other,
    bool isPublic = true,
  }) async {
    try {
      final res = await _remote.submit({
        'category': category.apiValue,
        'title': title,
        'body': body,
        'feature_area': area.apiValue,
        'is_public': isPublic,
      });
      return Right(FeedbackSubmitted(uid: res.uid, title: res.title));
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

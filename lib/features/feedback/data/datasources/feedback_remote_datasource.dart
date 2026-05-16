import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/feedback_dtos.dart';

part 'feedback_remote_datasource.g.dart';

/// Wire to /api/feedback/submit. Only the submit verb is exposed for v1
/// — feed / upvote / rating endpoints get their own datasource if/when
/// we ship the feedback browsing UI.
@injectable
@RestApi()
abstract class FeedbackRemoteDatasource {
  @factoryMethod
  factory FeedbackRemoteDatasource(Dio dio) = _FeedbackRemoteDatasource;

  @POST(Endpoints.feedbackSubmit)
  Future<FeedbackCreatedDto> submit(@Body() Map<String, dynamic> body);
}

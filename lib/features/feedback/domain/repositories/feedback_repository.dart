import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/feedback_draft.dart';

abstract class FeedbackRepository {
  /// POST /api/feedback/submit. Returns the created feedback's uid +
  /// title on success.
  Future<Either<Failure, FeedbackSubmitted>> submit({
    required FeedbackCategory category,
    required String title,
    required String body,
    FeedbackArea area = FeedbackArea.other,
    bool isPublic = true,
  });
}

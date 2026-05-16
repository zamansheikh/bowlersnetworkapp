import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/home_previews.dart';

abstract class HomePreviewRepository {
  Future<Either<Failure, List<DiscussionPreview>>> getTopDiscussions({
    int pageSize = 3,
  });

  /// Combined videos + splits feed, capped at [limit]. Web slices the two
  /// lists down to 4 total for the home grid.
  Future<Either<Failure, List<MediaPreview>>> getTrendingMedia({
    int limit = 4,
  });

  Future<Either<Failure, List<EventPreview>>> getUpcomingEvents({
    int pageSize = 3,
  });

  /// Live broadcasts from people the viewer follows.
  Future<Either<Failure, List<LiveBroadcastPreview>>> getLiveFromFollowing();
}

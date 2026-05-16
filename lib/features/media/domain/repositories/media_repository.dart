import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/media_item.dart';

abstract class MediaRepository {
  /// Paginated list of videos owned by [userId]. `hasMore` is inferred
  /// from the page being full (backend exposes no `next` cursor).
  Future<Either<Failure, ({List<MediaItem> items, bool hasMore})>>
      getUserVideos({
    required int userId,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, ({List<MediaItem> items, bool hasMore})>>
      getUserSplits({
    required int userId,
    int page = 1,
    int pageSize = 20,
  });
}

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/media_item.dart';

abstract class MediaRepository {
  /// Paginated videos for the channel owned by [username]. `hasMore` is
  /// inferred from the page being full (backend exposes no `next`).
  Future<Either<Failure, ({List<MediaItem> items, bool hasMore})>>
      getUserVideos({
    required String username,
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, ({List<MediaItem> items, bool hasMore})>>
      getUserSplits({
    required String username,
    int page = 1,
    int pageSize = 20,
  });
}

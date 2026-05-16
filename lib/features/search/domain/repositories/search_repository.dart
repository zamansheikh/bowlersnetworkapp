import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/search_result.dart';

abstract class SearchRepository {
  /// Central Predictive Search. Min query length is enforced server-side
  /// (400 when <2 chars), but callers are still expected to debounce.
  ///
  /// [types] is an optional comma-separated subset of
  /// `users,posts,discussions,centers,brands,events,videos,splits,cards`.
  /// Pass `null` to query every group.
  Future<Either<Failure, SearchResults>> search({
    required String query,
    String? types,
  });

  /// Centers-only paginated search — used by the home-center
  /// autocomplete in the edit-profile screen.
  Future<Either<Failure, List<CenterSearchResult>>> searchCenters({
    required String query,
    int limit = 10,
    int offset = 0,
  });
}

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/follow_user.dart';

abstract class FollowRepository {
  /// Toggle the viewer's follow on [userId]. Backend uses a single GET
  /// endpoint that flips state and returns `{is_following, follower_count}`.
  Future<Either<Failure, FollowToggleResult>> toggleFollow(int userId);

  /// People who follow the viewer.
  Future<Either<Failure, List<FollowUser>>> getMyFollowers();

  /// People the viewer is following.
  Future<Either<Failure, List<FollowUser>>> getMyFollowings();

  /// People who follow [userId] (any user, viewer-scoped relationship).
  Future<Either<Failure, List<FollowUser>>> getUserFollowers(int userId);

  /// People [userId] follows.
  Future<Either<Failure, List<FollowUser>>> getUserFollowings(int userId);
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/post.dart';
import '../repositories/newsfeed_repository.dart';

class GetFeedParams extends Equatable {
  const GetFeedParams({this.filter, this.cursor, this.pageSize = 20});

  final String? filter;
  final int? cursor;
  final int pageSize;

  @override
  List<Object?> get props => [filter, cursor, pageSize];
}

@lazySingleton
class GetFeedUseCase implements UseCase<FeedPage, GetFeedParams> {
  const GetFeedUseCase(this._repository);
  final NewsfeedRepository _repository;

  @override
  Future<Either<Failure, FeedPage>> call(GetFeedParams params) =>
      _repository.getFeed(
        filter: params.filter,
        cursor: params.cursor,
        pageSize: params.pageSize,
      );
}

class ReactParams extends Equatable {
  const ReactParams({required this.postUid, required this.reaction});
  final String postUid;
  final ReactionType reaction;
  @override
  List<Object?> get props => [postUid, reaction];
}

@lazySingleton
class ReactToPostUseCase implements UseCase<ReactionType?, ReactParams> {
  const ReactToPostUseCase(this._repository);
  final NewsfeedRepository _repository;

  @override
  Future<Either<Failure, ReactionType?>> call(ReactParams params) =>
      _repository.react(params.postUid, params.reaction);
}

@lazySingleton
class ToggleSavePostUseCase implements UseCase<bool, String> {
  const ToggleSavePostUseCase(this._repository);
  final NewsfeedRepository _repository;

  @override
  Future<Either<Failure, bool>> call(String postUid) =>
      _repository.toggleSave(postUid);
}

@lazySingleton
class HidePostUseCase implements UseCase<Unit, String> {
  const HidePostUseCase(this._repository);
  final NewsfeedRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String postUid) =>
      _repository.hide(postUid);
}

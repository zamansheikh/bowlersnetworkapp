import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../datasources/search_remote_datasource.dart';
import '../models/search_dtos.dart';

@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._remote);

  final SearchRemoteDatasource _remote;

  @override
  Future<Either<Failure, List<CenterSearchResult>>> searchCenters({
    required String query,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final res = await _remote.searchCenters(
        query: query,
        limit: limit,
        offset: offset,
      );
      return Right(
        res.results
            .map((c) => CenterSearchResult(
                  id: c.id,
                  name: c.name,
                  address: c.address,
                  logo: c.logo,
                ))
            .toList(growable: false),
      );
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

  @override
  Future<Either<Failure, SearchResults>> search({
    required String query,
    String? types,
  }) async {
    try {
      final res = await _remote.search(query: query, types: types);
      return Right(_map(res.results));
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

  SearchResults _map(SearchGroupsDto g) => SearchResults(
        users: g.users
            .map((u) => UserSearchResult(
                  id: u.id,
                  username: u.username,
                  fullName: u.fullName.isNotEmpty
                      ? u.fullName
                      : '${u.firstName} ${u.lastName}'.trim(),
                  profilePictureUrl: u.profilePictureUrl,
                  isPro: u.isPro,
                ))
            .toList(growable: false),
        posts: g.posts
            .map((p) => PostSearchResult(
                  uid: p.uid,
                  caption: p.caption,
                  authorName: p.authorName,
                  authorProfilePictureUrl: p.authorProfilePictureUrl,
                  likesCount: p.likesCount,
                ))
            .toList(growable: false),
        discussions: g.discussions
            .map((d) => DiscussionSearchResult(
                  uid: d.uid,
                  title: d.title,
                  topicName: d.topicName,
                  authorName: d.authorName,
                  upvoteCount: d.upvoteCount,
                  opinionCount: d.opinionCount,
                  isResolved: d.isResolved,
                ))
            .toList(growable: false),
        centers: g.centers
            .map((c) => CenterSearchResult(
                  id: c.id,
                  name: c.name,
                  address: c.address,
                  logo: c.logo,
                ))
            .toList(growable: false),
        brands: g.brands
            .map((b) => BrandSearchResult(
                  id: b.id,
                  name: b.name,
                  brandType: b.brandType,
                  formalName: b.formalName,
                  logoUrl: b.logoUrl,
                ))
            .toList(growable: false),
        events: g.events
            .map((e) => EventSearchResult(
                  uid: e.uid,
                  title: e.title,
                  eventTypeName: e.eventTypeName,
                  eventDate: e.eventDate == null
                      ? null
                      : DateTime.tryParse(e.eventDate!),
                  address: e.address,
                  isOnline: e.isOnline,
                ))
            .toList(growable: false),
        videos: g.videos
            .map((v) => VideoSearchResult(
                  uid: v.uid,
                  title: v.title,
                  thumbnailUrl: v.thumbnailUrl,
                  authorName: v.authorName,
                  durationSeconds: v.durationSeconds,
                  viewsCount: v.viewsCount,
                ))
            .toList(growable: false),
        splits: g.splits
            .map((s) => SplitSearchResult(
                  uid: s.uid,
                  caption: s.caption,
                  thumbnailUrl: s.thumbnailUrl,
                  authorName: s.authorName,
                ))
            .toList(growable: false),
        cards: g.cards
            .map((c) => CardSearchResult(
                  uid: c.uid,
                  displayName: c.displayName,
                  cardType: c.cardType,
                  displayImageUrl: c.displayImageUrl,
                  ownerUsername: c.ownerUsername,
                  ownerFullName: c.ownerFullName,
                ))
            .toList(growable: false),
      );
}

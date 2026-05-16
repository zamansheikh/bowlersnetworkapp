import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/trading_card.dart';
import '../../domain/repositories/cards_repository.dart';
import '../datasources/cards_remote_datasource.dart';
import '../models/card_dtos.dart';

@LazySingleton(as: CardsRepository)
class CardsRepositoryImpl implements CardsRepository {
  CardsRepositoryImpl(this._remote);

  final CardsRemoteDatasource _remote;

  @override
  Future<Either<Failure, ({List<TradingCard> cards, bool hasMore})>>
      getMyCards({int page = 1, int pageSize = 20}) =>
          _guard(() async {
            final res =
                await _remote.getMyCards(page: page, pageSize: pageSize);
            return _toPage(res, pageSize);
          });

  @override
  Future<Either<Failure, ({List<TradingCard> cards, bool hasMore})>>
      getMyCollections({int page = 1, int pageSize = 20}) =>
          _guard(() async {
            final res = await _remote.getMyCollections(
              page: page,
              pageSize: pageSize,
            );
            return _toPage(res, pageSize);
          });

  @override
  Future<Either<Failure, ({List<TradingCard> cards, bool hasMore})>>
      getUserCards({
    required int userId,
    int page = 1,
    int pageSize = 20,
  }) =>
          _guard(() async {
            final res = await _remote.getUserCards(
              userId,
              page: page,
              pageSize: pageSize,
            );
            return _toPage(res, pageSize);
          });

  @override
  Future<Either<Failure, CardLikeResult>> toggleLike(int cardId) =>
      _guard(() async {
        final res = await _remote.toggleLike(cardId);
        return CardLikeResult(
          isLiked: res.isLiked,
          likesCount: res.likesCount,
        );
      });

  @override
  Future<Either<Failure, CardCollectResult>> toggleCollect(int cardId) =>
      _guard(() async {
        final res = await _remote.toggleCollect(cardId);
        return CardCollectResult(
          isCollected: res.isCollected,
          collectionsCount: res.collectionsCount,
        );
      });

  ({List<TradingCard> cards, bool hasMore}) _toPage(
    CardsPageDto dto,
    int pageSize,
  ) {
    final cards = dto.cards.map(_toCard).toList(growable: false);
    return (cards: cards, hasMore: cards.length >= pageSize);
  }

  /// Each list item is wrapped in an envelope `{card, info, brands}`;
  /// we only need the `card` slice for the tile rendering.
  TradingCard _toCard(CardEnvelopeDto envelope) {
    final inner = envelope.card;
    return TradingCard(
      id: inner.cardId,
      uid: inner.uid,
      cardType: inner.cardType,
      isSealed: inner.isSealed,
      displayName: inner.displayName,
      displayImageUrl: inner.displayImageUrl,
      quote: inner.quote,
      accentHue: inner.accentHue,
      design: inner.design == null
          ? null
          : CardDesign(
              id: inner.design!.id,
              name: inner.design!.name,
              codeName: inner.design!.codeName,
              theme: inner.design!.theme,
            ),
      owner: inner.owner == null
          ? null
          : TradingCardOwner(
              id: inner.owner!.id,
              username: inner.owner!.username,
              firstName: inner.owner!.firstName,
              lastName: inner.owner!.lastName,
              profilePictureUrl: inner.owner!.profilePictureUrl,
              isPro: inner.owner!.isPro,
              level: inner.owner!.level,
              rankDisplay: inner.owner!.rankDisplay,
              badgeIconUrl: inner.owner!.badgeIconUrl,
            ),
      likesCount: inner.likesCount,
      collectionsCount: inner.collectionsCount,
      isLiked: inner.isLiked,
      isCollected: inner.isCollected,
      createdAt: inner.createdAtIso == null
          ? null
          : DateTime.tryParse(inner.createdAtIso!),
      rawPayload: envelope.raw,
    );
  }

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
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

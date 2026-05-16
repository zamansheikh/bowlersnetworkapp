import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/trading_card.dart';

abstract class CardsRepository {
  /// Logged-in user's own cards.
  Future<Either<Failure, ({List<TradingCard> cards, bool hasMore})>>
      getMyCards({
    int page = 1,
    int pageSize = 20,
  });

  /// Cards the logged-in user has collected from others. No equivalent
  /// endpoint exists for other users, so this is self-only.
  Future<Either<Failure, ({List<TradingCard> cards, bool hasMore})>>
      getMyCollections({
    int page = 1,
    int pageSize = 20,
  });

  /// Cards created by another user (their public catalog).
  Future<Either<Failure, ({List<TradingCard> cards, bool hasMore})>>
      getUserCards({
    required int userId,
    int page = 1,
    int pageSize = 20,
  });

  /// Global cards feed — newest first across all users. Powers the
  /// /cards drawer entry.
  Future<Either<Failure, ({List<TradingCard> cards, bool hasMore})>>
      getCardsFeed({
    int page = 1,
    int pageSize = 20,
  });

  Future<Either<Failure, CardLikeResult>> toggleLike(int cardId);

  Future<Either<Failure, CardCollectResult>> toggleCollect(int cardId);
}

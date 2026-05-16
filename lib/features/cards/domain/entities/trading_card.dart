import 'package:equatable/equatable.dart';

class TradingCardOwner extends Equatable {
  const TradingCardOwner({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.level,
    this.rankDisplay,
    this.badgeIconUrl,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String? profilePictureUrl;
  final bool isPro;
  final int? level;
  final String? rankDisplay;
  final String? badgeIconUrl;

  String get displayName {
    final full = '$firstName $lastName'.trim();
    return full.isEmpty ? username : full;
  }

  @override
  List<Object?> get props => [
        id,
        username,
        firstName,
        lastName,
        profilePictureUrl,
        isPro,
        level,
        rankDisplay,
        badgeIconUrl,
      ];
}

class CardDesign extends Equatable {
  const CardDesign({
    required this.id,
    required this.name,
    this.codeName = '',
    this.theme,
  });
  final int id;
  final String name;
  final String codeName;

  /// Raw theme blob from the backend (`face_bg`, `accent_grad`, fonts…).
  /// Kept opaque so a future full-card renderer can consume it without
  /// us hand-mapping every key.
  final Map<String, dynamic>? theme;

  @override
  List<Object?> get props => [id, name, codeName, theme];
}

class TradingCard extends Equatable {
  const TradingCard({
    required this.id,
    this.uid = '',
    this.cardType = '',
    this.isSealed = false,
    this.displayName = '',
    this.displayImageUrl = '',
    this.quote = '',
    this.accentHue = 0,
    this.design,
    this.owner,
    this.likesCount = 0,
    this.collectionsCount = 0,
    this.isLiked,
    this.isCollected,
    this.createdAt,
  });

  final int id;
  final String uid;

  /// `'modern'` | `'legacy'` — legacy cards are sealed (read-only).
  final String cardType;
  final bool isSealed;

  /// Player name shown on the card face (often different from the
  /// owner's profile name).
  final String displayName;

  /// Front photo URL — used as the tile thumbnail.
  final String displayImageUrl;

  /// Optional flavour quote.
  final String quote;

  /// Hue (0–360) the card's accent gradient is built from.
  final int accentHue;

  final CardDesign? design;
  final TradingCardOwner? owner;
  final int likesCount;
  final int collectionsCount;
  final bool? isLiked;
  final bool? isCollected;
  final DateTime? createdAt;

  TradingCard withLike({required bool isLiked, required int likesCount}) =>
      TradingCard(
        id: id,
        uid: uid,
        cardType: cardType,
        isSealed: isSealed,
        displayName: displayName,
        displayImageUrl: displayImageUrl,
        quote: quote,
        accentHue: accentHue,
        design: design,
        owner: owner,
        likesCount: likesCount,
        collectionsCount: collectionsCount,
        isLiked: isLiked,
        isCollected: isCollected,
        createdAt: createdAt,
      );

  TradingCard withCollect({
    required bool isCollected,
    required int collectionsCount,
  }) =>
      TradingCard(
        id: id,
        uid: uid,
        cardType: cardType,
        isSealed: isSealed,
        displayName: displayName,
        displayImageUrl: displayImageUrl,
        quote: quote,
        accentHue: accentHue,
        design: design,
        owner: owner,
        likesCount: likesCount,
        collectionsCount: collectionsCount,
        isLiked: isLiked,
        isCollected: isCollected,
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [
        id,
        uid,
        cardType,
        isSealed,
        displayName,
        displayImageUrl,
        quote,
        accentHue,
        design,
        owner,
        likesCount,
        collectionsCount,
        isLiked,
        isCollected,
        createdAt,
      ];
}

/// Result of a like-toggle call. Backend hands us the authoritative
/// `is_liked` + new `likes_count`.
class CardLikeResult {
  const CardLikeResult({required this.isLiked, required this.likesCount});
  final bool isLiked;
  final int likesCount;
}

class CardCollectResult {
  const CardCollectResult({
    required this.isCollected,
    required this.collectionsCount,
  });
  final bool isCollected;
  final int collectionsCount;
}

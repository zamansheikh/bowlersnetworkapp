import 'package:json_annotation/json_annotation.dart';

part 'card_dtos.g.dart';

/// Slim card owner. Trading cards always belong to one user, so this
/// nests inside every card payload.
@JsonSerializable(createToJson: false)
class CardOwnerDto {
  const CardOwnerDto({
    this.id = 0,
    this.username = '',
    this.firstName = '',
    this.lastName = '',
    this.profilePictureUrl,
    this.isPro = false,
    this.level,
    this.rankDisplay,
    this.badgeIconUrl,
  });

  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String username;
  @JsonKey(name: 'first_name', defaultValue: '')
  final String firstName;
  @JsonKey(name: 'last_name', defaultValue: '')
  final String lastName;
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'is_pro', defaultValue: false)
  final bool isPro;
  final int? level;
  @JsonKey(name: 'rank_display')
  final String? rankDisplay;
  @JsonKey(name: 'badge_icon_url')
  final String? badgeIconUrl;

  factory CardOwnerDto.fromJson(Map<String, dynamic> json) =>
      _$CardOwnerDtoFromJson(json);
}

/// Design metadata for a card — includes the raw `theme` blob that the
/// flippable TradingCard widget needs to recolour itself (kept as a raw
/// Map so we don't have to mirror every theme key).
@JsonSerializable(createToJson: false)
class CardDesignDto {
  const CardDesignDto({
    this.id = 0,
    this.name = '',
    this.codeName = '',
    this.theme,
  });
  @JsonKey(defaultValue: 0)
  final int id;
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(name: 'code_name', defaultValue: '')
  final String codeName;
  final Map<String, dynamic>? theme;
  factory CardDesignDto.fromJson(Map<String, dynamic> json) =>
      _$CardDesignDtoFromJson(json);
}

/// Inner card object — what lives under `cards[i].card` in the response.
/// This is the shape the backend's `Card.data()` returns; viewer flags
/// (`is_liked`, `is_collected`) sit on this object, not the envelope.
@JsonSerializable(createToJson: false)
class CardInnerDto {
  const CardInnerDto({
    required this.cardId,
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
    this.isLiked = false,
    this.isCollected = false,
    this.createdAtIso,
  });

  @JsonKey(name: 'card_id')
  final int cardId;
  @JsonKey(defaultValue: '')
  final String uid;
  @JsonKey(name: 'card_type', defaultValue: '')
  final String cardType;
  @JsonKey(name: 'is_sealed', defaultValue: false)
  final bool isSealed;
  @JsonKey(name: 'display_name', defaultValue: '')
  final String displayName;
  @JsonKey(name: 'display_image_url', defaultValue: '')
  final String displayImageUrl;
  @JsonKey(defaultValue: '')
  final String quote;
  @JsonKey(name: 'accent_hue', defaultValue: 0)
  final int accentHue;
  final CardDesignDto? design;
  final CardOwnerDto? owner;
  @JsonKey(name: 'likes_count', defaultValue: 0)
  final int likesCount;
  @JsonKey(name: 'collections_count', defaultValue: 0)
  final int collectionsCount;
  @JsonKey(name: 'is_liked', defaultValue: false)
  final bool isLiked;
  @JsonKey(name: 'is_collected', defaultValue: false)
  final bool isCollected;
  @JsonKey(name: 'created_at_iso')
  final String? createdAtIso;

  factory CardInnerDto.fromJson(Map<String, dynamic> json) =>
      _$CardInnerDtoFromJson(json);
}

/// Envelope shape `{card, info, brands}` that the list endpoint wraps
/// around every card. `info` and `brands` are only present when the
/// caller specifically asked for the full card payload — for the
/// profile-screen list they're often missing or thin.
@JsonSerializable(createToJson: false)
class CardEnvelopeDto {
  const CardEnvelopeDto({required this.card});
  final CardInnerDto card;
  factory CardEnvelopeDto.fromJson(Map<String, dynamic> json) =>
      _$CardEnvelopeDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class CardsPageDto {
  const CardsPageDto({
    this.cards = const [],
    this.page = 1,
    this.pageSize = 20,
  });

  final List<CardEnvelopeDto> cards;
  @JsonKey(defaultValue: 1)
  final int page;
  @JsonKey(name: 'page_size', defaultValue: 20)
  final int pageSize;

  factory CardsPageDto.fromJson(Map<String, dynamic> json) =>
      _$CardsPageDtoFromJson(json);
}

/// Authoritative `{is_liked, likes_count}` returned by the like-toggle
/// endpoint.
@JsonSerializable(createToJson: false)
class CardLikeToggleDto {
  const CardLikeToggleDto({this.isLiked = false, this.likesCount = 0});
  @JsonKey(name: 'is_liked', defaultValue: false)
  final bool isLiked;
  @JsonKey(name: 'likes_count', defaultValue: 0)
  final int likesCount;
  factory CardLikeToggleDto.fromJson(Map<String, dynamic> json) =>
      _$CardLikeToggleDtoFromJson(json);
}

/// Authoritative `{is_collected, collections_count}` returned by the
/// collect-toggle endpoint.
@JsonSerializable(createToJson: false)
class CardCollectToggleDto {
  const CardCollectToggleDto({
    this.isCollected = false,
    this.collectionsCount = 0,
  });
  @JsonKey(name: 'is_collected', defaultValue: false)
  final bool isCollected;
  @JsonKey(name: 'collections_count', defaultValue: 0)
  final int collectionsCount;
  factory CardCollectToggleDto.fromJson(Map<String, dynamic> json) =>
      _$CardCollectToggleDtoFromJson(json);
}

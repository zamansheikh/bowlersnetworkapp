// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardOwnerDto _$CardOwnerDtoFromJson(Map<String, dynamic> json) => CardOwnerDto(
  id: (json['id'] as num?)?.toInt() ?? 0,
  username: json['username'] as String? ?? '',
  firstName: json['first_name'] as String? ?? '',
  lastName: json['last_name'] as String? ?? '',
  profilePictureUrl: json['profile_picture_url'] as String?,
  isPro: json['is_pro'] as bool? ?? false,
  level: (json['level'] as num?)?.toInt(),
  rankDisplay: json['rank_display'] as String?,
  badgeIconUrl: json['badge_icon_url'] as String?,
);

CardDesignDto _$CardDesignDtoFromJson(Map<String, dynamic> json) =>
    CardDesignDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      codeName: json['code_name'] as String? ?? '',
      theme: json['theme'] as Map<String, dynamic>?,
    );

CardInnerDto _$CardInnerDtoFromJson(Map<String, dynamic> json) => CardInnerDto(
  cardId: (json['card_id'] as num).toInt(),
  uid: json['uid'] as String? ?? '',
  cardType: json['card_type'] as String? ?? '',
  isSealed: json['is_sealed'] as bool? ?? false,
  displayName: json['display_name'] as String? ?? '',
  displayImageUrl: json['display_image_url'] as String? ?? '',
  quote: json['quote'] as String? ?? '',
  accentHue: (json['accent_hue'] as num?)?.toInt() ?? 0,
  design: json['design'] == null
      ? null
      : CardDesignDto.fromJson(json['design'] as Map<String, dynamic>),
  owner: json['owner'] == null
      ? null
      : CardOwnerDto.fromJson(json['owner'] as Map<String, dynamic>),
  likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
  collectionsCount: (json['collections_count'] as num?)?.toInt() ?? 0,
  isLiked: json['is_liked'] as bool? ?? false,
  isCollected: json['is_collected'] as bool? ?? false,
  createdAtIso: json['created_at_iso'] as String?,
);

CardsPageDto _$CardsPageDtoFromJson(Map<String, dynamic> json) => CardsPageDto(
  cards:
      (json['cards'] as List<dynamic>?)
          ?.map((e) => CardEnvelopeDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  page: (json['page'] as num?)?.toInt() ?? 1,
  pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
);

CardLikeToggleDto _$CardLikeToggleDtoFromJson(Map<String, dynamic> json) =>
    CardLikeToggleDto(
      isLiked: json['is_liked'] as bool? ?? false,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
    );

CardCollectToggleDto _$CardCollectToggleDtoFromJson(
  Map<String, dynamic> json,
) => CardCollectToggleDto(
  isCollected: json['is_collected'] as bool? ?? false,
  collectionsCount: (json['collections_count'] as num?)?.toInt() ?? 0,
);

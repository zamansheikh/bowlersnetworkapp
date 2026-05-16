// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandDto _$BrandDtoFromJson(Map<String, dynamic> json) => BrandDto(
  brandId: (json['brand_id'] as num).toInt(),
  name: json['name'] as String,
  brandType: json['brand_type'] as String,
  logoUrl: json['logo_url'] as String,
  formalName: json['formal_name'] as String?,
  brandTypeId: (json['brand_type_id'] as num?)?.toInt(),
  isFavorite: json['is_favorite'] as bool? ?? false,
);

BrandFavoriteToggleDto _$BrandFavoriteToggleDtoFromJson(
  Map<String, dynamic> json,
) => BrandFavoriteToggleDto(isFavorite: json['is_favorite'] as bool? ?? false);

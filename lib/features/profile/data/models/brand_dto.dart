import 'package:json_annotation/json_annotation.dart';

part 'brand_dto.g.dart';

/// One row from GET /api/brands. We only care about basic display fields
/// for the profile's favorite-brands card.
@JsonSerializable(createToJson: false)
class BrandDto {
  const BrandDto({
    required this.brandId,
    required this.name,
    required this.brandType,
    required this.logoUrl,
    this.formalName,
    this.brandTypeId,
    this.isFavorite = false,
  });

  @JsonKey(name: 'brand_id')
  final int brandId;

  final String name;

  @JsonKey(name: 'brand_type')
  final String brandType;

  @JsonKey(name: 'brand_type_id')
  final int? brandTypeId;

  @JsonKey(name: 'formal_name')
  final String? formalName;

  @JsonKey(name: 'logo_url')
  final String logoUrl;

  @JsonKey(name: 'is_favorite', defaultValue: false)
  final bool isFavorite;

  factory BrandDto.fromJson(Map<String, dynamic> json) =>
      _$BrandDtoFromJson(json);
}

/// Response of POST /api/brands/{id}/favorite — backend echoes the
/// authoritative new boolean so the bloc doesn't have to assume.
@JsonSerializable(createToJson: false)
class BrandFavoriteToggleDto {
  const BrandFavoriteToggleDto({this.isFavorite = false});
  @JsonKey(name: 'is_favorite', defaultValue: false)
  final bool isFavorite;

  factory BrandFavoriteToggleDto.fromJson(Map<String, dynamic> json) =>
      _$BrandFavoriteToggleDtoFromJson(json);
}

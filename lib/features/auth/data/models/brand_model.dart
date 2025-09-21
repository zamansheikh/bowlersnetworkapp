import '../../domain/entities/brand.dart';

class BrandModel extends Brand {
  const BrandModel({
    required super.brandId,
    required super.brandType,
    required super.name,
    required super.formalName,
    required super.logoUrl,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      brandId: json['brand_id'] as int,
      brandType: json['brandType'] as String,
      name: json['name'] as String,
      formalName: json['formal_name'] as String,
      logoUrl: json['logo_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_id': brandId,
      'brandType': brandType,
      'name': name,
      'formal_name': formalName,
      'logo_url': logoUrl,
    };
  }
}

class BrandResponseModel extends BrandResponse {
  const BrandResponseModel({
    required super.shoes,
    required super.apparels,
    required super.balls,
    required super.accessories,
    required super.businessSponsors,
  });

  factory BrandResponseModel.fromJson(Map<String, dynamic> json) {
    List<BrandModel> parseBrands(List<dynamic>? brandList) {
      if (brandList == null) return [];
      return brandList
          .map((brand) => BrandModel.fromJson(brand as Map<String, dynamic>))
          .toList();
    }

    return BrandResponseModel(
      shoes: parseBrands(json['Shoes'] as List<dynamic>?),
      apparels: parseBrands(json['Apparels'] as List<dynamic>?),
      balls: parseBrands(json['Balls'] as List<dynamic>?),
      accessories: parseBrands(json['Accessories'] as List<dynamic>?),
      businessSponsors: parseBrands(json['Business Sponsors'] as List<dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Shoes': shoes.map((brand) => (brand as BrandModel).toJson()).toList(),
      'Apparels': apparels.map((brand) => (brand as BrandModel).toJson()).toList(),
      'Balls': balls.map((brand) => (brand as BrandModel).toJson()).toList(),
      'Accessories': accessories.map((brand) => (brand as BrandModel).toJson()).toList(),
      'Business Sponsors': businessSponsors.map((brand) => (brand as BrandModel).toJson()).toList(),
    };
  }
}
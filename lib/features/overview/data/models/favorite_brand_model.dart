class FavoriteBrandModel {
  final int brandId;
  final String brandType;
  final String name;
  final String formalName;
  final String logoUrl;

  FavoriteBrandModel({
    required this.brandId,
    required this.brandType,
    required this.name,
    required this.formalName,
    required this.logoUrl,
  });

  factory FavoriteBrandModel.fromJson(Map<String, dynamic> json) {
    return FavoriteBrandModel(
      brandId: json['brand_id'] ?? 0,
      brandType: json['brandType'] ?? '',
      name: json['name'] ?? '',
      formalName: json['formal_name'] ?? '',
      logoUrl: json['logo_url'] ?? '',
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

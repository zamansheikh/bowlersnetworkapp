import 'package:equatable/equatable.dart';

class Brand extends Equatable {
  final int brandId;
  final String brandType;
  final String name;
  final String formalName;
  final String logoUrl;

  const Brand({
    required this.brandId,
    required this.brandType,
    required this.name,
    required this.formalName,
    required this.logoUrl,
  });

  @override
  List<Object?> get props => [brandId, brandType, name, formalName, logoUrl];
}

class BrandResponse extends Equatable {
  final List<Brand> shoes;
  final List<Brand> apparels;
  final List<Brand> balls;
  final List<Brand> accessories;
  final List<Brand> businessSponsors;

  const BrandResponse({
    required this.shoes,
    required this.apparels,
    required this.balls,
    required this.accessories,
    required this.businessSponsors,
  });

  List<Brand> get allBrands => [
        ...shoes,
        ...apparels,
        ...balls,
        ...accessories,
        ...businessSponsors,
      ];

  Map<String, List<Brand>> get brandsByCategory => {
        'Shoes': shoes,
        'Apparels': apparels,
        'Balls': balls,
        'Accessories': accessories,
        'Business Sponsors': businessSponsors,
      };

  @override
  List<Object?> get props => [shoes, apparels, balls, accessories, businessSponsors];
}
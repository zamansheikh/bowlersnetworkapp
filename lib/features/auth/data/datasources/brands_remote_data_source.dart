import '../models/brand_model.dart';

abstract class BrandsRemoteDataSource {
  Future<BrandResponseModel> getBrands();
  Future<void> updateFavoriteBrands(List<int> brandIds);
}
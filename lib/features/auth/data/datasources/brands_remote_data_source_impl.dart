import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';
import '../models/brand_model.dart';
import 'brands_remote_data_source.dart';

@LazySingleton(as: BrandsRemoteDataSource)
class BrandsRemoteDataSourceImpl implements BrandsRemoteDataSource {
  late final Dio _dio;
  final SharedPreferences _prefs;

  BrandsRemoteDataSourceImpl(this._prefs) {
    _configureDio();
  }

  void _configureDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          print('🏷️ Brands API Error: ${error.message}');
          print('🏷️ Brands API Error Response: ${error.response?.data}');
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[Brands API] $object'),
      ),
    );
  }

  String? _getAuthToken() {
    final token = _prefs.getString(AppConstants.tokenKey);
    print(
      '🏷️ Auth token retrieved: ${token != null ? 'Token exists (${token.length} chars)' : 'No token found'}',
    );
    return token;
  }

  @override
  Future<BrandResponseModel> getBrands() async {
    try {
      print('🏷️ BrandsDataSource: Fetching brands from /api/brands');
      
      final response = await _dio.get('/api/brands');
      
      print('🏷️ BrandsDataSource: Response status: ${response.statusCode}');
      print('🏷️ BrandsDataSource: Response data: ${response.data}');

      if (response.statusCode == 200) {
        return BrandResponseModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load brands: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏷️ BrandsDataSource: Dio error: ${e.message}');
      if (e.response != null) {
        print('🏷️ BrandsDataSource: Error response: ${e.response?.data}');
        throw Exception('Failed to load brands: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('🏷️ BrandsDataSource: Unexpected error: $e');
      throw Exception('Failed to load brands: $e');
    }
  }

  @override
  Future<void> updateFavoriteBrands(List<int> brandIds) async {
    try {
      print('🏷️ BrandsDataSource: Updating favorite brands: $brandIds');
      
      final response = await _dio.patch(
        '/api/user/brands/favorites',
        data: {
          'brandIDs': brandIds,
        },
      );
      
      print('🏷️ BrandsDataSource: Update response: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update favorite brands: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('🏷️ BrandsDataSource: Update error: ${e.message}');
      if (e.response != null) {
        throw Exception('Update failed: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
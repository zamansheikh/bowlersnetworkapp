import 'package:injectable/injectable.dart';
import '../datasources/overview_remote_data_source.dart';
import '../models/dashboard_data_model.dart';
import '../models/favorite_brand_model.dart';
import '../models/message_model.dart';
import '../models/performance_data_model.dart';

abstract class OverviewRepository {
  Future<DashboardDataModel> getDashboardData();
  Future<List<FavoriteBrandModel>> getFavoriteBrands();
  Future<List<MessageModel>> getMessages();
  Future<List<PerformanceDataModel>> getPerformanceData(String range);
}

@LazySingleton(as: OverviewRepository)
class OverviewRepositoryImpl implements OverviewRepository {
  final OverviewRemoteDataSource _remoteDataSource;

  OverviewRepositoryImpl(this._remoteDataSource);

  @override
  Future<DashboardDataModel> getDashboardData() async {
    try {
      return await _remoteDataSource.getDashboardData();
    } catch (e) {
      throw Exception('Failed to get dashboard data: $e');
    }
  }

  @override
  Future<List<FavoriteBrandModel>> getFavoriteBrands() async {
    try {
      return await _remoteDataSource.getFavoriteBrands();
    } catch (e) {
      throw Exception('Failed to get favorite brands: $e');
    }
  }

  @override
  Future<List<MessageModel>> getMessages() async {
    try {
      return await _remoteDataSource.getMessages();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  @override
  Future<List<PerformanceDataModel>> getPerformanceData(String range) async {
    try {
      return await _remoteDataSource.getPerformanceData(range);
    } catch (e) {
      throw Exception('Failed to get performance data: $e');
    }
  }
}

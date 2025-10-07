import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';
import '../models/dashboard_data_model.dart';
import '../models/favorite_brand_model.dart';
import '../models/message_model.dart';
import '../models/performance_data_model.dart';

abstract class OverviewRemoteDataSource {
  Future<DashboardDataModel> getDashboardData();
  Future<List<FavoriteBrandModel>> getFavoriteBrands();
  Future<List<MessageModel>> getMessages();
  Future<List<PerformanceDataModel>> getPerformanceData(String range);
}

@LazySingleton(as: OverviewRemoteDataSource)
class OverviewRemoteDataSourceImpl implements OverviewRemoteDataSource {
  late final Dio _dio;
  final SharedPreferences _prefs;

  OverviewRemoteDataSourceImpl(this._prefs) {
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

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add token if available
          final token = _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Handle unauthorized access
            _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );
  }

  String? _getAuthToken() {
    return _prefs.getString(AppConstants.tokenKey);
  }

  void _handleUnauthorized() {
    // Clear stored token and redirect to login
    _prefs.remove(AppConstants.tokenKey);
    _prefs.remove(AppConstants.userKey);
  }

  @override
  Future<DashboardDataModel> getDashboardData() async {
    try {
      final response = await _dio.get('/api/user/pro-dashboard-data');

      if (response.statusCode == 200 && response.data != null) {
        return DashboardDataModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      // Return mock data if API doesn't exist or fails
      debugPrint('Dashboard API failed, using mock data: $e');
      return DashboardDataModel(
        userId: 1,
        likes: 128,
        comments: 45,
        shares: 32,
        views: 890,
        followerCount: 245,
        onboardedUserCount: 1000,
        freeUsers: 800,
        premiumUserCount: 200,
        conversionRate: 20.0,
        weightedIndex: 85.0,
      );
    }
  }

  @override
  Future<List<FavoriteBrandModel>> getFavoriteBrands() async {
    try {
      final response = await _dio.get('/api/user/favorite-brands');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((item) => FavoriteBrandModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load favorite brands');
      }
    } catch (e) {
      // Return mock data if API doesn't exist or fails
      debugPrint('Favorite brands API failed, using mock data: $e');
      return [
        FavoriteBrandModel(
          brandId: 1,
          brandType: 'Ball',
          name: 'Storm',
          formalName: 'Storm Bowling',
          logoUrl: 'https://via.placeholder.com/48x48?text=Storm',
        ),
        FavoriteBrandModel(
          brandId: 2,
          brandType: 'Ball',
          name: 'Brunswick',
          formalName: 'Brunswick Bowling',
          logoUrl: 'https://via.placeholder.com/48x48?text=Brunswick',
        ),
        FavoriteBrandModel(
          brandId: 3,
          brandType: 'Shoes',
          name: 'Dexter',
          formalName: 'Dexter Shoes',
          logoUrl: 'https://via.placeholder.com/48x48?text=Dexter',
        ),
      ];
    }
  }

  @override
  Future<List<MessageModel>> getMessages() async {
    try {
      final response = await _dio.get('/api/user/messages');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((item) => MessageModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      // Return mock data for now if API doesn't exist
      return [
        MessageModel(
          id: '1',
          from: 'Downtown Lanes',
          content: 'New tournament announced! Register by Friday.',
          timestamp: '1 day ago',
          read: false,
        ),
        MessageModel(
          id: '2',
          from: 'Bowling Center',
          content: 'Your league registration is confirmed.',
          timestamp: '2 days ago',
          read: true,
        ),
      ];
    }
  }

  @override
  Future<List<PerformanceDataModel>> getPerformanceData(String range) async {
    try {
      final response = await _dio.get(
        '/api/user/performance-data?range=$range',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((item) => PerformanceDataModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load performance data');
      }
    } catch (e) {
      // Return mock data for now
      return _getMockPerformanceData(range);
    }
  }

  List<PerformanceDataModel> _getMockPerformanceData(String range) {
    if (range == 'weekly') {
      return List.generate(
        7,
        (i) => PerformanceDataModel(
          label: 'Day ${i + 1}',
          score: 180 + (i * 5) + (i % 3 * 10),
          date: '2025-06-${10 + i}',
        ),
      );
    } else if (range == 'yearly') {
      return [
        PerformanceDataModel(label: '2020', score: 160, date: '2020'),
        PerformanceDataModel(label: '2021', score: 178, date: '2021'),
        PerformanceDataModel(label: '2022', score: 190, date: '2022'),
        PerformanceDataModel(label: '2023', score: 200, date: '2023'),
        PerformanceDataModel(label: '2024', score: 215, date: '2024'),
        PerformanceDataModel(label: '2025', score: 225, date: '2025'),
      ];
    } else {
      // monthly
      return [
        PerformanceDataModel(label: 'Jan', score: 205, date: '2025-01'),
        PerformanceDataModel(label: 'Feb', score: 198, date: '2025-02'),
        PerformanceDataModel(label: 'Mar', score: 215, date: '2025-03'),
        PerformanceDataModel(label: 'Apr', score: 187, date: '2025-04'),
        PerformanceDataModel(label: 'May', score: 195, date: '2025-05'),
        PerformanceDataModel(label: 'Jun', score: 210, date: '2025-06'),
      ];
    }
  }
}

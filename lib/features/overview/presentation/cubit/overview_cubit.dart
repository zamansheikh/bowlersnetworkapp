import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/repositories/overview_repository_impl.dart';
import '../../data/models/dashboard_data_model.dart';
import '../../data/models/favorite_brand_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/performance_data_model.dart';
import 'overview_state.dart';

@injectable
class OverviewCubit extends Cubit<OverviewState> {
  final OverviewRepository _repository;

  OverviewCubit(this._repository) : super(OverviewInitial());

  Future<void> loadOverviewData() async {
    emit(OverviewLoading());

    try {
      // Try to get dashboard data from API, but use fallback on failure
      DashboardDataModel? dashboardData;
      try {
        dashboardData = await _repository.getDashboardData();
      } catch (e) {
        debugPrint('Dashboard API failed, will use mock data: $e');
        dashboardData = null;
      }

      // Load other data concurrently
      final results = await Future.wait([
        _repository.getFavoriteBrands(),
        _repository.getMessages(),
        _repository.getPerformanceData('monthly'),
      ]);

      emit(
        OverviewLoaded(
          dashboardData: dashboardData,
          favoriteBrands: results[0] as List<FavoriteBrandModel>,
          messages: results[1] as List<MessageModel>,
          performanceData: results[2] as List<PerformanceDataModel>,
          performanceRange: 'monthly',
        ),
      );
    } catch (e) {
      emit(OverviewError('Failed to load overview data: ${e.toString()}'));
    }
  }

  Future<void> changePerformanceRange(String range) async {
    final currentState = state;
    if (currentState is OverviewLoaded) {
      emit(
        OverviewPerformanceLoading(
          dashboardData: currentState.dashboardData,
          favoriteBrands: currentState.favoriteBrands,
          messages: currentState.messages,
          performanceData: currentState.performanceData,
          performanceRange: range,
        ),
      );

      try {
        final performanceData = await _repository.getPerformanceData(range);

        emit(
          currentState.copyWith(
            performanceData: performanceData,
            performanceRange: range,
          ),
        );
      } catch (e) {
        emit(OverviewError('Failed to load performance data: ${e.toString()}'));
      }
    }
  }

  Future<void> refreshData() async {
    await loadOverviewData();
  }
}

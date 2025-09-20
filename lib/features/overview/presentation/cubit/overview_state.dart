import 'package:equatable/equatable.dart';
import '../../data/models/dashboard_data_model.dart';
import '../../data/models/favorite_brand_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/performance_data_model.dart';

abstract class OverviewState extends Equatable {
  const OverviewState();

  @override
  List<Object?> get props => [];
}

class OverviewInitial extends OverviewState {}

class OverviewLoading extends OverviewState {}

class OverviewLoaded extends OverviewState {
  final DashboardDataModel? dashboardData;
  final List<FavoriteBrandModel> favoriteBrands;
  final List<MessageModel> messages;
  final List<PerformanceDataModel> performanceData;
  final String performanceRange;

  const OverviewLoaded({
    this.dashboardData,
    this.favoriteBrands = const [],
    this.messages = const [],
    this.performanceData = const [],
    this.performanceRange = 'monthly',
  });

  OverviewLoaded copyWith({
    DashboardDataModel? dashboardData,
    List<FavoriteBrandModel>? favoriteBrands,
    List<MessageModel>? messages,
    List<PerformanceDataModel>? performanceData,
    String? performanceRange,
  }) {
    return OverviewLoaded(
      dashboardData: dashboardData ?? this.dashboardData,
      favoriteBrands: favoriteBrands ?? this.favoriteBrands,
      messages: messages ?? this.messages,
      performanceData: performanceData ?? this.performanceData,
      performanceRange: performanceRange ?? this.performanceRange,
    );
  }

  @override
  List<Object?> get props => [
    dashboardData,
    favoriteBrands,
    messages,
    performanceData,
    performanceRange,
  ];
}

class OverviewError extends OverviewState {
  final String message;

  const OverviewError(this.message);

  @override
  List<Object> get props => [message];
}

class OverviewPerformanceLoading extends OverviewState {
  final DashboardDataModel? dashboardData;
  final List<FavoriteBrandModel> favoriteBrands;
  final List<MessageModel> messages;
  final List<PerformanceDataModel> performanceData;
  final String performanceRange;

  const OverviewPerformanceLoading({
    this.dashboardData,
    this.favoriteBrands = const [],
    this.messages = const [],
    this.performanceData = const [],
    this.performanceRange = 'monthly',
  });

  @override
  List<Object?> get props => [
    dashboardData,
    favoriteBrands,
    messages,
    performanceData,
    performanceRange,
  ];
}

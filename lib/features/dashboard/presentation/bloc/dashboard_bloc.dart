import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/alpha_score.dart';
import '../../domain/entities/dashboard_range.dart';
import '../../domain/entities/engagement_insights.dart';
import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// Owns the whole /dashboard screen: which tab is active, the time
/// range, and one slot per tab. Tabs load lazily on first activation
/// (or when the range changes while they're active). Pro tabs are
/// loaded only if [DashboardLoadRequested.isPro] was true.
///
/// Sub-tab data scopes (XP, Games, Pro tabs) ship in later batches —
/// the state already has slots for them but they're unused for now.
@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._repository) : super(const DashboardState()) {
    on<DashboardInitRequested>(_onInit);
    on<DashboardTabChanged>(_onTabChanged);
    on<DashboardRangeChanged>(_onRangeChanged);
    on<DashboardRefreshRequested>(_onRefresh);
    on<DashboardEngagementLoadRequested>(_onLoadEngagement);
  }

  final DashboardRepository _repository;

  void _onInit(DashboardInitRequested event, Emitter<DashboardState> emit) {
    emit(state.copyWith(isPro: event.isPro));
    // Auto-load the engagement tab on first open.
    add(const DashboardEngagementLoadRequested());
  }

  void _onTabChanged(
    DashboardTabChanged event,
    Emitter<DashboardState> emit,
  ) {
    if (event.tab == state.activeTab) return;
    emit(state.copyWith(activeTab: event.tab));
    _ensureLoaded(event.tab);
  }

  void _onRangeChanged(
    DashboardRangeChanged event,
    Emitter<DashboardState> emit,
  ) {
    if (event.range == state.range) return;
    // Clear the active tab's data so the user sees the loader — stale
    // data with the wrong range is more confusing than a brief skeleton.
    final next = state.copyWith(range: event.range);
    emit(_invalidateActive(next));
    _ensureLoaded(state.activeTab);
  }

  Future<void> _onRefresh(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    switch (state.activeTab) {
      case DashboardTab.engagement:
        await _fetchEngagement(emit, isRefresh: true);
      case DashboardTab.xp:
      case DashboardTab.games:
      case DashboardTab.content:
      case DashboardTab.audience:
      case DashboardTab.referrals:
      case DashboardTab.weightedIndex:
        // Wired up in batches 2 + 3.
        break;
    }
  }

  Future<void> _onLoadEngagement(
    DashboardEngagementLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.engagement.loaded && !event.force) return;
    await _fetchEngagement(emit, isRefresh: false);
  }

  Future<void> _fetchEngagement(
    Emitter<DashboardState> emit, {
    required bool isRefresh,
  }) async {
    emit(state.copyWith(
      engagement: state.engagement.copyWith(
        loading: !isRefresh,
        refreshing: isRefresh,
        errors: const [],
      ),
    ));

    final results = await Future.wait([
      _repository.getEngagementInsights(range: state.range),
      _repository.getAlphaScore(range: state.range),
    ]);
    final insightsRes = results[0];
    final alphaRes = results[1];

    final errors = <String>[];
    EngagementInsights? insights = state.engagement.insights;
    AlphaScore? alpha = state.engagement.alpha;

    insightsRes.fold(
      (f) => errors.addAll(f.messages.isEmpty
          ? const ['Failed to load engagement insights.']
          : f.messages),
      (data) => insights = data as EngagementInsights,
    );
    alphaRes.fold(
      // Alpha is auxiliary — don't surface its error as a toast, just
      // skip the card.
      (_) {},
      (data) => alpha = data as AlphaScore,
    );

    emit(state.copyWith(
      engagement: state.engagement.copyWith(
        loading: false,
        refreshing: false,
        loaded: true,
        insights: insights,
        alpha: alpha,
        errors: errors,
      ),
    ));
  }

  void _ensureLoaded(DashboardTab tab) {
    switch (tab) {
      case DashboardTab.engagement:
        if (!state.engagement.loaded) {
          add(const DashboardEngagementLoadRequested());
        }
      case DashboardTab.xp:
      case DashboardTab.games:
      case DashboardTab.content:
      case DashboardTab.audience:
      case DashboardTab.referrals:
      case DashboardTab.weightedIndex:
        // Wired up in batches 2 + 3.
        break;
    }
  }

  DashboardState _invalidateActive(DashboardState s) {
    switch (s.activeTab) {
      case DashboardTab.engagement:
        return s.copyWith(
          engagement: const DashboardEngagementSlot(),
        );
      case DashboardTab.xp:
      case DashboardTab.games:
      case DashboardTab.content:
      case DashboardTab.audience:
      case DashboardTab.referrals:
      case DashboardTab.weightedIndex:
        return s;
    }
  }
}

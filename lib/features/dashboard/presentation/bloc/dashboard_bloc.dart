import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/alpha_score.dart';
import '../../domain/entities/dashboard_range.dart';
import '../../domain/entities/engagement_insights.dart';
import '../../domain/entities/games_insights.dart';
import '../../domain/entities/pro_audience.dart';
import '../../domain/entities/pro_content.dart';
import '../../domain/entities/pro_contribution.dart';
import '../../domain/entities/pro_referrals.dart';
import '../../domain/entities/xp_insights.dart';
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
    on<DashboardXpLoadRequested>(_onLoadXp);
    on<DashboardGamesLoadRequested>(_onLoadGames);
    on<DashboardProContentLoadRequested>(_onLoadProContent);
    on<DashboardProAudienceLoadRequested>(_onLoadProAudience);
    on<DashboardProReferralsLoadRequested>(_onLoadProReferrals);
    on<DashboardProContributionLoadRequested>(_onLoadProContribution);
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
        await _fetchXp(emit, isRefresh: true);
      case DashboardTab.games:
        await _fetchGames(emit, isRefresh: true);
      case DashboardTab.content:
        await _fetchProContent(emit, isRefresh: true);
      case DashboardTab.audience:
        await _fetchProAudience(emit, isRefresh: true);
      case DashboardTab.referrals:
        await _fetchProReferrals(emit, isRefresh: true);
      case DashboardTab.weightedIndex:
        await _fetchProContribution(emit, isRefresh: true);
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

  Future<void> _onLoadXp(
    DashboardXpLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.xp.loaded && !event.force) return;
    await _fetchXp(emit, isRefresh: false);
  }

  Future<void> _fetchXp(
    Emitter<DashboardState> emit, {
    required bool isRefresh,
  }) async {
    emit(state.copyWith(
      xp: state.xp.copyWith(
        loading: !isRefresh,
        refreshing: isRefresh,
        errors: const [],
      ),
    ));
    final res = await _repository.getXpInsights(range: state.range);
    res.fold(
      (f) => emit(state.copyWith(
        xp: state.xp.copyWith(
          loading: false,
          refreshing: false,
          errors: f.messages.isEmpty
              ? const ['Failed to load XP insights.']
              : f.messages,
        ),
      )),
      (data) => emit(state.copyWith(
        xp: state.xp.copyWith(
          loading: false,
          refreshing: false,
          loaded: true,
          insights: data,
          errors: const [],
        ),
      )),
    );
  }

  Future<void> _onLoadGames(
    DashboardGamesLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (state.games.loaded && !event.force) return;
    await _fetchGames(emit, isRefresh: false);
  }

  Future<void> _fetchGames(
    Emitter<DashboardState> emit, {
    required bool isRefresh,
  }) async {
    emit(state.copyWith(
      games: state.games.copyWith(
        loading: !isRefresh,
        refreshing: isRefresh,
        errors: const [],
      ),
    ));
    final results = await Future.wait([
      _repository.getGamesReport(),
      _repository.getGamesTrends(range: state.range),
    ]);
    final reportRes = results[0];
    final trendsRes = results[1];

    final errors = <String>[];
    GamesReport? report = state.games.report;
    GamesTrends? trends = state.games.trends;

    reportRes.fold(
      (f) => errors.addAll(f.messages.isEmpty
          ? const ['Failed to load games report.']
          : f.messages),
      (data) => report = data as GamesReport,
    );
    trendsRes.fold(
      (_) {
        // Trends are auxiliary — silently skip.
      },
      (data) => trends = data as GamesTrends,
    );

    emit(state.copyWith(
      games: state.games.copyWith(
        loading: false,
        refreshing: false,
        loaded: true,
        report: report,
        trends: trends,
        errors: errors,
      ),
    ));
  }

  // ── Pro tab handlers ─────────────────────────────────────────────────────

  Future<void> _onLoadProContent(
    DashboardProContentLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (!state.isPro) return;
    if (state.content.loaded && !event.force) return;
    await _fetchProContent(emit, isRefresh: false);
  }

  Future<void> _fetchProContent(
    Emitter<DashboardState> emit, {
    required bool isRefresh,
  }) async {
    if (!state.isPro) return;
    emit(state.copyWith(
      content: state.content.copyWith(
        loading: !isRefresh,
        refreshing: isRefresh,
        errors: const [],
      ),
    ));
    final res = await _repository.getProContent(
      window: state.range.proSafeFallback(),
    );
    res.fold(
      (f) => emit(state.copyWith(
        content: state.content.copyWith(
          loading: false,
          refreshing: false,
          errors: f.messages.isEmpty
              ? const ['Failed to load content insights.']
              : f.messages,
        ),
      )),
      (data) => emit(state.copyWith(
        content: state.content.copyWith(
          loading: false,
          refreshing: false,
          loaded: true,
          data: data,
          errors: const [],
        ),
      )),
    );
  }

  Future<void> _onLoadProAudience(
    DashboardProAudienceLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (!state.isPro) return;
    if (state.audience.loaded && !event.force) return;
    await _fetchProAudience(emit, isRefresh: false);
  }

  Future<void> _fetchProAudience(
    Emitter<DashboardState> emit, {
    required bool isRefresh,
  }) async {
    if (!state.isPro) return;
    emit(state.copyWith(
      audience: state.audience.copyWith(
        loading: !isRefresh,
        refreshing: isRefresh,
        errors: const [],
      ),
    ));
    final res = await _repository.getProAudience(
      window: state.range.proSafeFallback(),
    );
    res.fold(
      (f) => emit(state.copyWith(
        audience: state.audience.copyWith(
          loading: false,
          refreshing: false,
          errors: f.messages.isEmpty
              ? const ['Failed to load audience.']
              : f.messages,
        ),
      )),
      (data) => emit(state.copyWith(
        audience: state.audience.copyWith(
          loading: false,
          refreshing: false,
          loaded: true,
          data: data,
          errors: const [],
        ),
      )),
    );
  }

  Future<void> _onLoadProReferrals(
    DashboardProReferralsLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (!state.isPro) return;
    if (state.referrals.loaded && !event.force) return;
    await _fetchProReferrals(emit, isRefresh: false);
  }

  Future<void> _fetchProReferrals(
    Emitter<DashboardState> emit, {
    required bool isRefresh,
  }) async {
    if (!state.isPro) return;
    emit(state.copyWith(
      referrals: state.referrals.copyWith(
        loading: !isRefresh,
        refreshing: isRefresh,
        errors: const [],
      ),
    ));
    final res = await _repository.getProReferrals(
      window: state.range.proSafeFallback(),
    );
    res.fold(
      (f) => emit(state.copyWith(
        referrals: state.referrals.copyWith(
          loading: false,
          refreshing: false,
          errors: f.messages.isEmpty
              ? const ['Failed to load referrals.']
              : f.messages,
        ),
      )),
      (data) => emit(state.copyWith(
        referrals: state.referrals.copyWith(
          loading: false,
          refreshing: false,
          loaded: true,
          data: data,
          errors: const [],
        ),
      )),
    );
  }

  Future<void> _onLoadProContribution(
    DashboardProContributionLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    if (!state.isPro) return;
    if (state.weightedIndex.loaded && !event.force) return;
    await _fetchProContribution(emit, isRefresh: false);
  }

  Future<void> _fetchProContribution(
    Emitter<DashboardState> emit, {
    required bool isRefresh,
  }) async {
    if (!state.isPro) return;
    emit(state.copyWith(
      weightedIndex: state.weightedIndex.copyWith(
        loading: !isRefresh,
        refreshing: isRefresh,
        errors: const [],
      ),
    ));
    final res = await _repository.getProContribution(
      window: state.range.proSafeFallback(),
    );
    res.fold(
      (f) => emit(state.copyWith(
        weightedIndex: state.weightedIndex.copyWith(
          loading: false,
          refreshing: false,
          errors: f.messages.isEmpty
              ? const ['Failed to load contribution index.']
              : f.messages,
        ),
      )),
      (data) => emit(state.copyWith(
        weightedIndex: state.weightedIndex.copyWith(
          loading: false,
          refreshing: false,
          loaded: true,
          data: data,
          errors: const [],
        ),
      )),
    );
  }

  void _ensureLoaded(DashboardTab tab) {
    switch (tab) {
      case DashboardTab.engagement:
        if (!state.engagement.loaded) {
          add(const DashboardEngagementLoadRequested());
        }
      case DashboardTab.xp:
        if (!state.xp.loaded) {
          add(const DashboardXpLoadRequested());
        }
      case DashboardTab.games:
        if (!state.games.loaded) {
          add(const DashboardGamesLoadRequested());
        }
      case DashboardTab.content:
        if (!state.content.loaded) {
          add(const DashboardProContentLoadRequested());
        }
      case DashboardTab.audience:
        if (!state.audience.loaded) {
          add(const DashboardProAudienceLoadRequested());
        }
      case DashboardTab.referrals:
        if (!state.referrals.loaded) {
          add(const DashboardProReferralsLoadRequested());
        }
      case DashboardTab.weightedIndex:
        if (!state.weightedIndex.loaded) {
          add(const DashboardProContributionLoadRequested());
        }
    }
  }

  DashboardState _invalidateActive(DashboardState s) {
    switch (s.activeTab) {
      case DashboardTab.engagement:
        return s.copyWith(engagement: const DashboardEngagementSlot());
      case DashboardTab.xp:
        return s.copyWith(xp: const DashboardXpSlot());
      case DashboardTab.games:
        return s.copyWith(games: const DashboardGamesSlot());
      case DashboardTab.content:
        return s.copyWith(content: const DashboardProContentSlot());
      case DashboardTab.audience:
        return s.copyWith(audience: const DashboardProAudienceSlot());
      case DashboardTab.referrals:
        return s.copyWith(referrals: const DashboardProReferralsSlot());
      case DashboardTab.weightedIndex:
        return s.copyWith(
          weightedIndex: const DashboardProContributionSlot(),
        );
    }
  }
}

part of 'dashboard_bloc.dart';

/// All 7 tabs the dashboard can render. Engagement / xp / games are
/// available to all users; the other four are pro-gated. The bloc's
/// [DashboardState.visibleTabs] returns the subset the viewer can see.
enum DashboardTab {
  engagement('Engagement', isPro: false),
  xp('XP', isPro: false),
  games('Games', isPro: false),
  content('Content', isPro: true),
  audience('Audience', isPro: true),
  referrals('Referrals', isPro: true),
  weightedIndex('Index', isPro: true);

  const DashboardTab(this.label, {required this.isPro});
  final String label;
  final bool isPro;
}

class DashboardState extends Equatable {
  const DashboardState({
    this.isPro = false,
    this.activeTab = DashboardTab.engagement,
    this.range = DashboardRange.d7,
    this.engagement = const DashboardEngagementSlot(),
  });

  /// True if the viewer can see + load pro tabs. Set once on init from
  /// the cached Profile in [ProfileBloc].
  final bool isPro;
  final DashboardTab activeTab;
  final DashboardRange range;
  final DashboardEngagementSlot engagement;

  /// Tabs visible to the current viewer. Used by the screen's tab bar.
  List<DashboardTab> get visibleTabs => DashboardTab.values
      .where((t) => !t.isPro || isPro)
      .toList(growable: false);

  DashboardState copyWith({
    bool? isPro,
    DashboardTab? activeTab,
    DashboardRange? range,
    DashboardEngagementSlot? engagement,
  }) {
    return DashboardState(
      isPro: isPro ?? this.isPro,
      activeTab: activeTab ?? this.activeTab,
      range: range ?? this.range,
      engagement: engagement ?? this.engagement,
    );
  }

  @override
  List<Object?> get props => [isPro, activeTab, range, engagement];
}

/// Per-tab slot — owns the tab's loaded data + its own loading flags.
/// Each tab has its own slot class so future tabs can carry tab-specific
/// state (e.g. selected sub-range) without bloating the others.
class DashboardEngagementSlot extends Equatable {
  const DashboardEngagementSlot({
    this.loading = false,
    this.refreshing = false,
    this.loaded = false,
    this.insights,
    this.alpha,
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;

  /// True once we've made at least one round-trip — used to suppress the
  /// skeleton while refreshing already-loaded data.
  final bool loaded;

  final EngagementInsights? insights;
  final AlphaScore? alpha;
  final List<String> errors;

  DashboardEngagementSlot copyWith({
    bool? loading,
    bool? refreshing,
    bool? loaded,
    EngagementInsights? insights,
    AlphaScore? alpha,
    List<String>? errors,
  }) {
    return DashboardEngagementSlot(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loaded: loaded ?? this.loaded,
      insights: insights ?? this.insights,
      alpha: alpha ?? this.alpha,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props =>
      [loading, refreshing, loaded, insights, alpha, errors];
}

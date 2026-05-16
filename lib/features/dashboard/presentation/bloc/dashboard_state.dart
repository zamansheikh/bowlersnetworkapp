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
    this.xp = const DashboardXpSlot(),
    this.games = const DashboardGamesSlot(),
    this.content = const DashboardProContentSlot(),
    this.audience = const DashboardProAudienceSlot(),
    this.referrals = const DashboardProReferralsSlot(),
    this.weightedIndex = const DashboardProContributionSlot(),
  });

  /// True if the viewer can see + load pro tabs. Set once on init from
  /// the cached Profile in [ProfileBloc].
  final bool isPro;
  final DashboardTab activeTab;
  final DashboardRange range;
  final DashboardEngagementSlot engagement;
  final DashboardXpSlot xp;
  final DashboardGamesSlot games;
  final DashboardProContentSlot content;
  final DashboardProAudienceSlot audience;
  final DashboardProReferralsSlot referrals;
  final DashboardProContributionSlot weightedIndex;

  /// Tabs visible to the current viewer. Used by the screen's tab bar.
  List<DashboardTab> get visibleTabs => DashboardTab.values
      .where((t) => !t.isPro || isPro)
      .toList(growable: false);

  DashboardState copyWith({
    bool? isPro,
    DashboardTab? activeTab,
    DashboardRange? range,
    DashboardEngagementSlot? engagement,
    DashboardXpSlot? xp,
    DashboardGamesSlot? games,
    DashboardProContentSlot? content,
    DashboardProAudienceSlot? audience,
    DashboardProReferralsSlot? referrals,
    DashboardProContributionSlot? weightedIndex,
  }) {
    return DashboardState(
      isPro: isPro ?? this.isPro,
      activeTab: activeTab ?? this.activeTab,
      range: range ?? this.range,
      engagement: engagement ?? this.engagement,
      xp: xp ?? this.xp,
      games: games ?? this.games,
      content: content ?? this.content,
      audience: audience ?? this.audience,
      referrals: referrals ?? this.referrals,
      weightedIndex: weightedIndex ?? this.weightedIndex,
    );
  }

  @override
  List<Object?> get props => [
        isPro,
        activeTab,
        range,
        engagement,
        xp,
        games,
        content,
        audience,
        referrals,
        weightedIndex,
      ];
}

// ── Pro slots ────────────────────────────────────────────────────────────────

class DashboardProContentSlot extends Equatable {
  const DashboardProContentSlot({
    this.loading = false,
    this.refreshing = false,
    this.loaded = false,
    this.data,
    this.errors = const [],
  });
  final bool loading;
  final bool refreshing;
  final bool loaded;
  final ProContent? data;
  final List<String> errors;

  DashboardProContentSlot copyWith({
    bool? loading,
    bool? refreshing,
    bool? loaded,
    ProContent? data,
    List<String>? errors,
  }) {
    return DashboardProContentSlot(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loaded: loaded ?? this.loaded,
      data: data ?? this.data,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [loading, refreshing, loaded, data, errors];
}

class DashboardProAudienceSlot extends Equatable {
  const DashboardProAudienceSlot({
    this.loading = false,
    this.refreshing = false,
    this.loaded = false,
    this.data,
    this.errors = const [],
  });
  final bool loading;
  final bool refreshing;
  final bool loaded;
  final ProAudience? data;
  final List<String> errors;

  DashboardProAudienceSlot copyWith({
    bool? loading,
    bool? refreshing,
    bool? loaded,
    ProAudience? data,
    List<String>? errors,
  }) {
    return DashboardProAudienceSlot(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loaded: loaded ?? this.loaded,
      data: data ?? this.data,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [loading, refreshing, loaded, data, errors];
}

class DashboardProReferralsSlot extends Equatable {
  const DashboardProReferralsSlot({
    this.loading = false,
    this.refreshing = false,
    this.loaded = false,
    this.data,
    this.errors = const [],
  });
  final bool loading;
  final bool refreshing;
  final bool loaded;
  final ProReferrals? data;
  final List<String> errors;

  DashboardProReferralsSlot copyWith({
    bool? loading,
    bool? refreshing,
    bool? loaded,
    ProReferrals? data,
    List<String>? errors,
  }) {
    return DashboardProReferralsSlot(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loaded: loaded ?? this.loaded,
      data: data ?? this.data,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [loading, refreshing, loaded, data, errors];
}

class DashboardProContributionSlot extends Equatable {
  const DashboardProContributionSlot({
    this.loading = false,
    this.refreshing = false,
    this.loaded = false,
    this.data,
    this.errors = const [],
  });
  final bool loading;
  final bool refreshing;
  final bool loaded;
  final ProContribution? data;
  final List<String> errors;

  DashboardProContributionSlot copyWith({
    bool? loading,
    bool? refreshing,
    bool? loaded,
    ProContribution? data,
    List<String>? errors,
  }) {
    return DashboardProContributionSlot(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loaded: loaded ?? this.loaded,
      data: data ?? this.data,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [loading, refreshing, loaded, data, errors];
}

/// Per-tab slot — owns the tab's loaded data + its own loading flags.
/// Each tab has its own slot class so future tabs can carry tab-specific
/// state (e.g. selected sub-range) without bloating the others.

class DashboardXpSlot extends Equatable {
  const DashboardXpSlot({
    this.loading = false,
    this.refreshing = false,
    this.loaded = false,
    this.insights,
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;
  final bool loaded;
  final XpInsights? insights;
  final List<String> errors;

  DashboardXpSlot copyWith({
    bool? loading,
    bool? refreshing,
    bool? loaded,
    XpInsights? insights,
    List<String>? errors,
  }) {
    return DashboardXpSlot(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loaded: loaded ?? this.loaded,
      insights: insights ?? this.insights,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [loading, refreshing, loaded, insights, errors];
}

class DashboardGamesSlot extends Equatable {
  const DashboardGamesSlot({
    this.loading = false,
    this.refreshing = false,
    this.loaded = false,
    this.report,
    this.trends,
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;
  final bool loaded;
  final GamesReport? report;
  final GamesTrends? trends;
  final List<String> errors;

  DashboardGamesSlot copyWith({
    bool? loading,
    bool? refreshing,
    bool? loaded,
    GamesReport? report,
    GamesTrends? trends,
    List<String>? errors,
  }) {
    return DashboardGamesSlot(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loaded: loaded ?? this.loaded,
      report: report ?? this.report,
      trends: trends ?? this.trends,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props =>
      [loading, refreshing, loaded, report, trends, errors];
}

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

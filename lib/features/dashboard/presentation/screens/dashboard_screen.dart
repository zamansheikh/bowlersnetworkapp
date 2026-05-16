import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/dashboard_range_selector.dart';
import 'tabs/engagement_tab.dart';
import 'tabs/games_tab.dart';
import 'tabs/xp_tab.dart';

/// /dashboard — all 7 tabs in a single mobile-friendly scaffold. Tabs
/// are rendered into a single scroll view (one body per active tab) so
/// each tab can have its own scroll position and pull-to-refresh
/// without nested PageView complexity.
///
/// Free users see Engagement / XP / Games only; pro users get the
/// extra Content / Audience / Referrals / Index tabs (gating happens
/// in [DashboardState.visibleTabs]).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Snapshot isPro from the cached profile — falls back to false if
    // ProfileBloc hasn't resolved yet. Pro users can refresh after
    // upgrade by reopening the screen.
    final isPro =
        context.read<ProfileBloc>().state.profile?.user.isPro ?? false;
    return BlocProvider<DashboardBloc>(
      create: (_) => getIt<DashboardBloc>()
        ..add(DashboardInitRequested(isPro: isPro)),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: const AppBackButton(),
      ),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listenWhen: (p, n) => _activeTabErrors(p) != _activeTabErrors(n) &&
            _activeTabErrors(n).isNotEmpty,
        listener: (context, state) {
          showAppToast(
            context,
            message: _activeTabErrors(state).join('\n'),
            variant: ToastVariant.error,
          );
        },
        builder: (context, state) {
          return Column(
            children: [
              _TabBar(
                tabs: state.visibleTabs,
                active: state.activeTab,
                onPick: (t) =>
                    context.read<DashboardBloc>().add(DashboardTabChanged(t)),
              ),
              DashboardRangeSelector(
                active: state.range,
                excludeBeyond30: state.activeTab.isPro,
                onPick: (r) => context
                    .read<DashboardBloc>()
                    .add(DashboardRangeChanged(r)),
              ),
              const SizedBox(height: AppSpacing.xs),
              Expanded(child: _TabBody(state: state)),
            ],
          );
        },
      ),
    );
  }

  List<String> _activeTabErrors(DashboardState s) => switch (s.activeTab) {
        DashboardTab.engagement => s.engagement.errors,
        DashboardTab.xp => s.xp.errors,
        DashboardTab.games => s.games.errors,
        // Batch 3 plugs its slots in here.
        _ => const [],
      };
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.tabs,
    required this.active,
    required this.onPick,
  });

  final List<DashboardTab> tabs;
  final DashboardTab active;
  final ValueChanged<DashboardTab> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.borderDefault),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        child: Row(
          children: [
            for (final t in tabs)
              _TabPill(
                tab: t,
                active: t == active,
                onTap: () => onPick(t),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.tab,
    required this.active,
    required this.onTap,
  });

  final DashboardTab tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 12,
              ),
              child: Row(
                children: [
                  if (tab.isPro) ...[
                    Icon(LucideIcons.crown,
                        size: 11,
                        color: active ? colors.accent : colors.textTertiary),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    tab.label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: active ? colors.accent : colors.textSecondary,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 2,
              width: 24,
              decoration: BoxDecoration(
                color: active ? colors.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBody extends StatelessWidget {
  const _TabBody({required this.state});
  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    // Each tab handles its own refresh + skeleton internally. We just
    // key the widget on the active tab so swapping tabs gets a fresh
    // scroll position.
    switch (state.activeTab) {
      case DashboardTab.engagement:
        return EngagementTab(slot: state.engagement);
      case DashboardTab.xp:
        return XpTab(slot: state.xp);
      case DashboardTab.games:
        return GamesTab(slot: state.games);
      case DashboardTab.content:
      case DashboardTab.audience:
      case DashboardTab.referrals:
      case DashboardTab.weightedIndex:
        return const _ComingSoonTab();
    }
  }
}

/// Placeholder for tabs that ship in batches 2 + 3.
class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab();
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.sparkles, size: 32, color: colors.textTertiary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Coming soon',
              style: AppTextStyles.sectionTitle.copyWith(
                color: colors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'This tab is being polished and will land in the next update.',
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.bodySmall.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

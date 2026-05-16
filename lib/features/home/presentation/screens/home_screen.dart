import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/bn_logo.dart';
import '../../../../core/widgets/glow_blob.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../shell/widgets/app_drawer.dart';
import '../bloc/home_bloc.dart';
import '../widgets/home_discussions_preview.dart';
import '../widgets/home_events_preview.dart';
import '../widgets/home_feed_preview.dart';
import '../widgets/home_hero_greeting.dart';
import '../widgets/home_leaderboard_preview.dart';
import '../widgets/home_live_now_strip.dart';
import '../widgets/home_media_preview.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_xp_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (_) => getIt<HomeBloc>()..add(const HomeLoadRequested()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(LucideIcons.menu, size: 20),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        titleSpacing: AppSpacing.base,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            BnLogoMark(size: 28, showGlow: false),
            SizedBox(width: AppSpacing.sm),
            BnWordmark(fontSize: 16),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(RouteNames.notifications),
            icon: const Icon(LucideIcons.bell, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -80,
            right: -80,
            child: GlowBlob(
              size: 260,
              color: colors.accent,
              opacity: 0.05,
              animate: false,
            ),
          ),
          SafeArea(
            top: false,
            child: BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                return RefreshIndicator(
                  color: colors.accent,
                  onRefresh: () async {
                    context
                        .read<HomeBloc>()
                        .add(const HomeRefreshRequested());
                    await context
                        .read<HomeBloc>()
                        .stream
                        .firstWhere((s) => !s.refreshing);
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.xl,
                    ),
                    children: [
                      // ─── Search bar ───
                      HomeSearchBar(
                        onTap: () => context.push(RouteNames.search),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ─── Live now strip (hidden when empty) ───
                      if (state.livePreview.isNotEmpty) ...[
                        HomeLiveNowStrip(
                          broadcasts: state.livePreview,
                          onViewAll: () => context.push(RouteNames.events),
                          onTap: (_) => context.push(RouteNames.events),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],

                      // ─── Hero greeting ───
                      BlocBuilder<ProfileBloc, ProfileState>(
                        buildWhen: (p, n) =>
                            p.profile?.user.firstName !=
                            n.profile?.user.firstName,
                        builder: (context, profile) {
                          final first = profile.profile?.user.firstName.trim();
                          return HomeHeroGreeting(
                            firstName: (first == null || first.isEmpty)
                                ? (profile.profile?.user.username ?? 'there')
                                : first,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ─── XP card ───
                      BlocBuilder<ProfileBloc, ProfileState>(
                        buildWhen: (p, n) =>
                            p.xp != n.xp || p.loading != n.loading,
                        builder: (context, profile) {
                          if (profile.xp == null) {
                            return profile.loading
                                ? const SkeletonCard(height: 110)
                                : const SizedBox.shrink();
                          }
                          return HomeXpCard(
                            xp: profile.xp!,
                            onTap: () => context.push(RouteNames.leaderboard),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ─── Quick actions ───
                      HomeQuickActions(
                        actions: [
                          HomeQuickAction(
                            icon: LucideIcons.squarePen,
                            label: 'Create a post',
                            onTap: () => context.go(RouteNames.newsfeed),
                          ),
                          HomeQuickAction(
                            icon: LucideIcons.messageCircle,
                            label: 'Start a discussion',
                            onTap: () => context.push(RouteNames.chatter),
                          ),
                          HomeQuickAction(
                            icon: LucideIcons.calendar,
                            label: 'Browse events',
                            onTap: () => context.push(RouteNames.events),
                          ),
                          HomeQuickAction(
                            icon: LucideIcons.target,
                            label: 'Track a game',
                            onTap: () => context.go(RouteNames.games),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // ─── Your feed preview ───
                      if (state.loading && state.feedPreview.isEmpty)
                        const SkeletonCard(height: 220)
                      else
                        HomeFeedPreview(
                          posts: state.feedPreview,
                          onViewAll: () => context.go(RouteNames.newsfeed),
                          onPostTap: (_) => context.go(RouteNames.newsfeed),
                        ),
                      const SizedBox(height: AppSpacing.md),

                      // ─── Top discussions preview ───
                      if (state.loading && state.discussionsPreview.isEmpty)
                        const SkeletonCard(height: 220)
                      else
                        HomeDiscussionsPreview(
                          discussions: state.discussionsPreview,
                          onViewAll: () => context.push(RouteNames.chatter),
                          onTap: (_) => context.push(RouteNames.chatter),
                        ),
                      const SizedBox(height: AppSpacing.md),

                      // ─── Weekly leaderboard preview ───
                      if (state.loading && state.leaderboardPreview.isEmpty)
                        const SkeletonCard(height: 280)
                      else
                        HomeLeaderboardPreview(
                          entries: state.leaderboardPreview,
                          onViewAll: () =>
                              context.push(RouteNames.leaderboard),
                        ),
                      const SizedBox(height: AppSpacing.md),

                      // ─── Upcoming events preview ───
                      if (state.loading && state.eventsPreview.isEmpty)
                        const SkeletonCard(height: 220)
                      else
                        HomeEventsPreview(
                          events: state.eventsPreview,
                          onViewAll: () => context.push(RouteNames.events),
                          onTap: (_) => context.push(RouteNames.events),
                        ),
                      const SizedBox(height: AppSpacing.md),

                      // ─── Trending media grid ───
                      if (state.loading && state.mediaPreview.isEmpty)
                        const SkeletonCard(height: 260)
                      else
                        HomeMediaPreview(
                          items: state.mediaPreview,
                          onViewAll: () => context.push(RouteNames.media),
                          onTap: (_) => context.push(RouteNames.media),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

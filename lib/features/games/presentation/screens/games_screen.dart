import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_fab.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/repositories/games_repository.dart';
import '../bloc/games_bloc.dart';
import '../widgets/session_card.dart';
import '../widgets/stats_card.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GamesBloc>(
      create: (_) => getIt<GamesBloc>()..add(const GamesLoadRequested()),
      child: const _GamesView(),
    );
  }
}

class _GamesView extends StatefulWidget {
  const _GamesView();

  @override
  State<_GamesView> createState() => _GamesViewState();
}

class _GamesViewState extends State<_GamesView> {
  bool _creatingSession = false;

  Future<void> _startNewSession(BuildContext ctx) async {
    if (_creatingSession) return;
    setState(() => _creatingSession = true);
    final res = await getIt<GamesRepository>().createSession();
    if (!mounted) return;
    setState(() => _creatingSession = false);
    res.fold(
      (f) => showAppToast(
        ctx,
        message: f.messages.isNotEmpty
            ? f.messages.first
            : 'Couldn\'t start a new session.',
        variant: ToastVariant.error,
      ),
      (session) {
        // Refresh the list so the new session shows even before we return.
        ctx.read<GamesBloc>().add(const GamesLoadRequested(force: true));
        ctx.push('${RouteNames.games}/play/${session.uid}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.navGames),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.circle, size: 20),
            tooltip: 'My equipment',
            onPressed: () =>
                context.push('${RouteNames.games}/equipment'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chartLine, size: 20),
            tooltip: 'Analytics',
            onPressed: () => context.push('${RouteNames.games}/stats'),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      floatingActionButton: AppFab.extended(
        icon: LucideIcons.plus,
        label: _creatingSession ? 'Starting…' : 'New session',
        onPressed: _creatingSession ? null : () => _startNewSession(context),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<GamesBloc, GamesState>(
          builder: (context, state) {
            if (state.loading && state.sessions.isEmpty && state.stats == null) {
              return const _GamesSkeleton();
            }

            return RefreshIndicator(
              color: colors.accent,
              onRefresh: () async {
                context.read<GamesBloc>().add(const GamesRefreshRequested());
                await context
                    .read<GamesBloc>()
                    .stream
                    .firstWhere((s) => !s.refreshing);
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.base),
                children: [
                  if (state.stats != null) ...[
                    GameStatsCard(stats: state.stats!),
                    const SizedBox(height: AppSpacing.base),
                  ],
                  Row(
                    children: [
                      Text(
                        'RECENT SESSIONS',
                        style: AppTextStyles.label.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      if (state.sessions.isNotEmpty)
                        Text(
                          '${state.sessions.length}',
                          style: AppTextStyles.micro.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (state.sessions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xl),
                      child: EmptyState(
                        icon: LucideIcons.target,
                        title: 'No sessions yet',
                        hint: state.errors.isNotEmpty
                            ? state.errors.join('\n')
                            : 'Start a session to track frames and series.',
                        action: state.errors.isNotEmpty
                            ? AppButton(
                                label: l10n.actionRetry,
                                onPressed: () => context
                                    .read<GamesBloc>()
                                    .add(const GamesRefreshRequested()),
                              )
                            : null,
                      ),
                    )
                  else
                    for (final s in state.sessions) ...[
                      SessionCard(
                        session: s,
                        onTap: () => context.push(
                          '${RouteNames.games}/sessions/${s.uid}',
                          extra: s,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  const SizedBox(height: AppSpacing.xl2),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GamesSkeleton extends StatelessWidget {
  const _GamesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.base),
      children: const [
        SkeletonBox(height: 160),
        SizedBox(height: AppSpacing.base),
        SkeletonCard(height: 140),
        SizedBox(height: AppSpacing.md),
        SkeletonCard(height: 140),
      ],
    );
  }
}

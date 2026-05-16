import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../bloc/my_events_bloc.dart';
import '../widgets/event_card.dart';

/// /events/my — paginated list of events the viewer created. Used as
/// the host's dashboard shortcut.
class MyEventsScreen extends StatelessWidget {
  const MyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MyEventsBloc>(
      create: (_) =>
          getIt<MyEventsBloc>()..add(const MyEventsLoadRequested()),
      child: const _MyEventsView(),
    );
  }
}

class _MyEventsView extends StatefulWidget {
  const _MyEventsView();
  @override
  State<_MyEventsView> createState() => _MyEventsViewState();
}

class _MyEventsViewState extends State<_MyEventsView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final remaining =
        _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (remaining < 600) {
      context.read<MyEventsBloc>().add(const MyEventsNextPageRequested());
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('My events'),
        leading: const AppBackButton(fallbackRoute: '/events'),
        actions: [
          IconButton(
            tooltip: 'New event',
            icon: const Icon(LucideIcons.plus),
            onPressed: () => context.push('/events/new'),
          ),
        ],
      ),
      body: BlocConsumer<MyEventsBloc, MyEventsState>(
        listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
        listener: (context, state) {
          showAppToast(
            context,
            message: state.errors.join('\n'),
            variant: ToastVariant.error,
          );
        },
        builder: (context, state) {
          if (state.loading && state.events.isEmpty) {
            return const _Skeleton();
          }
          if (state.events.isEmpty) {
            return const EmptyState(
              icon: LucideIcons.calendarPlus,
              title: "You haven't created any events",
              hint: 'Tap the + above to host your first one.',
            );
          }
          return RefreshIndicator(
            color: colors.accent,
            onRefresh: () async {
              context
                  .read<MyEventsBloc>()
                  .add(const MyEventsRefreshRequested());
              await context
                  .read<MyEventsBloc>()
                  .stream
                  .firstWhere((s) => !s.refreshing);
            },
            child: ListView.separated(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.xl,
              ),
              itemCount:
                  state.events.length + (state.loadingMore ? 1 : 0),
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) {
                if (i >= state.events.length) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.accent,
                        ),
                      ),
                    ),
                  );
                }
                final e = state.events[i];
                return EventCard(
                  event: e,
                  onTap: () => context.push('/events/${e.uid}'),
                  // The viewer is always the creator on this screen,
                  // so the interest button is a no-op anyway. Wire
                  // it to a toast so it does nothing surprising.
                  onInterestTap: () => showAppToast(
                    context,
                    message: "You're hosting this event.",
                    variant: ToastVariant.info,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => const SkeletonBox(height: 200),
    );
  }
}

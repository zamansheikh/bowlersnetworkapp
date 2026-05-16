import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../domain/entities/event.dart';
import '../bloc/events_list_bloc.dart';
import '../widgets/event_card.dart';

/// /events — paginated event browser with category tabs. Tap a card to
/// open detail, tap the heart to toggle interest.
class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EventsListBloc>(
      create: (_) => getIt<EventsListBloc>()
        ..add(const EventsListLoadRequested()),
      child: const _EventsView(),
    );
  }
}

class _EventsView extends StatefulWidget {
  const _EventsView();

  @override
  State<_EventsView> createState() => _EventsViewState();
}

class _EventsViewState extends State<_EventsView> {
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
      context.read<EventsListBloc>().add(const EventsListNextPageRequested());
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
        title: const Text('Events'),
        leading: const AppBackButton(),
        actions: [
          IconButton(
            tooltip: 'Invitations',
            icon: const Icon(LucideIcons.mail),
            onPressed: () => context.push('/events/invitations'),
          ),
          IconButton(
            tooltip: 'My events',
            icon: const Icon(LucideIcons.calendarHeart),
            onPressed: () => context.push('/events/my'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(LucideIcons.plus),
        label: const Text('New event'),
        onPressed: () => context.push('/events/new'),
      ),
      body: BlocConsumer<EventsListBloc, EventsListState>(
        listenWhen: (p, n) {
          final ps = p.activeSlot;
          final ns = n.activeSlot;
          return ps.errors != ns.errors && ns.errors.isNotEmpty;
        },
        listener: (context, state) {
          showAppToast(
            context,
            message: state.activeSlot.errors.join('\n'),
            variant: ToastVariant.error,
          );
        },
        builder: (context, state) {
          final slot = state.activeSlot;
          return Column(
            children: [
              _CategoryTabs(
                active: state.activeCategory,
                onPick: (c) => context
                    .read<EventsListBloc>()
                    .add(EventsListCategoryChanged(c)),
              ),
              Expanded(
                child: slot.loading && slot.events.isEmpty
                    ? const _ListSkeleton()
                    : slot.events.isEmpty
                        ? EmptyState(
                            icon: LucideIcons.calendarX,
                            title: _emptyTitleFor(state.activeCategory),
                            hint: _emptyHintFor(state.activeCategory),
                          )
                        : RefreshIndicator(
                            color: colors.accent,
                            onRefresh: () async {
                              context
                                  .read<EventsListBloc>()
                                  .add(const EventsListRefreshRequested());
                              await context
                                  .read<EventsListBloc>()
                                  .stream
                                  .firstWhere(
                                      (s) => !s.activeSlot.refreshing);
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
                              itemCount: slot.events.length +
                                  (slot.loadingMore ? 1 : 0),
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.md),
                              itemBuilder: (_, i) {
                                if (i >= slot.events.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md,
                                    ),
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
                                final e = slot.events[i];
                                return EventCard(
                                  event: e,
                                  onTap: () =>
                                      context.push('/events/${e.uid}'),
                                  onInterestTap: () => context
                                      .read<EventsListBloc>()
                                      .add(EventsListInterestToggled(e.uid)),
                                );
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _emptyTitleFor(EventCategory cat) {
    switch (cat) {
      case EventCategory.trending:
        return 'Nothing trending yet';
      case EventCategory.upcoming:
        return 'No upcoming events';
      case EventCategory.joined:
        return "You haven't joined any events";
      case EventCategory.created:
        return "You haven't created any events";
    }
  }

  String _emptyHintFor(EventCategory cat) {
    switch (cat) {
      case EventCategory.trending:
      case EventCategory.upcoming:
        return 'Check back soon — new events drop daily.';
      case EventCategory.joined:
        return "Tap 'Interested' on an event to track it here.";
      case EventCategory.created:
        return 'Hosting an event? Create one from the web for now.';
    }
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.active, required this.onPick});
  final EventCategory active;
  final ValueChanged<EventCategory> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.bgPrimary,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
        child: Row(
          children: [
            for (var i = 0; i < EventCategory.values.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _TabPill(
                category: EventCategory.values[i],
                active: active == EventCategory.values[i],
                onTap: () => onPick(EventCategory.values[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.category,
    required this.active,
    required this.onTap,
  });

  final EventCategory category;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = active ? Colors.white : colors.textSecondary;
    return Material(
      color: active ? colors.accent : colors.bgSurface,
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        borderRadius: AppRadius.fullAll,
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppRadius.fullAll,
            border: Border.all(
              color: active ? colors.accent : colors.borderDefault,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: colors.accentGlow,
                      blurRadius: 0,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Text(
            category.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: fg,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => const SkeletonBox(height: 220),
    );
  }
}

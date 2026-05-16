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
import '../../domain/entities/chatter.dart';
import '../bloc/chatter_list_bloc.dart';
import '../widgets/discussion_card.dart';

/// /chatter — paginated list of discussions with topic-filter chips and
/// a sort-tab row. Tap a card to open the detail screen.
class ChatterScreen extends StatelessWidget {
  const ChatterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ChatterListBloc>(
      create: (_) => getIt<ChatterListBloc>()
        ..add(const ChatterListLoadRequested()),
      child: const _ChatterView(),
    );
  }
}

class _ChatterView extends StatefulWidget {
  const _ChatterView();
  @override
  State<_ChatterView> createState() => _ChatterViewState();
}

class _ChatterViewState extends State<_ChatterView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final remaining = _scroll.position.maxScrollExtent - _scroll.position.pixels;
    if (remaining < 600) {
      context
          .read<ChatterListBloc>()
          .add(const ChatterListNextPageRequested());
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
        title: const Text('Chatter'),
        leading: const AppBackButton(),
      ),
      body: BlocConsumer<ChatterListBloc, ChatterListState>(
        listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
        listener: (context, state) {
          showAppToast(
            context,
            message: state.errors.join('\n'),
            variant: ToastVariant.error,
          );
        },
        builder: (context, state) {
          if (state.loading && state.discussions.isEmpty) {
            return Column(
              children: [
                _SortTabs(active: state.sort, onPick: (_) {}),
                const Expanded(child: _ListSkeleton()),
              ],
            );
          }
          return Column(
            children: [
              _TopicFilterRow(
                topics: state.topics,
                activeTopicId: state.topicId,
                onPick: (id) => context
                    .read<ChatterListBloc>()
                    .add(ChatterListTopicChanged(id)),
              ),
              _SortTabs(
                active: state.sort,
                onPick: (s) => context
                    .read<ChatterListBloc>()
                    .add(ChatterListSortChanged(s)),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: colors.accent,
                  onRefresh: () async {
                    context
                        .read<ChatterListBloc>()
                        .add(const ChatterListRefreshRequested());
                    await context
                        .read<ChatterListBloc>()
                        .stream
                        .firstWhere((s) => !s.refreshing);
                  },
                  child: state.discussions.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 80),
                            EmptyState(
                              icon: LucideIcons.messageSquare,
                              title: 'No discussions yet',
                              hint: 'Be the first to start one.',
                            ),
                          ],
                        )
                      : ListView.separated(
                          controller: _scroll,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.base,
                            AppSpacing.base,
                            AppSpacing.base,
                            AppSpacing.xl,
                          ),
                          itemCount: state.discussions.length +
                              (state.loadingMore ? 1 : 0),
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (_, i) {
                            if (i >= state.discussions.length) {
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
                            final d = state.discussions[i];
                            return DiscussionCard(
                              discussion: d,
                              onTap: () =>
                                  context.push('/chatter/${d.uid}'),
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
}

class _TopicFilterRow extends StatelessWidget {
  const _TopicFilterRow({
    required this.topics,
    required this.activeTopicId,
    required this.onPick,
  });

  final List<Topic> topics;
  final int? activeTopicId;
  final ValueChanged<int?> onPick;

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          AppSpacing.sm,
          AppSpacing.base,
          0,
        ),
        children: [
          _Chip(
            label: 'All',
            active: activeTopicId == null,
            onTap: () => onPick(null),
          ),
          for (final t in topics) ...[
            const SizedBox(width: 6),
            _Chip(
              label: t.name,
              active: activeTopicId == t.id,
              onTap: () => onPick(t.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: active ? colors.accent.withValues(alpha: 0.12) : colors.bgSurface,
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        borderRadius: AppRadius.fullAll,
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: AppRadius.fullAll,
            border: Border.all(
              color: active ? colors.accent : colors.borderDefault,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: active ? colors.accent : colors.textSecondary,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _SortTabs extends StatelessWidget {
  const _SortTabs({required this.active, required this.onPick});
  final DiscussionSort active;
  final ValueChanged<DiscussionSort> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderDefault)),
      ),
      child: Row(
        children: [
          for (final s in DiscussionSort.values)
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onPick(s),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          s.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: s == active
                                ? colors.accent
                                : colors.textTertiary,
                            fontWeight: s == active
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                        if (s == active)
                          Positioned(
                            bottom: -12,
                            child: Container(
                              width: 32,
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: colors.accent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
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
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => const SkeletonBox(height: 132),
    );
  }
}

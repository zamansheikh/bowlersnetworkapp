import 'package:cached_network_image/cached_network_image.dart';
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
import '../../domain/entities/live_viewer.dart';
import '../bloc/live_list_bloc.dart';

/// /live — paginated list of currently-active broadcasts. Scope toggle
/// flips between "All" and "Following"; cards open the per-broadcast
/// viewer at /live/:uid.
class LiveListScreen extends StatelessWidget {
  const LiveListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LiveListBloc>(
      create: (_) =>
          getIt<LiveListBloc>()..add(const LiveListLoadRequested()),
      child: const _LiveListView(),
    );
  }
}

class _LiveListView extends StatefulWidget {
  const _LiveListView();
  @override
  State<_LiveListView> createState() => _LiveListViewState();
}

class _LiveListViewState extends State<_LiveListView> {
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
      context.read<LiveListBloc>().add(const LiveListNextPageRequested());
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
        title: const Text('Live'),
        leading: const AppBackButton(),
      ),
      body: BlocConsumer<LiveListBloc, LiveListState>(
        listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
        listener: (context, state) {
          showAppToast(
            context,
            message: state.errors.join('\n'),
            variant: ToastVariant.error,
          );
        },
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.sm,
                  AppSpacing.base,
                  AppSpacing.sm,
                ),
                child: _ScopeRail(
                  active: state.scope,
                  onPick: (s) => context
                      .read<LiveListBloc>()
                      .add(LiveListScopeChanged(s)),
                ),
              ),
              Expanded(
                child: state.loading && state.items.isEmpty
                    ? const _Skeleton()
                    : state.items.isEmpty
                        ? RefreshIndicator(
                            color: colors.accent,
                            onRefresh: () async {
                              context
                                  .read<LiveListBloc>()
                                  .add(const LiveListRefreshRequested());
                              await context
                                  .read<LiveListBloc>()
                                  .stream
                                  .firstWhere((s) => !s.refreshing);
                            },
                            child: ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              children: [
                                const SizedBox(height: 64),
                                EmptyState(
                                  icon: LucideIcons.radio,
                                  title: state.scope ==
                                          LiveListScope.following
                                      ? 'No one you follow is live'
                                      : 'Nothing live right now',
                                  hint: state.scope ==
                                          LiveListScope.following
                                      ? 'Try the "All" tab to see other broadcasts.'
                                      : 'Pull down to refresh.',
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            color: colors.accent,
                            onRefresh: () async {
                              context
                                  .read<LiveListBloc>()
                                  .add(const LiveListRefreshRequested());
                              await context
                                  .read<LiveListBloc>()
                                  .stream
                                  .firstWhere((s) => !s.refreshing);
                            },
                            child: ListView.separated(
                              controller: _scroll,
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.base,
                                0,
                                AppSpacing.base,
                                AppSpacing.xl,
                              ),
                              itemCount: state.items.length +
                                  (state.loadingMore ? 1 : 0),
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (_, i) {
                                if (i >= state.items.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.accent,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return _LiveCard(item: state.items[i]);
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

class _ScopeRail extends StatelessWidget {
  const _ScopeRail({required this.active, required this.onPick});
  final LiveListScope active;
  final ValueChanged<LiveListScope> onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final s in LiveListScope.values) ...[
          _ScopePill(scope: s, active: s == active, onTap: () => onPick(s)),
          if (s != LiveListScope.values.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _ScopePill extends StatelessWidget {
  const _ScopePill({
    required this.scope,
    required this.active,
    required this.onTap,
  });
  final LiveListScope scope;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: active ? colors.accent.withValues(alpha: 0.14) : colors.bgSurface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            scope.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: active ? colors.accent : colors.textSecondary,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.item});
  final LiveBroadcastListItem item;

  static const _rose = Color(0xFFE11D48);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.bgSurface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/live/${item.uid}'),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _rose.withValues(alpha: 0.25)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _rose.withValues(alpha: 0.08),
                colors.bgSurface,
                colors.bgSurface,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _Avatar(user: item.user),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.user?.displayName ?? 'Someone',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (item.user?.username != null)
                          Text(
                            '@${item.user!.username}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.nano.copyWith(
                              color: colors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  _LiveBadge(),
                ],
              ),
              if (item.title.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _Stat(
                    icon: LucideIcons.users,
                    label: '${item.viewerCount}',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _Stat(
                    icon: LucideIcons.heart,
                    label: '${item.reactionsCount}',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _Stat(
                    icon: LucideIcons.messageCircle,
                    label: '${item.commentsCount}',
                  ),
                  const Spacer(),
                  if (item.startedAt != null)
                    Text(
                      _liveFor(item.startedAt!),
                      style: AppTextStyles.nano.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _liveFor(DateTime startedAt) {
    final minutes = DateTime.now().difference(startedAt).inMinutes;
    if (minutes < 1) return 'Just live';
    if (minutes < 60) return '$minutes min live';
    final hours = minutes ~/ 60;
    return '${hours}h live';
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE11D48),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: AppTextStyles.nano.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: colors.textTertiary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.nano.copyWith(
            color: colors.textTertiary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});
  final LiveBroadcastUser? user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = user?.firstName.isNotEmpty == true
        ? user!.firstName.substring(0, 1).toUpperCase()
        : user?.username.isNotEmpty == true
            ? user!.username.substring(0, 1).toUpperCase()
            : '?';
    final placeholder = Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
      ),
      child: Text(
        initial,
        style: AppTextStyles.bodySmall.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final url = user?.profilePictureUrl;
    if (url == null || url.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: 38,
        height: 38,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, _) => placeholder,
          errorWidget: (_, _, _) => placeholder,
        ),
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
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, _) => const SkeletonBox(height: 130),
    );
  }
}

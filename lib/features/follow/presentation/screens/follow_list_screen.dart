import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/repositories/follow_repository.dart';
import '../bloc/follow_list_bloc.dart';
import '../widgets/follow_list_tile.dart';

/// Generic followers/followings list. Pass `source` to pick which endpoint
/// (and `userId` when looking at someone else's list). Title is derived
/// from `source` so we ship one screen, not four.
class FollowListScreen extends StatelessWidget {
  const FollowListScreen({
    super.key,
    required this.source,
    this.userId,
    this.title,
  });

  final FollowListSource source;
  final int? userId;

  /// Override the auto-derived title (useful when showing another user's
  /// list and you want "Jay's Followers" instead of "Followers").
  final String? title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FollowListBloc>(
      create: (_) => FollowListBloc(
        repository: getIt<FollowRepository>(),
        source: source,
        userId: userId,
      )..add(const FollowListLoadRequested()),
      child: _FollowListView(source: source, title: title),
    );
  }
}

class _FollowListView extends StatelessWidget {
  const _FollowListView({required this.source, this.title});
  final FollowListSource source;
  final String? title;

  String _defaultTitle() => switch (source) {
        FollowListSource.myFollowers ||
        FollowListSource.userFollowers =>
          'Followers',
        FollowListSource.myFollowings ||
        FollowListSource.userFollowings =>
          'Following',
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final myUserId =
        context.select<ProfileBloc, int?>((b) => b.state.profile?.user.id);

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: Text(title ?? _defaultTitle()),
      ),
      body: BlocBuilder<FollowListBloc, FollowListState>(
        builder: (context, state) {
          if (state.loading && state.users.isEmpty) {
            return const _FollowListSkeleton();
          }
          if (state.users.isEmpty) {
            return EmptyState(
              icon: source == FollowListSource.myFollowers ||
                      source == FollowListSource.userFollowers
                  ? LucideIcons.users
                  : LucideIcons.userCheck,
              title: _emptyTitle(),
              hint: state.errors.isNotEmpty ? state.errors.join('\n') : null,
              action: state.errors.isNotEmpty
                  ? AppButton(
                      label: context.l10n.actionRetry,
                      onPressed: () => context
                          .read<FollowListBloc>()
                          .add(const FollowListRefreshRequested()),
                    )
                  : null,
            );
          }
          return RefreshIndicator(
            color: colors.accent,
            onRefresh: () async {
              context
                  .read<FollowListBloc>()
                  .add(const FollowListRefreshRequested());
              await context
                  .read<FollowListBloc>()
                  .stream
                  .firstWhere((s) => !s.refreshing);
            },
            child: ListView.separated(
              itemCount: state.users.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                indent: 76,
                color: colors.borderDefault.withValues(alpha: 0.5),
              ),
              itemBuilder: (_, i) {
                final u = state.users[i];
                return FollowListTile(
                  user: u,
                  isSelf: myUserId != null && u.id == myUserId,
                  onToggleFollow: () => context
                      .read<FollowListBloc>()
                      .add(FollowListFollowToggled(userId: u.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _emptyTitle() => switch (source) {
        FollowListSource.myFollowers => 'No followers yet',
        FollowListSource.userFollowers => 'No followers yet',
        FollowListSource.myFollowings => 'Not following anyone',
        FollowListSource.userFollowings => 'Not following anyone',
      };
}

class _FollowListSkeleton extends StatelessWidget {
  const _FollowListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const SkeletonCircle(size: 44),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(height: 14, width: 140),
                  SizedBox(height: 6),
                  SkeletonBox(height: 11, width: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

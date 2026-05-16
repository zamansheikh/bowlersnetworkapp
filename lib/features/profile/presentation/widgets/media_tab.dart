import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../media/domain/entities/media_item.dart';
import '../../../media/domain/repositories/media_repository.dart';
import '../bloc/user_media_bloc.dart';

/// Media tab for both profile screens. Two sub-tabs: Videos / Splits.
/// Each renders a 2-column grid of thumbnails with overlay metadata
/// (duration badge + view count). Tap a tile to launch the player —
/// for now we toast "Opening videos is coming soon" since there's no
/// dedicated player screen yet (defer to media-detail follow-up).
class MediaTab extends StatelessWidget {
  const MediaTab({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserMediaBloc>(
      key: ValueKey('media-tab-$userId'),
      create: (_) => UserMediaBloc(
        repository: getIt<MediaRepository>(),
        userId: userId,
      )..add(const UserMediaLoadRequested()),
      child: const _MediaView(),
    );
  }
}

class _MediaView extends StatefulWidget {
  const _MediaView();

  @override
  State<_MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<_MediaView> {
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
    if (remaining < 800) {
      context.read<UserMediaBloc>().add(const UserMediaNextPageRequested());
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _comingSoon(BuildContext context) {
    showAppToast(
      context,
      message: 'Tap-to-play is coming soon.',
      variant: ToastVariant.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocConsumer<UserMediaBloc, UserMediaState>(
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
            _SubTabBar(
              active: state.activeKind,
              onPick: (k) => context
                  .read<UserMediaBloc>()
                  .add(UserMediaSubTabChanged(k)),
            ),
            Expanded(
              child: slot.loading && slot.items.isEmpty
                  ? const _MediaGridSkeleton()
                  : slot.items.isEmpty
                      ? EmptyState(
                          icon: state.activeKind == MediaKind.video
                              ? LucideIcons.video
                              : LucideIcons.film,
                          title: state.activeKind == MediaKind.video
                              ? 'No videos yet'
                              : 'No splits yet',
                          hint: 'New uploads will appear here.',
                        )
                      : RefreshIndicator(
                          color: colors.accent,
                          onRefresh: () async {
                            context
                                .read<UserMediaBloc>()
                                .add(const UserMediaRefreshRequested());
                            await context
                                .read<UserMediaBloc>()
                                .stream
                                .firstWhere(
                                    (s) => !s.activeSlot.refreshing);
                          },
                          child: GridView.builder(
                            controller: _scroll,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.base,
                              AppSpacing.sm,
                              AppSpacing.base,
                              AppSpacing.xl,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: AppSpacing.sm,
                              crossAxisSpacing: AppSpacing.sm,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: slot.items.length +
                                (slot.loadingMore ? 1 : 0),
                            itemBuilder: (_, i) {
                              if (i >= slot.items.length) {
                                return Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.accent,
                                    ),
                                  ),
                                );
                              }
                              return _MediaTile(
                                item: slot.items[i],
                                onTap: () => _comingSoon(context),
                              );
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _SubTabBar extends StatelessWidget {
  const _SubTabBar({required this.active, required this.onPick});
  final MediaKind active;
  final ValueChanged<MediaKind> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        0,
      ),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          _TabPill(
            icon: LucideIcons.video,
            label: 'Videos',
            active: active == MediaKind.video,
            onTap: () => onPick(MediaKind.video),
          ),
          _TabPill(
            icon: LucideIcons.film,
            label: 'Splits',
            active: active == MediaKind.split,
            onTap: () => onPick(MediaKind.split),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  const _TabPill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Expanded(
      child: Material(
        color: active ? colors.accent.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: AppRadius.fullAll,
        child: InkWell(
          borderRadius: AppRadius.fullAll,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 14,
                    color: active ? colors.accent : colors.textTertiary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: active ? colors.accent : colors.textSecondary,
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.item, required this.onTap});
  final MediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final placeholder = Container(
      color: colors.bgSurfaceHover,
      alignment: Alignment.center,
      child: Icon(
        item.kind == MediaKind.video ? LucideIcons.video : LucideIcons.film,
        color: colors.textTertiary,
        size: 24,
      ),
    );
    return Material(
      color: colors.bgSurface,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: item.thumbnailUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => placeholder,
                      errorWidget: (_, _, _) => placeholder,
                    )
                  else
                    placeholder,
                  // Pinned badge top-left
                  if (item.isPinned)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent,
                          borderRadius: AppRadius.smAll,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.pin,
                                size: 9, color: Colors.white),
                            const SizedBox(width: 3),
                            Text(
                              'Pinned',
                              style: AppTextStyles.nano.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Duration badge bottom-right
                  if (item.durationDisplay != null &&
                      item.durationDisplay!.isNotEmpty)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: AppRadius.smAll,
                        ),
                        child: Text(
                          item.durationDisplay!,
                          style: AppTextStyles.nano.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title.isEmpty
                        ? (item.kind == MediaKind.video
                            ? 'Untitled'
                            : 'Split')
                        : item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(LucideIcons.eye,
                          size: 11, color: colors.textTertiary),
                      const SizedBox(width: 3),
                      Text(
                        '${item.viewsCount}',
                        style: AppTextStyles.nano.copyWith(
                          color: colors.textTertiary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(LucideIcons.heart,
                          size: 11,
                          color: item.hasLiked == true
                              ? colors.accent
                              : colors.textTertiary),
                      const SizedBox(width: 3),
                      Text(
                        '${item.likesCount}',
                        style: AppTextStyles.nano.copyWith(
                          color: item.hasLiked == true
                              ? colors.accent
                              : colors.textTertiary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaGridSkeleton extends StatelessWidget {
  const _MediaGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.75,
      ),
      itemCount: 4,
      itemBuilder: (_, _) => const SkeletonBox(height: 200),
    );
  }
}

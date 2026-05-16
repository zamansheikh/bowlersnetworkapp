import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../newsfeed/presentation/widgets/trading_card.dart' as nf;
import '../../domain/entities/trading_card.dart';
import '../bloc/cards_feed_bloc.dart';

/// /cards — global cards feed. Mirrors the profile Cards tab visually
/// (vertical column of full flippable trading cards) but pulls from
/// `/api/cards/feed` and adds a right-aligned All / Modern / Legacy
/// filter rail above the list.
class CardsScreen extends StatelessWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CardsFeedBloc>(
      create: (_) => getIt<CardsFeedBloc>()
        ..add(const CardsFeedLoadRequested()),
      child: const _CardsFeedView(),
    );
  }
}

class _CardsFeedView extends StatefulWidget {
  const _CardsFeedView();
  @override
  State<_CardsFeedView> createState() => _CardsFeedViewState();
}

class _CardsFeedViewState extends State<_CardsFeedView> {
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
      context.read<CardsFeedBloc>().add(const CardsFeedNextPageRequested());
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
        title: const Text('Cards'),
        leading: const AppBackButton(),
      ),
      body: BlocConsumer<CardsFeedBloc, CardsFeedState>(
        listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
        listener: (context, state) {
          showAppToast(
            context,
            message: state.errors.join('\n'),
            variant: ToastVariant.error,
          );
        },
        builder: (context, state) {
          final visible = state.filteredCards;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.sm,
                  AppSpacing.base,
                  AppSpacing.sm,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _FilterRail(
                    active: state.typeFilter,
                    onPick: (f) => context
                        .read<CardsFeedBloc>()
                        .add(CardsFeedFilterChanged(f)),
                  ),
                ),
              ),
              Expanded(
                child: state.loading && state.cards.isEmpty
                    ? const _CardsSkeleton()
                    : visible.isEmpty
                        ? EmptyState(
                            icon: LucideIcons.idCard,
                            title: state.cards.isEmpty
                                ? 'No cards yet'
                                : 'No ${state.typeFilter.label.toLowerCase()} cards',
                            hint: state.cards.isEmpty
                                ? 'New trading cards will appear here.'
                                : 'Switch the filter to see other types.',
                          )
                        : RefreshIndicator(
                            color: colors.accent,
                            onRefresh: () async {
                              context
                                  .read<CardsFeedBloc>()
                                  .add(const CardsFeedRefreshRequested());
                              await context
                                  .read<CardsFeedBloc>()
                                  .stream
                                  .firstWhere((s) => !s.refreshing);
                            },
                            child: ListView.separated(
                              controller: _scroll,
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.base,
                                AppSpacing.sm,
                                AppSpacing.base,
                                AppSpacing.xl,
                              ),
                              itemCount: visible.length +
                                  (state.loadingMore ? 1 : 0),
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppSpacing.lg),
                              itemBuilder: (_, i) {
                                if (i >= visible.length) {
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
                                return _CardCell(
                                  card: visible[i],
                                  onLike: () => context
                                      .read<CardsFeedBloc>()
                                      .add(CardsFeedLikeToggled(
                                          visible[i].id)),
                                  onCollect: () => context
                                      .read<CardsFeedBloc>()
                                      .add(CardsFeedCollectToggled(
                                          visible[i].id)),
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

/// One card row — flippable [nf.TradingCard] up top, like/collect
/// footer beneath. Cell scales to fit the viewport with the accent
/// shadow having room to breathe.
class _CardCell extends StatelessWidget {
  const _CardCell({
    required this.card,
    required this.onLike,
    required this.onCollect,
  });

  final TradingCard card;
  final VoidCallback onLike;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cellWidth = (screenWidth - AppSpacing.base * 4).clamp(
      220.0,
      nf.TradingCard.cardWidth,
    );
    final scale = cellWidth / nf.TradingCard.cardWidth;
    final cardHeight = nf.TradingCard.cardHeight * scale;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: cellWidth,
            height: cardHeight,
            child: nf.TradingCard(
              typeData: card.rawPayload,
              scale: scale,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _CardFooter(
            card: card,
            onLike: onLike,
            onCollect: onCollect,
          ),
        ],
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({
    required this.card,
    required this.onLike,
    required this.onCollect,
  });

  final TradingCard card;
  final VoidCallback onLike;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ToggleAction(
          icon: LucideIcons.heart,
          active: card.isLiked == true,
          count: card.likesCount,
          onTap: onLike,
        ),
        const SizedBox(width: AppSpacing.md),
        _ToggleAction(
          icon: LucideIcons.bookmark,
          active: card.isCollected == true,
          count: card.collectionsCount,
          onTap: onCollect,
        ),
        if (card.isSealed) ...[
          const SizedBox(width: AppSpacing.md),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors.bgSurfaceHover,
              borderRadius: AppRadius.smAll,
            ),
            child: Text(
              'LEGACY',
              style: AppTextStyles.nano.copyWith(
                color: colors.textTertiary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterRail extends StatelessWidget {
  const _FilterRail({required this.active, required this.onPick});
  final CardFeedTypeFilter active;
  final ValueChanged<CardFeedTypeFilter> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final f in CardFeedTypeFilter.values) ...[
          Material(
            color: active == f
                ? colors.accent.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppRadius.smAll,
            child: InkWell(
              borderRadius: AppRadius.smAll,
              onTap: () => onPick(f),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Text(
                  f.label,
                  style: AppTextStyles.nano.copyWith(
                    color: active == f
                        ? colors.accent
                        : colors.textTertiary,
                    fontWeight:
                        active == f ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          if (f != CardFeedTypeFilter.values.last)
            const SizedBox(width: 4),
        ],
      ],
    );
  }
}

class _ToggleAction extends StatelessWidget {
  const _ToggleAction({
    required this.icon,
    required this.active,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = active ? colors.accent : colors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardsSkeleton extends StatelessWidget {
  const _CardsSkeleton();
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final cellWidth = (screenWidth - AppSpacing.base * 4).clamp(
      220.0,
      nf.TradingCard.cardWidth,
    );
    final cardHeight = nf.TradingCard.cardHeight *
        (cellWidth / nf.TradingCard.cardWidth);
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (_, _) => Center(
        child: SizedBox(
          width: cellWidth,
          child: SkeletonBox(height: cardHeight),
        ),
      ),
    );
  }
}

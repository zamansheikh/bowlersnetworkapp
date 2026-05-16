import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../cards/domain/entities/trading_card.dart';
import '../../../cards/domain/repositories/cards_repository.dart';
import '../../../newsfeed/presentation/widgets/trading_card.dart' as nf;
import '../bloc/user_cards_bloc.dart';

/// Cards tab — renders the actual flippable [nf.TradingCard] widget for
/// each card so visuals match the web grid exactly (per-design theme,
/// accent gradient, name/quote, XP/LVL badges, flip-to-back animation).
///
/// Layout: horizontal scroll matching the web, with the My Cards /
/// Collections sub-tab toggle on the left and the All / Modern / Legacy
/// type filter on the right. Other-user profiles skip the Collections
/// sub-tab since the backend has no equivalent endpoint.
class CardsTab extends StatelessWidget {
  const CardsTab({
    super.key,
    required this.userId,
    required this.isSelf,
  });

  final int userId;
  final bool isSelf;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserCardsBloc>(
      key: ValueKey('cards-tab-$userId-$isSelf'),
      create: (_) => UserCardsBloc(
        repository: getIt<CardsRepository>(),
        isSelf: isSelf,
        userId: userId,
      )..add(const UserCardsLoadRequested()),
      child: _CardsView(isSelf: isSelf),
    );
  }
}

class _CardsView extends StatefulWidget {
  const _CardsView({required this.isSelf});
  final bool isSelf;

  @override
  State<_CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends State<_CardsView> {
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
      context.read<UserCardsBloc>().add(const UserCardsNextPageRequested());
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
    return BlocBuilder<UserCardsBloc, UserCardsState>(
      builder: (context, state) {
        final slot = state.activeSlot;
        final items = state.filteredActiveItems;
        return Column(
          children: [
            // Toolbar — stacked on mobile so neither row truncates:
            // segmented sub-tab (self only) on top, filter rail beneath
            // right-aligned. Matches the web's two-row arrangement when
            // the viewport gets narrow.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.sm,
                AppSpacing.base,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.isSelf)
                    _SubTabBar(
                      active: state.activeTab,
                      onPick: (t) => context
                          .read<UserCardsBloc>()
                          .add(UserCardsSubTabChanged(t)),
                    ),
                  if (widget.isSelf) const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _TypeFilterRail(
                      active: state.typeFilter,
                      onPick: (f) => context
                          .read<UserCardsBloc>()
                          .add(UserCardsFilterChanged(f)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: slot.loading && slot.items.isEmpty
                  ? const _CardsSkeleton()
                  : items.isEmpty
                      ? EmptyState(
                          icon: LucideIcons.idCard,
                          title: slot.items.isEmpty
                              ? (state.activeTab == CardsSubTab.collections
                                  ? 'No collected cards yet'
                                  : 'No cards yet')
                              : 'No ${state.typeFilter.label.toLowerCase()} cards',
                          hint: slot.items.isEmpty
                              ? (state.activeTab == CardsSubTab.collections
                                  ? 'Cards you collect will appear here.'
                                  : 'New trading cards will appear here.')
                              : 'Switch the filter to see other types.',
                        )
                      : RefreshIndicator(
                          color: colors.accent,
                          onRefresh: () async {
                            context
                                .read<UserCardsBloc>()
                                .add(const UserCardsRefreshRequested());
                            await context
                                .read<UserCardsBloc>()
                                .stream
                                .firstWhere(
                                    (s) => !s.activeSlot.refreshing);
                          },
                          // Vertical scroll — one card per row, centred,
                          // maximises each card's visibility on mobile.
                          child: ListView.separated(
                            controller: _scroll,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.base,
                              AppSpacing.sm,
                              AppSpacing.base,
                              AppSpacing.xl,
                            ),
                            itemCount: items.length +
                                (slot.loadingMore ? 1 : 0),
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.lg),
                            itemBuilder: (_, i) {
                              if (i >= items.length) {
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
                              return _CardCell(
                                card: items[i],
                                onLike: () => context
                                    .read<UserCardsBloc>()
                                    .add(UserCardsLikeToggled(items[i].id)),
                                onCollect: () => context
                                    .read<UserCardsBloc>()
                                    .add(UserCardsCollectToggled(
                                        items[i].id)),
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

/// One card cell — flippable [nf.TradingCard] up top, like/collect row
/// underneath. Card width is sized so ~1.7 cards peek into view at
/// once on a typical phone.
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
    // Vertical layout: each card centres in the row at the native 300×420
    // size (capped slightly smaller than the viewport width so the accent
    // shadow has room to breathe).
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxByViewport = (screenWidth - AppSpacing.base * 4).clamp(
      220.0,
      nf.TradingCard.cardWidth,
    );
    final scale = maxByViewport / nf.TradingCard.cardWidth;
    final cardHeight = nf.TradingCard.cardHeight * scale;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: maxByViewport,
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

class _SubTabBar extends StatelessWidget {
  const _SubTabBar({required this.active, required this.onPick});
  final CardsSubTab active;
  final ValueChanged<CardsSubTab> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.fullAll,
        border: Border.all(color: colors.borderDefault),
      ),
      child: Row(
        children: [
          _SegmentPill(
            icon: LucideIcons.idCard,
            label: 'My cards',
            active: active == CardsSubTab.owned,
            onTap: () => onPick(CardsSubTab.owned),
          ),
          _SegmentPill(
            icon: LucideIcons.bookmark,
            label: 'Collections',
            active: active == CardsSubTab.collections,
            onTap: () => onPick(CardsSubTab.collections),
          ),
        ],
      ),
    );
  }
}

class _SegmentPill extends StatelessWidget {
  const _SegmentPill({
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

class _TypeFilterRail extends StatelessWidget {
  const _TypeFilterRail({required this.active, required this.onPick});
  final CardTypeFilter active;
  final ValueChanged<CardTypeFilter> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final f in CardTypeFilter.values) ...[
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
          if (f != CardTypeFilter.values.last) const SizedBox(width: 4),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.xl,
      ),
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

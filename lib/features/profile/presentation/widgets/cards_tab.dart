import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/network_badge.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../cards/domain/entities/trading_card.dart';
import '../../../cards/domain/repositories/cards_repository.dart';
import '../bloc/user_cards_bloc.dart';

/// Cards tab for both profile screens. Self profiles get a Cards /
/// Collections sub-tab toggle; other-user profiles show only Cards
/// (no `/api/cards/collections` equivalent for other users).
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
    if (remaining < 800) {
      context.read<UserCardsBloc>().add(const UserCardsNextPageRequested());
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
      message: 'Full card view is coming soon.',
      variant: ToastVariant.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<UserCardsBloc, UserCardsState>(
      builder: (context, state) {
        final slot = state.activeSlot;
        return Column(
          children: [
            if (widget.isSelf)
              _SubTabBar(
                active: state.activeTab,
                onPick: (t) => context
                    .read<UserCardsBloc>()
                    .add(UserCardsSubTabChanged(t)),
              ),
            Expanded(
              child: slot.loading && slot.items.isEmpty
                  ? const _CardsSkeleton()
                  : slot.items.isEmpty
                      ? EmptyState(
                          icon: LucideIcons.idCard,
                          title: state.activeTab == CardsSubTab.collections
                              ? 'No collected cards yet'
                              : 'No cards yet',
                          hint: state.activeTab == CardsSubTab.collections
                              ? 'Cards you collect will appear here.'
                              : 'New trading cards will appear here.',
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
                          child: ListView.separated(
                            controller: _scroll,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.base,
                              AppSpacing.sm,
                              AppSpacing.base,
                              AppSpacing.xl,
                            ),
                            itemCount: slot.items.length +
                                (slot.loadingMore ? 1 : 0),
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.md),
                            itemBuilder: (_, i) {
                              if (i >= slot.items.length) {
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
                              final card = slot.items[i];
                              return _TradingCardCard(
                                card: card,
                                onLike: () => context
                                    .read<UserCardsBloc>()
                                    .add(UserCardsLikeToggled(card.id)),
                                onCollect: () => context
                                    .read<UserCardsBloc>()
                                    .add(UserCardsCollectToggled(card.id)),
                                onOpenDetail: () => _comingSoon(context),
                                onAuthorTap: card.owner == null ||
                                        card.owner!.username.isEmpty
                                    ? null
                                    : () => context.push(
                                          '/u/${card.owner!.username}',
                                        ),
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
  final CardsSubTab active;
  final ValueChanged<CardsSubTab> onPick;

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
            icon: LucideIcons.idCard,
            label: 'My cards',
            active: active == CardsSubTab.owned,
            onTap: () => onPick(CardsSubTab.owned),
          ),
          _TabPill(
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

/// One card row — owner header, hero photo (display_image_url with an
/// accent gradient frame derived from the card's hue), display name +
/// quote overlay, and like/collect toggles.
class _TradingCardCard extends StatelessWidget {
  const _TradingCardCard({
    required this.card,
    required this.onLike,
    required this.onCollect,
    required this.onOpenDetail,
    this.onAuthorTap,
  });

  final TradingCard card;
  final VoidCallback onLike;
  final VoidCallback onCollect;
  final VoidCallback onOpenDetail;
  final VoidCallback? onAuthorTap;

  Color _accentFromHue(int hue) =>
      HSLColor.fromAHSL(1, (hue % 360).toDouble(), 0.65, 0.55).toColor();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final owner = card.owner;
    final accent = card.accentHue == 0
        ? colors.accent
        : _accentFromHue(card.accentHue);

    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onOpenDetail,
        borderRadius: AppRadius.lgAll,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Owner row
              if (owner != null)
                InkWell(
                  onTap: onAuthorTap,
                  borderRadius: AppRadius.smAll,
                  child: Row(
                    children: [
                      _OwnerAvatar(owner: owner),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    owner.displayName,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (owner.badgeIconUrl != null) ...[
                                  const SizedBox(width: 4),
                                  NetworkBadge(
                                    url: owner.badgeIconUrl,
                                    size: 12,
                                  ),
                                ],
                              ],
                            ),
                            if (owner.rankDisplay != null &&
                                owner.rankDisplay!.isNotEmpty)
                              Text(
                                owner.rankDisplay!,
                                style: AppTextStyles.nano.copyWith(
                                  color: colors.textTertiary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (card.design != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.18),
                            borderRadius: AppRadius.smAll,
                          ),
                          child: Text(
                            card.design!.name,
                            style: AppTextStyles.nano.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              // Photo hero — uses card.displayImageUrl with an accent
              // gradient frame + name overlay at the bottom.
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(
                      color: accent.withValues(alpha: 0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _CardPhoto(
                        url: card.displayImageUrl,
                        accent: accent,
                      ),
                      // Dark gradient overlay at the bottom for legible text.
                      const Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Color(0xCC000000),
                              ],
                              stops: [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),
                      if (card.isSealed)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _PillBadge(
                            label: 'Legacy',
                            color: accent,
                          ),
                        ),
                      Positioned(
                        left: AppSpacing.md,
                        right: AppSpacing.md,
                        bottom: AppSpacing.md,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (card.displayName.isNotEmpty)
                              Text(
                                card.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.pageTitle.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                  shadows: [
                                    Shadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            if (card.quote.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '"${card.quote}"',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.nano.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPhoto extends StatelessWidget {
  const _CardPhoto({required this.url, required this.accent});
  final String url;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.32),
            colors.bgSurfaceHover,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(LucideIcons.idCard, size: 40, color: accent),
    );
    if (url.isEmpty) return fallback;
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => fallback,
      errorWidget: (_, _, _) => fallback,
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.nano.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _OwnerAvatar extends StatelessWidget {
  const _OwnerAvatar({required this.owner});
  final TradingCardOwner owner;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = owner.firstName.isNotEmpty
        ? owner.firstName.substring(0, 1).toUpperCase()
        : owner.username.isNotEmpty
            ? owner.username.substring(0, 1).toUpperCase()
            : '?';
    final placeholder = Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSubtle,
        border: Border.all(color: colors.borderStrong),
      ),
      child: Text(
        initial,
        style: AppTextStyles.nano.copyWith(
          color: colors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    final url = owner.profilePictureUrl;
    if (url == null || url.isEmpty) return placeholder;
    return ClipOval(
      child: SizedBox(
        width: 32,
        height: 32,
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
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.base),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => const SkeletonBox(height: 360),
    );
  }
}

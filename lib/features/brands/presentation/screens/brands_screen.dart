import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../profile/domain/entities/brand.dart';
import '../bloc/brands_bloc.dart';

/// /brands — full brand directory. Search bar, All/Favorites filter
/// pills, sections grouped by brand type (Balls, Shoes, Accessories…).
/// Each tile has an optimistic heart toggle.
class BrandsScreen extends StatelessWidget {
  const BrandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BrandsBloc>(
      create: (_) => getIt<BrandsBloc>()..add(const BrandsLoadRequested()),
      child: const _BrandsView(),
    );
  }
}

class _BrandsView extends StatefulWidget {
  const _BrandsView();
  @override
  State<_BrandsView> createState() => _BrandsViewState();
}

class _BrandsViewState extends State<_BrandsView> {
  final _queryCtl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _queryCtl.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      context.read<BrandsBloc>().add(BrandsQueryChanged(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Brands'),
        leading: const AppBackButton(),
      ),
      body: BlocConsumer<BrandsBloc, BrandsState>(
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
                child: _SearchField(
                  controller: _queryCtl,
                  onChanged: _onQueryChanged,
                ),
              ),
              _FilterRail(
                active: state.filter,
                totalCount: state.brands.length,
                favoritesCount: state.favoritesCount,
                onPick: (f) => context
                    .read<BrandsBloc>()
                    .add(BrandsFilterChanged(f)),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: state.loading && state.brands.isEmpty
                    ? const _BrandsSkeleton()
                    : _BrandsBody(state: state),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandsBody extends StatelessWidget {
  const _BrandsBody({required this.state});
  final BrandsState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final grouped = state.groupedVisible;
    if (grouped.isEmpty) {
      return RefreshIndicator(
        color: colors.accent,
        onRefresh: () async {
          context.read<BrandsBloc>().add(const BrandsRefreshRequested());
          await context
              .read<BrandsBloc>()
              .stream
              .firstWhere((s) => !s.refreshing);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 64),
            EmptyState(
              icon: state.filter == BrandsFilter.favorites
                  ? LucideIcons.heart
                  : LucideIcons.bookmark,
              title: state.query.trim().isNotEmpty
                  ? 'No brands match'
                  : state.filter == BrandsFilter.favorites
                      ? 'No favorites yet'
                      : 'No brands available',
              hint: state.filter == BrandsFilter.favorites
                  ? 'Tap the heart on any brand to favorite it.'
                  : null,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      color: colors.accent,
      onRefresh: () async {
        context.read<BrandsBloc>().add(const BrandsRefreshRequested());
        await context
            .read<BrandsBloc>()
            .stream
            .firstWhere((s) => !s.refreshing);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.base,
          0,
          AppSpacing.base,
          AppSpacing.xl,
        ),
        children: [
          for (final entry in grouped.entries) ...[
            _SectionTitle(label: entry.key, count: entry.value.length),
            const SizedBox(height: AppSpacing.sm),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.85,
              ),
              itemCount: entry.value.length,
              itemBuilder: (_, i) {
                final brand = entry.value[i];
                return _BrandTile(
                  brand: brand,
                  busy: state.busyIds.contains(brand.id),
                );
              },
            ),
            const SizedBox(height: AppSpacing.base),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colors.bgSurfaceHover,
              borderRadius: AppRadius.smAll,
            ),
            child: Text(
              '$count',
              style: AppTextStyles.nano.copyWith(
                color: colors.textTertiary,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandTile extends StatelessWidget {
  const _BrandTile({required this.brand, required this.busy});
  final Brand brand;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.bgSurface,
      borderRadius: AppRadius.mdAll,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: brand.logoUrl.isEmpty
                        ? _LogoPlaceholder(name: brand.name)
                        : CachedNetworkImage(
                            imageUrl: brand.logoUrl,
                            fit: BoxFit.contain,
                            placeholder: (_, _) =>
                                _LogoPlaceholder(name: brand.name),
                            errorWidget: (_, _, _) =>
                                _LogoPlaceholder(name: brand.name),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  brand.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.nano.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: _FavoriteButton(brand: brand, busy: busy),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.brand, required this.busy});
  final Brand brand;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        borderRadius: AppRadius.fullAll,
        onTap: busy
            ? null
            : () => context
                .read<BrandsBloc>()
                .add(BrandFavoriteToggled(brand.id)),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.bgSurfaceElevated.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
          child: Icon(
            brand.isFavorite ? LucideIcons.heart : LucideIcons.heart,
            size: 14,
            color: brand.isFavorite ? colors.error : colors.textTertiary,
            fill: brand.isFavorite ? 1.0 : 0.0,
          ),
        ),
      ),
    );
  }
}

class _LogoPlaceholder extends StatelessWidget {
  const _LogoPlaceholder({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.bgSurfaceHover,
        borderRadius: AppRadius.smAll,
      ),
      padding: const EdgeInsets.all(8),
      child: Text(
        initial,
        style: AppTextStyles.sectionTitle.copyWith(
          color: colors.textTertiary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.borderStrong),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.body.copyWith(color: colors.textPrimary),
        cursorColor: colors.accent,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: 'Search brands…',
          hintStyle: AppTextStyles.body
              .copyWith(color: colors.textTertiary, fontSize: 13),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          prefixIcon: Icon(LucideIcons.search,
              size: 16, color: colors.textTertiary),
          prefixIconConstraints: const BoxConstraints(minWidth: 36),
        ),
      ),
    );
  }
}

class _FilterRail extends StatelessWidget {
  const _FilterRail({
    required this.active,
    required this.totalCount,
    required this.favoritesCount,
    required this.onPick,
  });
  final BrandsFilter active;
  final int totalCount;
  final int favoritesCount;
  final ValueChanged<BrandsFilter> onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Row(
        children: [
          _FilterPill(
            label: 'All',
            count: totalCount,
            active: active == BrandsFilter.all,
            onTap: () => onPick(BrandsFilter.all),
          ),
          const SizedBox(width: 6),
          _FilterPill(
            label: 'Favorites',
            count: favoritesCount,
            active: active == BrandsFilter.favorites,
            onTap: () => onPick(BrandsFilter.favorites),
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: active ? colors.accent.withValues(alpha: 0.14) : colors.bgSurface,
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        borderRadius: AppRadius.fullAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: active ? colors.accent : colors.textSecondary,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: AppTextStyles.nano.copyWith(
                  color: active ? colors.accent : colors.textTertiary,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandsSkeleton extends StatelessWidget {
  const _BrandsSkeleton();
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.base),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.85,
      ),
      itemCount: 9,
      itemBuilder: (_, _) => const SkeletonBox(height: 120),
    );
  }
}

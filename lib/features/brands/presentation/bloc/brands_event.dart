part of 'brands_bloc.dart';

/// What the user is currently viewing — drives the filter pill row.
enum BrandsFilter {
  all('All'),
  favorites('Favorites');

  const BrandsFilter(this.label);
  final String label;
}

sealed class BrandsEvent extends Equatable {
  const BrandsEvent();
  @override
  List<Object?> get props => const [];
}

class BrandsLoadRequested extends BrandsEvent {
  const BrandsLoadRequested({this.force = false});
  final bool force;
  @override
  List<Object?> get props => [force];
}

class BrandsRefreshRequested extends BrandsEvent {
  const BrandsRefreshRequested();
}

class BrandsQueryChanged extends BrandsEvent {
  const BrandsQueryChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class BrandsFilterChanged extends BrandsEvent {
  const BrandsFilterChanged(this.filter);
  final BrandsFilter filter;
  @override
  List<Object?> get props => [filter];
}

class BrandFavoriteToggled extends BrandsEvent {
  const BrandFavoriteToggled(this.brandId);
  final int brandId;
  @override
  List<Object?> get props => [brandId];
}

part of 'brands_bloc.dart';

class BrandsState extends Equatable {
  const BrandsState({
    this.loading = false,
    this.refreshing = false,
    this.brands = const [],
    this.query = '',
    this.filter = BrandsFilter.all,
    this.busyIds = const {},
    this.errors = const [],
  });

  final bool loading;
  final bool refreshing;
  final List<Brand> brands;
  final String query;
  final BrandsFilter filter;

  /// Brand ids with an in-flight favorite toggle. Used to disable the
  /// heart while the request is in flight so the user can't double-tap.
  final Set<int> busyIds;
  final List<String> errors;

  /// Brand count after the active filter — drives the pill counts.
  int get favoritesCount =>
      brands.where((b) => b.isFavorite).length;

  /// The filter + search applied. Returns a flat list — grouping is
  /// done by the screen so we can keep section ordering deterministic.
  List<Brand> get visibleBrands {
    Iterable<Brand> result = brands;
    if (filter == BrandsFilter.favorites) {
      result = result.where((b) => b.isFavorite);
    }
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((b) => b.name.toLowerCase().contains(q));
    }
    return result.toList(growable: false);
  }

  /// Brands grouped by `type` for the section list. Keys are sorted
  /// alphabetically so section order is stable across rebuilds.
  Map<String, List<Brand>> get groupedVisible {
    final map = <String, List<Brand>>{};
    for (final b in visibleBrands) {
      map.putIfAbsent(b.type.isEmpty ? 'Other' : b.type, () => []).add(b);
    }
    final sortedKeys = map.keys.toList()..sort();
    return {for (final k in sortedKeys) k: map[k]!};
  }

  BrandsState withBrand(int brandId, Brand next) {
    final idx = brands.indexWhere((b) => b.id == brandId);
    if (idx == -1) return this;
    final updated = List<Brand>.from(brands);
    updated[idx] = next;
    return copyWith(brands: updated);
  }

  BrandsState withBusy(int brandId, bool busy) {
    final next = Set<int>.from(busyIds);
    if (busy) {
      next.add(brandId);
    } else {
      next.remove(brandId);
    }
    return copyWith(busyIds: next);
  }

  BrandsState copyWith({
    bool? loading,
    bool? refreshing,
    List<Brand>? brands,
    String? query,
    BrandsFilter? filter,
    Set<int>? busyIds,
    List<String>? errors,
  }) {
    return BrandsState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      brands: brands ?? this.brands,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      busyIds: busyIds ?? this.busyIds,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        refreshing,
        brands,
        query,
        filter,
        busyIds,
        errors,
      ];
}

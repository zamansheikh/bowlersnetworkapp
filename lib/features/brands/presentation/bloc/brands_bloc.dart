import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../profile/domain/entities/brand.dart';
import '../../../profile/domain/repositories/profile_repository.dart';

part 'brands_event.dart';
part 'brands_state.dart';

/// Drives /brands — one shot load, client-side search + All/Favorites
/// filter, and optimistic per-row favorite toggling with rollback on
/// error. Brands live in the profile repository because the Brand entity
/// is shared with the profile's favorites strip.
@injectable
class BrandsBloc extends Bloc<BrandsEvent, BrandsState> {
  BrandsBloc(this._repository) : super(const BrandsState()) {
    on<BrandsLoadRequested>(_onLoad);
    on<BrandsRefreshRequested>(_onRefresh);
    on<BrandsQueryChanged>(_onQuery);
    on<BrandsFilterChanged>(_onFilter);
    on<BrandFavoriteToggled>(_onToggle);
  }

  final ProfileRepository _repository;

  Future<void> _onLoad(
    BrandsLoadRequested event,
    Emitter<BrandsState> emit,
  ) async {
    if (state.brands.isNotEmpty && !event.force) return;
    emit(state.copyWith(loading: true, errors: const []));
    await _fetch(emit);
  }

  Future<void> _onRefresh(
    BrandsRefreshRequested event,
    Emitter<BrandsState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, errors: const []));
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<BrandsState> emit) async {
    final res = await _repository.getBrands();
    res.fold(
      (f) => emit(state.copyWith(
        loading: false,
        refreshing: false,
        errors: f.messages.isEmpty
            ? const ['Failed to load brands.']
            : f.messages,
      )),
      (list) => emit(state.copyWith(
        loading: false,
        refreshing: false,
        brands: list,
        errors: const [],
      )),
    );
  }

  void _onQuery(BrandsQueryChanged event, Emitter<BrandsState> emit) {
    emit(state.copyWith(query: event.query));
  }

  void _onFilter(BrandsFilterChanged event, Emitter<BrandsState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onToggle(
    BrandFavoriteToggled event,
    Emitter<BrandsState> emit,
  ) async {
    if (state.busyIds.contains(event.brandId)) return;
    final idx = state.brands.indexWhere((b) => b.id == event.brandId);
    if (idx == -1) return;
    final original = state.brands[idx];
    final optimistic = original.copyWith(isFavorite: !original.isFavorite);
    emit(state
        .withBrand(event.brandId, optimistic)
        .withBusy(event.brandId, true));
    final res = await _repository.toggleBrandFavorite(event.brandId);
    res.fold(
      (f) {
        // Roll back to the original on failure.
        emit(state
            .withBrand(event.brandId, original)
            .withBusy(event.brandId, false)
            .copyWith(
              errors: f.messages.isEmpty
                  ? const ['Failed to update favorite.']
                  : f.messages,
            ));
      },
      (isFavorite) {
        // Backend is authoritative — apply whatever it returned (handles
        // edge cases where the user double-tapped, etc.).
        final corrected = original.copyWith(isFavorite: isFavorite);
        emit(state
            .withBrand(event.brandId, corrected)
            .withBusy(event.brandId, false)
            .copyWith(errors: const []));
      },
    );
  }
}

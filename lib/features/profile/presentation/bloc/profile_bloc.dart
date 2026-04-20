import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/xp_level_info.dart';
import '../../domain/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Drives the profile screen: profile + XP level info + favorite brands.
///
/// All three calls fire in parallel when [ProfileLoadRequested] comes in,
/// mirroring the web's `Promise.allSettled([/api/profile, /api/brands])`
/// pattern plus a separate `/api/xp/level-info` probe.
@lazySingleton
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._repository) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoad);
    on<ProfileCompletionRefreshed>(_onCompletionRefreshed);
    on<ProfileCleared>((_, emit) => emit(const ProfileState()));
  }

  final ProfileRepository _repository;

  Future<void> _onLoad(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, errors: const []));

    // Fire all three in parallel. Only a profile failure is fatal — XP and
    // brands are decorative and may legitimately be empty.
    final results = await Future.wait<dynamic>([
      _repository.getMyProfile(),
      _repository.getXpLevelInfo(),
      _repository.getBrands(),
    ], eagerError: false);

    final profileResult = results[0] as Either<Failure, Profile>;
    final xpResult = results[1] as Either<Failure, XpLevelInfo>;
    final brandsResult = results[2] as Either<Failure, List<Brand>>;

    profileResult.fold(
      (failure) => emit(state.copyWith(
        loading: false,
        errors: failure.messages,
      )),
      (profile) {
        final xp = xpResult.fold<XpLevelInfo?>(
          (_) => null,
          (info) => info.hasRecord ? info : null,
        );
        final brands = brandsResult.fold<List<Brand>>(
          (_) => const <Brand>[],
          (all) => all.where((b) => b.isFavorite).toList(growable: false),
        );
        emit(state.copyWith(
          loading: false,
          profile: profile,
          completionPercentage: profile.completionPercentage,
          isComplete: profile.isComplete,
          xp: xp,
          favoriteBrands: brands,
        ));
      },
    );
  }

  Future<void> _onCompletionRefreshed(
    ProfileCompletionRefreshed event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await _repository.getCompletion();
    result.fold(
      (_) {}, // silent — completion check is a background probe
      (c) => emit(state.copyWith(
        completionPercentage: c.completionPercentage,
        isComplete: c.isComplete,
      )),
    );
  }
}

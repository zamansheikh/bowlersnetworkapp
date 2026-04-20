part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.profile,
    this.loading = false,
    this.completionPercentage = 0,
    this.isComplete = false,
    this.errors = const [],
    this.xp,
    this.favoriteBrands = const [],
  });

  final Profile? profile;
  final bool loading;
  final int completionPercentage;
  final bool isComplete;
  final List<String> errors;

  /// Lightweight XP snapshot — null while loading or if backend returned
  /// an empty object (user has no XP record yet).
  final XpLevelInfo? xp;

  /// Favorites only (subset of the full brands list).
  final List<Brand> favoriteBrands;

  ProfileState copyWith({
    Profile? profile,
    bool? loading,
    int? completionPercentage,
    bool? isComplete,
    List<String>? errors,
    XpLevelInfo? xp,
    List<Brand>? favoriteBrands,
    bool clearXp = false,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      loading: loading ?? this.loading,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      isComplete: isComplete ?? this.isComplete,
      errors: errors ?? this.errors,
      xp: clearXp ? null : (xp ?? this.xp),
      favoriteBrands: favoriteBrands ?? this.favoriteBrands,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        loading,
        completionPercentage,
        isComplete,
        errors,
        xp,
        favoriteBrands,
      ];
}

part of 'other_profile_bloc.dart';

class OtherProfileState extends Equatable {
  const OtherProfileState({
    this.loading = false,
    this.profile,
    this.followBusy = false,
    this.errors = const [],
  });

  /// True while the initial profile load is in flight (and no prior
  /// result is available). Pull-to-refresh also flips this.
  final bool loading;

  final Profile? profile;

  /// True while a follow-toggle RPC is in flight — disables the button
  /// to prevent double-taps from racing.
  final bool followBusy;

  final List<String> errors;

  OtherProfileState copyWith({
    bool? loading,
    Profile? profile,
    bool? followBusy,
    List<String>? errors,
  }) {
    return OtherProfileState(
      loading: loading ?? this.loading,
      profile: profile ?? this.profile,
      followBusy: followBusy ?? this.followBusy,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [loading, profile, followBusy, errors];
}

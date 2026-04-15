part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.profile,
    this.loading = false,
    this.completionPercentage = 0,
    this.isComplete = false,
    this.errors = const [],
  });

  final Profile? profile;
  final bool loading;
  final int completionPercentage;
  final bool isComplete;
  final List<String> errors;

  ProfileState copyWith({
    Profile? profile,
    bool? loading,
    int? completionPercentage,
    bool? isComplete,
    List<String>? errors,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      loading: loading ?? this.loading,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      isComplete: isComplete ?? this.isComplete,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        loading,
        completionPercentage,
        isComplete,
        errors,
      ];
}

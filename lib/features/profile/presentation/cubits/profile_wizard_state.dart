part of 'profile_wizard_cubit.dart';

class ProfileWizardState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final bool isUploading;
  final String? error;
  final ProfileModel? profile;
  final List<CenterModel> centers;
  final int completionPercentage;
  final String? profilePictureUrl;

  const ProfileWizardState({
    this.isLoading = false,
    this.isSaving = false,
    this.isUploading = false,
    this.error,
    this.profile,
    this.centers = const [],
    this.completionPercentage = 0,
    this.profilePictureUrl,
  });

  ProfileWizardState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isUploading,
    String? error,
    ProfileModel? profile,
    List<CenterModel>? centers,
    int? completionPercentage,
    String? profilePictureUrl,
  }) {
    return ProfileWizardState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      profile: profile ?? this.profile,
      centers: centers ?? this.centers,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSaving, isUploading, error, profile, centers, completionPercentage, profilePictureUrl];
}

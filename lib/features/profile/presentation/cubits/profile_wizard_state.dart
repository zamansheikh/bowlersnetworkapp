part of 'profile_wizard_cubit.dart';

class ProfileWizardState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final bool isUploading;
  final String? error;
  final ProfileModel? profile;
  final List<CenterModel> centers;
  final List<WizardStep> steps;
  final int completionPercentage;
  final String? profilePictureUrl;
  final bool allComplete;

  const ProfileWizardState({
    this.isLoading = false,
    this.isSaving = false,
    this.isUploading = false,
    this.error,
    this.profile,
    this.centers = const [],
    this.steps = const [WizardStep.completion],
    this.completionPercentage = 0,
    this.profilePictureUrl,
    this.allComplete = false,
  });

  int get totalSteps => steps.length;

  ProfileWizardState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isUploading,
    String? error,
    ProfileModel? profile,
    List<CenterModel>? centers,
    List<WizardStep>? steps,
    int? completionPercentage,
    String? profilePictureUrl,
    bool? allComplete,
  }) {
    return ProfileWizardState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      profile: profile ?? this.profile,
      centers: centers ?? this.centers,
      steps: steps ?? this.steps,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      allComplete: allComplete ?? this.allComplete,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSaving, isUploading, error, profile, centers, steps, completionPercentage, profilePictureUrl, allComplete];
}

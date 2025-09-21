import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/datasources/brands_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';
import 'profile_completion_state.dart';

@injectable
class ProfileCompletionCubit extends Cubit<ProfileCompletionState> {
  final BrandsRemoteDataSource _brandsDataSource;
  final AuthRepository _authRepository;

  int _currentStep = 0;
  ProfileCompletionData _data = const ProfileCompletionData();

  ProfileCompletionCubit(this._brandsDataSource, this._authRepository)
    : super(ProfileCompletionInitial());

  int get currentStep => _currentStep;
  ProfileCompletionData get data => _data;

  void updateData(ProfileCompletionData newData) {
    _data = newData;
    emit(ProfileDataChanged(data: _data, step: _currentStep));
  }

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      if (_currentStep == 2) {
        // Load brands when reaching step 3
        loadBrands();
      }
      emit(ProfileStepChanged(_currentStep));
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      emit(ProfileStepChanged(_currentStep));
    }
  }

  void goToStep(int step) {
    _currentStep = step;
    if (_currentStep == 2) {
      loadBrands();
    }
    emit(ProfileStepChanged(_currentStep));
  }

  bool canProceedFromCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _data.isStep1Valid;
      case 1:
        return _data.isStep2Valid;
      case 2:
        return _data.isStep3Valid;
      default:
        return false;
    }
  }

  Future<void> loadBrands() async {
    try {
      emit(BrandsLoading());
      final brands = await _brandsDataSource.getBrands();
      emit(BrandsLoaded(brands));
    } catch (e) {
      print('❌ Error loading brands: $e');
      emit(BrandsError('Failed to load brands: ${e.toString()}'));
    }
  }

  Future<void> completeProfile() async {
    try {
      emit(ProfileCompletionLoading());

      // Update favorite brands
      await _brandsDataSource.updateFavoriteBrands(_data.selectedBrandIds);

      // Refresh user profile to get updated completion status
      await _authRepository.getProfile();

      emit(ProfileCompletionSuccess());
    } catch (e) {
      print('❌ Error completing profile: $e');
      emit(
        ProfileCompletionError('Failed to complete profile: ${e.toString()}'),
      );
    }
  }

  void toggleBrandSelection(int brandId) {
    final currentIds = List<int>.from(_data.selectedBrandIds);
    if (currentIds.contains(brandId)) {
      currentIds.remove(brandId);
    } else {
      currentIds.add(brandId);
    }
    _data = _data.copyWith(selectedBrandIds: currentIds);
    emit(ProfileDataChanged(data: _data, step: _currentStep));
  }

  void reset() {
    _currentStep = 0;
    _data = const ProfileCompletionData();
    emit(ProfileCompletionInitial());
  }
}

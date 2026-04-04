import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_button.dart';
import '../../../../core/widgets/bn_text_field.dart';
import '../../data/models/profile_models.dart';
import '../cubits/profile_wizard_cubit.dart';

class ProfileCompletionWizardPage extends StatefulWidget {
  const ProfileCompletionWizardPage({super.key});

  @override
  State<ProfileCompletionWizardPage> createState() => _ProfileCompletionWizardPageState();
}

class _ProfileCompletionWizardPageState extends State<ProfileCompletionWizardPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 8;

  // Local form state
  String? _selectedGender;
  String _handedness = 'Righty';
  String _ballCarry = 'One handed';
  String _grip = 'With Thumb';
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();
  final _centerSearchController = TextEditingController();
  List<CenterModel> _filteredCenters = [];
  CenterModel? _selectedCenter;

  late ProfileWizardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<ProfileWizardCubit>();
    _cubit.loadProfile();
    _cubit.loadCenters();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    _bioController.dispose();
    _centerSearchController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  void _filterCenters(String query, List<CenterModel> allCenters) {
    setState(() {
      if (query.isEmpty) {
        _filteredCenters = [];
      } else {
        _filteredCenters = allCenters
            .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
            .take(10)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ProfileWizardCubit, ProfileWizardState>(
        listener: (context, state) {
          if (state.error != null) {
            context.showErrorSnackBar(state.error!);
            _cubit.clearError();
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.profile == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.bgWhite,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(state),
                  AppSpacing.verticalBase,
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildProfilePictureStep(state),
                        _buildGenderStep(state),
                        _buildBirthdateStep(state),
                        _buildAddressStep(state),
                        _buildHomeCenterStep(state),
                        _buildBallHandlingStep(state),
                        _buildNicknameBioStep(state),
                        _buildCompletionStep(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ProfileWizardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              if (_currentStep > 0)
                IconButton(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                )
              else
                const SizedBox(width: 48),
              const Spacer(),
              Text('Complete Your Profile', style: AppTextStyles.labelLarge),
              const Spacer(),
              if (_currentStep < _totalSteps - 1)
                TextButton(onPressed: _nextStep, child: const Text('Skip'))
              else
                const SizedBox(width: 48),
            ],
          ),
          AppSpacing.verticalXs,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              backgroundColor: AppColors.bgSubtleGray,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          AppSpacing.verticalXs,
          Text('${_currentStep + 1} of $_totalSteps', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  // ── Step 1: Profile Picture ──────────────────────────────

  Widget _buildProfilePictureStep(ProfileWizardState state) {
    final picUrl = state.profilePictureUrl ?? state.profile?.profileMedia?.profilePictureUrl;
    final hasCustomPic = picUrl != null && !picUrl.contains('defaults/');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          Text('Add a Profile Photo', style: AppTextStyles.h3, textAlign: TextAlign.center),
          AppSpacing.verticalSm,
          Text('Help others recognize you', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: state.isUploading ? null : () => _pickAndUploadPhoto(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bgSubtleGray,
                    border: Border.all(color: hasCustomPic ? AppColors.primary : AppColors.borderLight, width: 2),
                    image: picUrl != null && hasCustomPic
                        ? DecorationImage(image: NetworkImage(picUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: hasCustomPic
                      ? null
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.textMuted),
                            SizedBox(height: 8),
                            Text('Tap to add', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                          ],
                        ),
                ),
                if (state.isUploading)
                  Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.4)),
                    child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)),
                  ),
              ],
            ),
          ),
          if (hasCustomPic) ...[
            AppSpacing.verticalMd,
            const Icon(Icons.check_circle, color: AppColors.success, size: 28),
          ],
          const Spacer(),
          BnButton(text: 'Continue', onPressed: _nextStep),
          AppSpacing.verticalXl,
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    final name = image.name.isNotEmpty ? image.name : 'profile.jpg';
    _cubit.uploadProfilePicture(fileBytes: bytes, fileName: name);
  }

  // ── Step 2: Gender ───────────────────────────────────────

  Widget _buildGenderStep(ProfileWizardState state) {
    final existing = state.profile?.gender?.value;
    _selectedGender ??= (existing != null && existing.isNotEmpty) ? existing : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          Text("What's your gender?", style: AppTextStyles.h3, textAlign: TextAlign.center),
          AppSpacing.verticalSm,
          Text('This helps personalize your experience', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(child: _buildGenderCard('Male', Icons.male_rounded)),
              AppSpacing.horizontalBase,
              Expanded(child: _buildGenderCard('Female', Icons.female_rounded)),
            ],
          ),
          const Spacer(),
          BnButton(
            text: 'Continue',
            isLoading: state.isSaving,
            onPressed: _selectedGender == null ? null : () async {
              final ok = await _cubit.updateGender(_selectedGender!);
              if (ok && mounted) _nextStep();
            },
          ),
          AppSpacing.verticalXl,
        ],
      ),
    );
  }

  Widget _buildGenderCard(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: isSelected ? 2 : 1),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.bgWhite,
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: isSelected ? AppColors.primary : AppColors.textMuted),
            AppSpacing.verticalSm,
            Text(gender, style: AppTextStyles.labelLarge.copyWith(color: isSelected ? AppColors.primary : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ── Step 3: Birthdate ────────────────────────────────────

  Widget _buildBirthdateStep(ProfileWizardState state) {
    final existing = state.profile?.birthdate?.dateOfBirth;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          Text('Confirm Your Birthday', style: AppTextStyles.h3, textAlign: TextAlign.center),
          AppSpacing.verticalSm,
          Text(
            existing != null ? 'We have your birthday on file.\nTap continue or update it.' : 'Tap to pick your date of birth.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          const Icon(Icons.cake_outlined, size: 64, color: AppColors.primary),
          if (existing != null) ...[
            AppSpacing.verticalBase,
            Text(existing, style: AppTextStyles.h4),
          ],
          const Spacer(),
          BnButton(
            text: 'Continue',
            isLoading: state.isSaving,
            onPressed: () async {
              if (existing != null) {
                // Already set from signup, just move on
                _nextStep();
                return;
              }
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000, 1, 1),
                firstDate: DateTime(1930),
                lastDate: DateTime.now(),
              );
              if (picked == null || !mounted) return;
              final dob = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
              final ok = await _cubit.updateBirthdate(dob);
              if (ok && mounted) _nextStep();
            },
          ),
          AppSpacing.verticalXl,
        ],
      ),
    );
  }

  // ── Step 4: Address ──────────────────────────────────��───

  Widget _buildAddressStep(ProfileWizardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          Text('Your Location', style: AppTextStyles.h3, textAlign: TextAlign.center),
          AppSpacing.verticalSm,
          Text('Find bowling centers and events near you', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          BnButton(
            text: 'Use My Current Location',
            icon: Icons.my_location_rounded,
            isLoading: state.isSaving,
            onPressed: () async {
              try {
                LocationPermission perm = await Geolocator.checkPermission();
                if (perm == LocationPermission.denied) {
                  perm = await Geolocator.requestPermission();
                }
                if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
                  if (mounted) context.showErrorSnackBar('Location permission denied');
                  return;
                }
                final pos = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium));
                final ok = await _cubit.updateAddress(
                  address: 'Current Location',
                  zipCode: '',
                  latitude: pos.latitude,
                  longitude: pos.longitude,
                );
                if (ok && mounted) _nextStep();
              } catch (e) {
                if (mounted) context.showErrorSnackBar('Could not get location. Please try again.');
              }
            },
          ),
          AppSpacing.verticalMd,
          BnButton(text: 'Skip for Now', isOutlined: true, onPressed: _nextStep),
          const Spacer(),
        ],
      ),
    );
  }

  // ── Step 5: Home Center ──────────────────────────────────

  Widget _buildHomeCenterStep(ProfileWizardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          Text('Home Bowling Center', style: AppTextStyles.h3, textAlign: TextAlign.center),
          AppSpacing.verticalSm,
          Text('Where do you bowl most often?', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          BnTextField(
            controller: _centerSearchController,
            hintText: 'Search bowling centers...',
            prefixIcon: const Icon(Icons.search, size: 20),
            onChanged: (q) => _filterCenters(q, state.centers),
          ),
          if (_selectedCenter != null) ...[
            AppSpacing.verticalMd,
            Container(
              padding: AppSpacing.paddingCard,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  AppSpacing.horizontalSm,
                  Expanded(child: Text(_selectedCenter!.name, style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary))),
                  GestureDetector(
                    onTap: () => setState(() { _selectedCenter = null; _centerSearchController.clear(); _filteredCenters = []; }),
                    child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
          if (_filteredCenters.isNotEmpty && _selectedCenter == null)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: _filteredCenters.length,
                itemBuilder: (_, i) {
                  final center = _filteredCenters[i];
                  return ListTile(
                    leading: const Icon(Icons.place_outlined, color: AppColors.textMuted),
                    title: Text(center.name, style: AppTextStyles.bodyMedium),
                    subtitle: center.address != null ? Text(center.address!, style: AppTextStyles.caption) : null,
                    onTap: () {
                      setState(() { _selectedCenter = center; _filteredCenters = []; _centerSearchController.text = center.name; });
                    },
                  );
                },
              ),
            )
          else
            const Spacer(),
          BnButton(
            text: 'Continue',
            isLoading: state.isSaving,
            onPressed: () async {
              if (_selectedCenter != null) {
                final ok = await _cubit.updateHomeCenter(_selectedCenter!.id, centerName: _selectedCenter!.name);
                if (ok && mounted) _nextStep();
              } else {
                _nextStep(); // skip
              }
            },
          ),
          AppSpacing.verticalXl,
        ],
      ),
    );
  }

  // ── Step 6: Ball Handling Style ──────────────────────────

  Widget _buildBallHandlingStep(ProfileWizardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppSpacing.verticalXl,
            Text('Your Bowling Style', style: AppTextStyles.h3, textAlign: TextAlign.center),
            AppSpacing.verticalSm,
            Text('How do you throw?', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Text('Bowling Hand', style: AppTextStyles.labelLarge),
            AppSpacing.verticalSm,
            Row(children: [
              Expanded(child: _buildChip('Righty', _handedness == 'Righty', () => setState(() => _handedness = 'Righty'))),
              AppSpacing.horizontalSm,
              Expanded(child: _buildChip('Lefty', _handedness == 'Lefty', () => setState(() => _handedness = 'Lefty'))),
            ]),
            AppSpacing.verticalLg,
            Text('Ball Carry', style: AppTextStyles.labelLarge),
            AppSpacing.verticalSm,
            Row(children: [
              Expanded(child: _buildChip('One handed', _ballCarry == 'One handed', () => setState(() => _ballCarry = 'One handed'))),
              AppSpacing.horizontalSm,
              Expanded(child: _buildChip('Two handed', _ballCarry == 'Two handed', () => setState(() => _ballCarry = 'Two handed'))),
            ]),
            AppSpacing.verticalLg,
            Text('Grip Style', style: AppTextStyles.labelLarge),
            AppSpacing.verticalSm,
            Row(children: [
              Expanded(child: _buildChip('With Thumb', _grip == 'With Thumb', () => setState(() => _grip = 'With Thumb'))),
              AppSpacing.horizontalSm,
              Expanded(child: _buildChip('With No Thumb', _grip == 'With No Thumb', () => setState(() => _grip = 'With No Thumb'))),
            ]),
            const SizedBox(height: 32),
            BnButton(
              text: 'Continue',
              isLoading: state.isSaving,
              onPressed: () async {
                final ok = await _cubit.updateBallHandlingStyle(
                  handedness: _handedness,
                  ballCarry: _ballCarry,
                  grip: _grip,
                );
                if (ok && mounted) _nextStep();
              },
            ),
            AppSpacing.verticalXl,
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight, width: isSelected ? 2 : 1),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.bgWhite,
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: isSelected ? AppColors.primary : AppColors.textSecondary)),
      ),
    );
  }

  // ── Step 7: Nickname + Bio ───────────────────────────────

  Widget _buildNicknameBioStep(ProfileWizardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          Text('Almost Done!', style: AppTextStyles.h3, textAlign: TextAlign.center),
          AppSpacing.verticalSm,
          Text('Add a nickname and a short bio', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          BnTextField(controller: _nicknameController, labelText: 'Nickname', hintText: 'What should we call you?', maxLength: 20),
          AppSpacing.verticalBase,
          BnTextField(controller: _bioController, labelText: 'Bio', hintText: 'Tell the bowling community about yourself...', maxLines: 4, maxLength: 280),
          const Spacer(),
          BnButton(
            text: 'Continue',
            isLoading: state.isSaving,
            onPressed: () async {
              final nickname = _nicknameController.text.trim();
              final bio = _bioController.text.trim();
              if (nickname.isEmpty) {
                context.showErrorSnackBar('Please enter a nickname');
                return;
              }
              bool ok = await _cubit.updateNickname(nickname);
              if (!ok || !mounted) return;
              if (bio.isNotEmpty) {
                ok = await _cubit.updateBio(bio);
                if (!ok || !mounted) return;
              }
              _nextStep();
            },
          ),
          AppSpacing.verticalXl,
        ],
      ),
    );
  }

  // ── Step 8: Completion ───────────────────────────────────

  Widget _buildCompletionStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (_, value, child) => Transform.scale(scale: value, child: child),
            child: Container(
              width: 110, height: 110,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.successLight),
              child: const Icon(Icons.check_rounded, size: 60, color: AppColors.success),
            ),
          ),
          AppSpacing.verticalXl,
          Text("You're All Set!", style: AppTextStyles.h2, textAlign: TextAlign.center),
          AppSpacing.verticalMd,
          Text(
            'Your profile is ready.\nWelcome to the BowlersNetwork community!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          BnButton(text: "Let's Go!", onPressed: () => context.go('/home')),
        ],
      ),
    );
  }
}

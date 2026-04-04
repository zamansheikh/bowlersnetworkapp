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
  int _currentIndex = 0;

  // Form state
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
    final totalSteps = _cubit.state.steps.length;
    if (_currentIndex < totalSteps - 1) {
      setState(() => _currentIndex++);
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  void _previousStep() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _pageController.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  void _filterCenters(String query, List<CenterModel> allCenters) {
    setState(() {
      _filteredCenters = query.isEmpty
          ? []
          : allCenters.where((c) => c.name.toLowerCase().contains(query.toLowerCase())).take(10).toList();
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
          // If profile is fully complete already, go straight home
          if (state.allComplete && !state.isLoading) {
            context.go('/home');
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.profile == null) {
            return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
          }

          final steps = state.steps;
          if (steps.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

          return Scaffold(
            backgroundColor: AppColors.bgWhite,
            body: SafeArea(
              child: Column(
                children: [
                  _buildHeader(state),
                  const SizedBox(height: 8),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: steps.length,
                      itemBuilder: (_, index) => _buildStepWidget(steps[index], state),
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
    final total = state.totalSteps;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              if (_currentIndex > 0)
                IconButton(onPressed: _previousStep, icon: const Icon(Icons.arrow_back_ios_new, size: 20))
              else
                const SizedBox(width: 48),
              const Spacer(),
              Text('Complete Your Profile', style: AppTextStyles.labelLarge),
              const Spacer(),
              if (_currentIndex < total - 1)
                TextButton(onPressed: _nextStep, child: const Text('Skip'))
              else
                const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 1 ? (_currentIndex + 1) / total : 1,
              backgroundColor: AppColors.bgSubtleGray,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text('${_currentIndex + 1} of $total', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildStepWidget(WizardStep step, ProfileWizardState state) {
    return switch (step) {
      WizardStep.profilePicture => _buildProfilePictureStep(state),
      WizardStep.gender         => _buildGenderStep(state),
      WizardStep.birthdate      => _buildBirthdateStep(state),
      WizardStep.address        => _buildAddressStep(state),
      WizardStep.homeCenter     => _buildHomeCenterStep(state),
      WizardStep.ballHandling   => _buildBallHandlingStep(state),
      WizardStep.nicknameBio    => _buildNicknameBioStep(state),
      WizardStep.completion     => _buildCompletionStep(),
    };
  }

  // ── Profile Picture ──

  Widget _buildProfilePictureStep(ProfileWizardState state) {
    final picUrl = state.profilePictureUrl;
    final hasPic = picUrl != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text('Add a Profile Photo', style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Help others recognize you', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: state.isUploading ? null : _pickAndUploadPhoto,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bgSubtleGray,
                    border: Border.all(color: hasPic ? AppColors.primary : AppColors.borderLight, width: 2),
                    image: hasPic ? DecorationImage(image: NetworkImage(picUrl), fit: BoxFit.cover) : null,
                  ),
                  child: hasPic ? null : const Column(
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
          if (hasPic) ...[const SizedBox(height: 12), const Icon(Icons.check_circle, color: AppColors.success, size: 28)],
          const Spacer(),
          BnButton(text: 'Continue', onPressed: _nextStep),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadPhoto() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800, imageQuality: 85);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    _cubit.uploadProfilePicture(fileBytes: bytes, fileName: image.name.isNotEmpty ? image.name : 'profile.jpg');
  }

  // ── Gender ──

  Widget _buildGenderStep(ProfileWizardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text("What's your gender?", style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('This helps personalize your experience', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 48),
          Row(children: [
            Expanded(child: _genderCard('Male', Icons.male_rounded)),
            const SizedBox(width: 16),
            Expanded(child: _genderCard('Female', Icons.female_rounded)),
          ]),
          const Spacer(),
          BnButton(
            text: 'Continue', isLoading: state.isSaving,
            onPressed: _selectedGender == null ? null : () async {
              if (await _cubit.updateGender(_selectedGender!) && mounted) _nextStep();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _genderCard(String gender, IconData icon) {
    final sel = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? AppColors.primary : AppColors.borderLight, width: sel ? 2 : 1),
          color: sel ? AppColors.primary.withValues(alpha: 0.08) : AppColors.bgWhite,
        ),
        child: Column(children: [
          Icon(icon, size: 48, color: sel ? AppColors.primary : AppColors.textMuted),
          const SizedBox(height: 8),
          Text(gender, style: AppTextStyles.labelLarge.copyWith(color: sel ? AppColors.primary : AppColors.textSecondary)),
        ]),
      ),
    );
  }

  // ── Birthdate ──

  Widget _buildBirthdateStep(ProfileWizardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text('Your Birthday', style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Pick your date of birth', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 48),
          const Icon(Icons.cake_outlined, size: 64, color: AppColors.primary),
          const Spacer(),
          BnButton(
            text: 'Pick Date & Continue', isLoading: state.isSaving,
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000, 1, 1),
                firstDate: DateTime(1930),
                lastDate: DateTime.now(),
              );
              if (picked == null || !mounted) return;
              final dob = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
              if (await _cubit.updateBirthdate(dob) && mounted) _nextStep();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Address ──

  bool _isGettingLocation = false;

  Future<void> _handleGetLocation() async {
    if (_isGettingLocation) return;
    setState(() => _isGettingLocation = true);

    try {
      // 1. Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        final shouldOpen = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Location Services Disabled'),
            content: const Text('Please turn on location services to use this feature.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Open Settings')),
            ],
          ),
        );
        if (shouldOpen == true) await Geolocator.openLocationSettings();
        return;
      }

      // 2. Check permission — show rationale first if needed
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        if (!mounted) return;
        final shouldRequest = await _showLocationRationale();
        if (shouldRequest != true) return;
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied) {
        if (mounted) context.showErrorSnackBar('Location permission is required for this step');
        return;
      }
      if (perm == LocationPermission.deniedForever) {
        if (!mounted) return;
        await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text('Location permission was permanently denied. Please enable it from your device Settings > Apps > BowlersNetwork > Permissions.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () { Navigator.pop(context); Geolocator.openAppSettings(); },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return;
      }

      // 3. Get position — use last known first (fast), fall back to current
      Position? pos = await Geolocator.getLastKnownPosition();
      pos ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );

      if (!mounted) return;
      final ok = await _cubit.updateAddress(
        address: 'Current Location',
        zipCode: '',
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      if (ok && mounted) _nextStep();
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Could not get location. You can skip this step and add it later.');
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Widget _rationaleRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Future<bool?> _showLocationRationale() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 28),
        ),
        title: const Text('Allow Location Access'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'BowlersNetwork uses your location to:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _rationaleRow(Icons.place_outlined, 'Find bowling centers near you'),
            const SizedBox(height: 8),
            _rationaleRow(Icons.event_outlined, 'Show nearby events & tournaments'),
            const SizedBox(height: 8),
            _rationaleRow(Icons.people_outline, 'Connect with local bowlers'),
            const SizedBox(height: 12),
            Text(
              'Your location is never shared publicly.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not Now')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Allow Location'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressStep(ProfileWizardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text('Your Location', style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Find bowling centers and events near you', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 40),
          BnButton(
            text: 'Use My Current Location', icon: Icons.my_location_rounded,
            isLoading: _isGettingLocation || state.isSaving,
            onPressed: _handleGetLocation,
          ),
          const SizedBox(height: 12),
          BnButton(text: 'Skip for Now', isOutlined: true, onPressed: _nextStep),
          const Spacer(),
        ],
      ),
    );
  }

  // ── Home Center ──

  Widget _buildHomeCenterStep(ProfileWizardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text('Home Bowling Center', style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Where do you bowl most often?', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          BnTextField(
            controller: _centerSearchController,
            hintText: 'Search bowling centers...',
            prefixIcon: const Icon(Icons.search, size: 20),
            onChanged: (q) => _filterCenters(q, state.centers),
          ),
          if (_selectedCenter != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: AppSpacing.paddingCard,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(_selectedCenter!.name, style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary))),
                GestureDetector(
                  onTap: () => setState(() { _selectedCenter = null; _centerSearchController.clear(); _filteredCenters = []; }),
                  child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                ),
              ]),
            ),
          ],
          if (_filteredCenters.isNotEmpty && _selectedCenter == null)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8),
                itemCount: _filteredCenters.length,
                itemBuilder: (_, i) {
                  final c = _filteredCenters[i];
                  return ListTile(
                    leading: const Icon(Icons.place_outlined, color: AppColors.textMuted),
                    title: Text(c.name, style: AppTextStyles.bodyMedium),
                    subtitle: c.address != null ? Text(c.address!, style: AppTextStyles.caption) : null,
                    onTap: () => setState(() { _selectedCenter = c; _filteredCenters = []; _centerSearchController.text = c.name; }),
                  );
                },
              ),
            )
          else
            const Spacer(),
          BnButton(
            text: 'Continue', isLoading: state.isSaving,
            onPressed: () async {
              if (_selectedCenter != null) {
                if (await _cubit.updateHomeCenter(_selectedCenter!.id, centerName: _selectedCenter!.name) && mounted) _nextStep();
              } else {
                _nextStep();
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Ball Handling Style ──

  Widget _buildBallHandlingStep(ProfileWizardState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text('Your Bowling Style', style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('How do you throw?', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          Text('Bowling Hand', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _chip('Righty', _handedness == 'Righty', () => setState(() => _handedness = 'Righty'))),
            const SizedBox(width: 8),
            Expanded(child: _chip('Lefty', _handedness == 'Lefty', () => setState(() => _handedness = 'Lefty'))),
          ]),
          const SizedBox(height: 20),
          Text('Ball Carry', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _chip('One handed', _ballCarry == 'One handed', () => setState(() => _ballCarry = 'One handed'))),
            const SizedBox(width: 8),
            Expanded(child: _chip('Two handed', _ballCarry == 'Two handed', () => setState(() => _ballCarry = 'Two handed'))),
          ]),
          const SizedBox(height: 20),
          Text('Grip Style', style: AppTextStyles.labelLarge),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _chip('With Thumb', _grip == 'With Thumb', () => setState(() => _grip = 'With Thumb'))),
            const SizedBox(width: 8),
            Expanded(child: _chip('With No Thumb', _grip == 'With No Thumb', () => setState(() => _grip = 'With No Thumb'))),
          ]),
          const SizedBox(height: 40),
          BnButton(
            text: 'Continue', isLoading: state.isSaving,
            onPressed: () async {
              if (await _cubit.updateBallHandlingStyle(handedness: _handedness, ballCarry: _ballCarry, grip: _grip) && mounted) _nextStep();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _chip(String label, bool sel, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? AppColors.primary : AppColors.borderLight, width: sel ? 2 : 1),
          color: sel ? AppColors.primary.withValues(alpha: 0.08) : AppColors.bgWhite,
        ),
        child: Text(label, style: AppTextStyles.labelMedium.copyWith(color: sel ? AppColors.primary : AppColors.textSecondary)),
      ),
    );
  }

  // ── Nickname + Bio ──

  Widget _buildNicknameBioStep(ProfileWizardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text('Almost Done!', style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Add a nickname and a short bio', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          BnTextField(controller: _nicknameController, labelText: 'Nickname', hintText: 'What should we call you?', maxLength: 20),
          const SizedBox(height: 16),
          BnTextField(controller: _bioController, labelText: 'Bio', hintText: 'Tell the bowling community about yourself...', maxLines: 4, maxLength: 280),
          const Spacer(),
          BnButton(
            text: 'Continue', isLoading: state.isSaving,
            onPressed: () async {
              final nickname = _nicknameController.text.trim();
              if (nickname.isEmpty) { context.showErrorSnackBar('Please enter a nickname'); return; }
              if (!await _cubit.updateNickname(nickname) || !mounted) return;
              final bio = _bioController.text.trim();
              if (bio.isNotEmpty) { if (!await _cubit.updateBio(bio) || !mounted) return; }
              _nextStep();
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Completion ──

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
          const SizedBox(height: 32),
          Text("You're All Set!", style: AppTextStyles.h2, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text('Your profile is ready.\nWelcome to the BowlersNetwork community!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 48),
          BnButton(text: "Let's Go!", onPressed: () => context.go('/home')),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_button.dart';
import '../../../../core/widgets/bn_text_field.dart';

class ProfileCompletionWizardPage extends StatefulWidget {
  const ProfileCompletionWizardPage({super.key});

  @override
  State<ProfileCompletionWizardPage> createState() => _ProfileCompletionWizardPageState();
}

class _ProfileCompletionWizardPageState extends State<ProfileCompletionWizardPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 8;

  // Step 2 - Gender
  String? _selectedGender;

  // Step 7 - Nickname & Bio
  final _nicknameController = TextEditingController();
  final _bioController = TextEditingController();

  // Step 6 - Ball handling
  String _handedness = 'Right';
  String _ballCarry = 'One Handed';
  String _grip = 'With Thumb';

  @override
  void dispose() {
    _pageController.dispose();
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishWizard() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    IconButton(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    )
                  else
                    const SizedBox(width: 48),
                  const Spacer(),
                  Text(
                    'Complete Your Profile',
                    style: AppTextStyles.labelLarge,
                  ),
                  const Spacer(),
                  if (_currentStep < _totalSteps - 1)
                    TextButton(
                      onPressed: _nextStep,
                      child: const Text('Skip'),
                    )
                  else
                    const SizedBox(width: 48),
                ],
              ),
            ),

            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
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
                  Text(
                    '${_currentStep + 1} of $_totalSteps',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            AppSpacing.verticalBase,

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildProfilePictureStep(),
                  _buildGenderStep(),
                  _buildBirthdateStep(),
                  _buildAddressStep(),
                  _buildHomeCenterStep(),
                  _buildBallHandlingStep(),
                  _buildNicknameBioStep(),
                  _buildCompletionStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          Text('Add a Profile Photo', style: AppTextStyles.h3, textAlign: TextAlign.center),
          AppSpacing.verticalSm,
          Text(
            'Help others recognize you',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: () {
              // TODO: Pick image from camera/gallery
            },
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgSubtleGray,
                border: Border.all(color: AppColors.borderLight, width: 2),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.textMuted),
                  SizedBox(height: 8),
                  Text('Tap to add', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                ],
              ),
            ),
          ),
          const Spacer(),
          BnButton(text: 'Continue', onPressed: _nextStep),
          AppSpacing.verticalXl,
        ],
      ),
    );
  }

  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          Text("What's your gender?", style: AppTextStyles.h3, textAlign: TextAlign.center),
          AppSpacing.verticalSm,
          Text(
            'This helps us personalize your experience',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Expanded(child: _buildGenderCard('Male', Icons.male_rounded)),
              AppSpacing.horizontalBase,
              Expanded(child: _buildGenderCard('Female', Icons.female_rounded)),
            ],
          ),
          const Spacer(),
          BnButton(text: 'Continue', onPressed: _selectedGender != null ? _nextStep : null),
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
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.bgWhite,
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: isSelected ? AppColors.primary : AppColors.textMuted),
            AppSpacing.verticalSm,
            Text(
              gender,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBirthdateStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          Text('Confirm Your Birthday', style: AppTextStyles.h3, textAlign: TextAlign.center),
          AppSpacing.verticalSm,
          Text(
            'Pre-filled from signup. Tap to change.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          const Icon(Icons.cake_outlined, size: 64, color: AppColors.primary),
          const Spacer(),
          BnButton(text: 'Continue', onPressed: _nextStep),
          AppSpacing.verticalXl,
        ],
      ),
    );
  }

  Widget _buildAddressStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          Text('Your Location', style: AppTextStyles.h3, textAlign: TextAlign.center),
          AppSpacing.verticalSm,
          Text(
            'Find bowling centers and events near you',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          BnButton(
            text: 'Use My Current Location',
            icon: Icons.my_location_rounded,
            onPressed: () {
              // TODO: Get GPS location
              _nextStep();
            },
          ),
          AppSpacing.verticalMd,
          BnButton(
            text: 'Enter Manually',
            isOutlined: true,
            onPressed: _nextStep,
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildHomeCenterStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          Text('Home Bowling Center', style: AppTextStyles.h3, textAlign: TextAlign.center),
          AppSpacing.verticalSm,
          Text(
            'Where do you bowl most often?',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          BnTextField(
            hintText: 'Search bowling centers...',
            prefixIcon: const Icon(Icons.search, size: 20),
            onChanged: (query) {
              // TODO: Search centers API
            },
          ),
          const Spacer(),
          BnButton(text: 'Continue', onPressed: _nextStep),
          AppSpacing.verticalXl,
        ],
      ),
    );
  }

  Widget _buildBallHandlingStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          children: [
            AppSpacing.verticalXl,
            Text('Your Bowling Style', style: AppTextStyles.h3, textAlign: TextAlign.center),
            AppSpacing.verticalSm,
            Text(
              'How do you throw?',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Handedness
            Text('Bowling Hand', style: AppTextStyles.labelLarge),
            AppSpacing.verticalSm,
            Row(
              children: [
                Expanded(child: _buildChip('Right', _handedness == 'Right', () => setState(() => _handedness = 'Right'))),
                AppSpacing.horizontalSm,
                Expanded(child: _buildChip('Left', _handedness == 'Left', () => setState(() => _handedness = 'Left'))),
              ],
            ),
            AppSpacing.verticalLg,

            // Ball carry
            Text('Ball Carry', style: AppTextStyles.labelLarge),
            AppSpacing.verticalSm,
            Row(
              children: [
                Expanded(child: _buildChip('One Handed', _ballCarry == 'One Handed', () => setState(() => _ballCarry = 'One Handed'))),
                AppSpacing.horizontalSm,
                Expanded(child: _buildChip('Two Handed', _ballCarry == 'Two Handed', () => setState(() => _ballCarry = 'Two Handed'))),
              ],
            ),
            AppSpacing.verticalLg,

            // Grip
            Text('Grip Style', style: AppTextStyles.labelLarge),
            AppSpacing.verticalSm,
            Row(
              children: [
                Expanded(child: _buildChip('With Thumb', _grip == 'With Thumb', () => setState(() => _grip = 'With Thumb'))),
                AppSpacing.horizontalSm,
                Expanded(child: _buildChip('No Thumb', _grip == 'No Thumb', () => setState(() => _grip = 'No Thumb'))),
              ],
            ),
            const SizedBox(height: 32),
            BnButton(text: 'Continue', onPressed: _nextStep),
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
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.bgWhite,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildNicknameBioStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          Text('Almost Done!', style: AppTextStyles.h3, textAlign: TextAlign.center),
          AppSpacing.verticalSm,
          Text(
            'Add a nickname and a short bio',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          BnTextField(
            controller: _nicknameController,
            labelText: 'Nickname',
            hintText: 'What should we call you?',
          ),
          AppSpacing.verticalBase,
          BnTextField(
            controller: _bioController,
            labelText: 'Bio',
            hintText: 'Tell the bowling community about yourself...',
            maxLines: 4,
            maxLength: 280,
          ),
          const Spacer(),
          BnButton(text: 'Continue', onPressed: _nextStep),
          AppSpacing.verticalXl,
        ],
      ),
    );
  }

  Widget _buildCompletionStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.successLight,
            ),
            child: const Icon(Icons.check_rounded, size: 56, color: AppColors.success),
          ),
          AppSpacing.verticalXl,
          Text("You're All Set!", style: AppTextStyles.h2, textAlign: TextAlign.center),
          AppSpacing.verticalMd,
          Text(
            'Your profile is ready. Welcome to the BowlersNetwork community!',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          BnButton(
            text: "Let's Go!",
            onPressed: _finishWizard,
          ),
        ],
      ),
    );
  }
}

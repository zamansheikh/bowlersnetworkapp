import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/brand.dart';
import '../cubit/profile_completion_cubit.dart';
import '../cubit/profile_completion_state.dart';

class ProfileCompletionPage extends StatelessWidget {
  const ProfileCompletionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          GetIt.instance<ProfileCompletionCubit>()..loadBrands(),
      child: const ProfileCompletionView(),
    );
  }
}

class ProfileCompletionView extends StatefulWidget {
  const ProfileCompletionView({super.key});

  @override
  State<ProfileCompletionView> createState() => _ProfileCompletionViewState();
}

class _ProfileCompletionViewState extends State<ProfileCompletionView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ProfileCompletionCubit, ProfileCompletionState>(
          builder: (context, state) {
            final cubit = context.read<ProfileCompletionCubit>();

            return Column(
              children: [
                // Header with progress
                _buildHeader(context, cubit),

                // Step content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _BowlingStyleStep(cubit: cubit),
                      _LocationStep(cubit: cubit),
                      _BrandSelectionStep(cubit: cubit),
                    ],
                  ),
                ),

                // Navigation buttons
                _buildNavigationButtons(context, cubit),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProfileCompletionCubit cubit) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Container(
            width: 60,
            height: 60,
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset('assets/icon/icon.png', fit: BoxFit.contain),
          ),

          SizedBox(height: AppSpacing.md),

          Text(
            'Complete Your Profile',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.gray800,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: AppSpacing.xs),

          Text(
            'Step ${cubit.currentStep + 1} of 3',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray600),
          ),

          SizedBox(height: AppSpacing.lg),

          // Progress indicator
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= cubit.currentStep;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryLimeGreen
                        : AppColors.gray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    ProfileCompletionCubit cubit,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          if (cubit.currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _previousStep(cubit),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryLimeGreen),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.primaryLimeGreen,
                  ),
                ),
              ),
            ),

          if (cubit.currentStep > 0) SizedBox(width: AppSpacing.md),

          Expanded(
            flex: cubit.currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: () => _nextStep(cubit),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLimeGreen,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                cubit.currentStep == 2 ? 'Complete Profile' : 'Next',
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousStep(ProfileCompletionCubit cubit) {
    cubit.previousStep();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep(ProfileCompletionCubit cubit) {
    if (cubit.currentStep == 2) {
      // Submit profile completion
      cubit.completeProfile();
    } else {
      cubit.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

// Step 1: Bowling Style & Membership
class _BowlingStyleStep extends StatefulWidget {
  final ProfileCompletionCubit cubit;

  const _BowlingStyleStep({required this.cubit});

  @override
  State<_BowlingStyleStep> createState() => __BowlingStyleStepState();
}

class __BowlingStyleStepState extends State<_BowlingStyleStep> {
  final _averageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _averageController.text = widget.cubit.data.average;
  }

  @override
  void dispose() {
    _averageController.dispose();
    super.dispose();
  }

  void _updateData() {
    widget.cubit.updateData(
      widget.cubit.data.copyWith(average: _averageController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.cubit.data;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Text('🎳', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome to Bowlers Network!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Let\'s start by learning about your bowling style and experience.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            Text(
              'Bowling Style',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),

            SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: _buildRadioOption(
                    'One Handed',
                    Icons.sports_cricket,
                    data.bowlingStyle == 'One Handed',
                    () => widget.cubit.updateData(
                      data.copyWith(bowlingStyle: 'One Handed'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildRadioOption(
                    'Two Handed',
                    Icons.sports_handball,
                    data.bowlingStyle == 'Two Handed',
                    () => widget.cubit.updateData(
                      data.copyWith(bowlingStyle: 'Two Handed'),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg),

            Text(
              'Average Score',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),

            SizedBox(height: AppSpacing.md),

            TextFormField(
              controller: _averageController,
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateData(),
              decoration: InputDecoration(
                hintText: 'Enter your average score (e.g., 150)',
                prefixIcon: const Icon(
                  Icons.sports_score,
                  color: AppColors.primaryLimeGreen,
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryLimeGreen,
                    width: 2,
                  ),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            Text(
              'Division',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 16),

            Column(
              children: [
                _buildRadioOption(
                  'Senior',
                  Icons.elderly,
                  data.division == 'Senior',
                  () => widget.cubit.updateData(
                    data.copyWith(division: 'Senior'),
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                _buildRadioOption(
                  "Men's",
                  Icons.man,
                  data.division == "Men's",
                  () =>
                      widget.cubit.updateData(data.copyWith(division: "Men's")),
                ),
                SizedBox(height: AppSpacing.xs),
                _buildRadioOption(
                  "Women's",
                  Icons.woman,
                  data.division == "Women's",
                  () => widget.cubit.updateData(
                    data.copyWith(division: "Women's"),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.lg),

            Text(
              'Membership Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),

            SizedBox(height: AppSpacing.md),

            // PBA Card Holder
            Card(
              elevation: 0,
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: data.isPBACardHolder
                      ? AppColors.primaryLimeGreen
                      : AppColors.gray.withValues(alpha: 0.3),
                  width: data.isPBACardHolder ? 2 : 1,
                ),
              ),
              child: CheckboxListTile(
                value: data.isPBACardHolder,
                onChanged: (value) {
                  widget.cubit.updateData(
                    data.copyWith(
                      isPBACardHolder: value ?? false,
                      pbaNumber: value == false ? null : data.pbaNumber,
                    ),
                  );
                },
                title: const Text(
                  'PBA Card Holder',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Professional Bowlers Association'),
                activeColor: AppColors.primaryLimeGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            if (data.isPBACardHolder) ...[
              SizedBox(height: AppSpacing.sm),
              TextFormField(
                initialValue: data.pbaNumber ?? '',
                onChanged: (value) =>
                    widget.cubit.updateData(data.copyWith(pbaNumber: value)),
                decoration: InputDecoration(
                  hintText: 'Enter PBA member number',
                  prefixIcon: const Icon(
                    Icons.card_membership,
                    color: AppColors.primaryLimeGreen,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryLimeGreen,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],

            SizedBox(height: AppSpacing.md),

            // USBC Member
            Card(
              elevation: 0,
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: data.isUSBCMember
                      ? AppColors.primaryLimeGreen
                      : AppColors.gray.withValues(alpha: 0.3),
                  width: data.isUSBCMember ? 2 : 1,
                ),
              ),
              child: CheckboxListTile(
                value: data.isUSBCMember,
                onChanged: (value) {
                  widget.cubit.updateData(
                    data.copyWith(
                      isUSBCMember: value ?? false,
                      usbcNumber: value == false ? null : data.usbcNumber,
                    ),
                  );
                },
                title: const Text(
                  'USBC Member',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('United States Bowling Congress'),
                activeColor: AppColors.primaryLimeGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            if (data.isUSBCMember) ...[
              SizedBox(height: AppSpacing.sm),
              TextFormField(
                initialValue: data.usbcNumber ?? '',
                onChanged: (value) =>
                    widget.cubit.updateData(data.copyWith(usbcNumber: value)),
                decoration: InputDecoration(
                  hintText: 'Enter USBC member number',
                  prefixIcon: const Icon(
                    Icons.card_membership,
                    color: AppColors.primaryLimeGreen,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryLimeGreen,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLimeGreen
                : AppColors.gray.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryLimeGreen.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryLimeGreen : AppColors.gray,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppColors.primaryLimeGreen
                      : AppColors.black,
                  fontSize: 16,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryLimeGreen,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// Step 2: Location Information
class _LocationStep extends StatefulWidget {
  final ProfileCompletionCubit cubit;

  const _LocationStep({required this.cubit});

  @override
  State<_LocationStep> createState() => __LocationStepState();
}

class __LocationStepState extends State<_LocationStep> {
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final data = widget.cubit.data;
    _cityController.text = data.city;
    _stateController.text = data.state;
    _zipController.text = data.zipCode;
  }

  @override
  void dispose() {
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  void _updateData() {
    widget.cubit.updateData(
      widget.cubit.data.copyWith(
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location info header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Text('📍', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Help us connect you with nearby bowlers and events.',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'Your Address',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'All fields are required to complete your profile',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.gray),
            ),

            const SizedBox(height: 24),

            // City and State
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'City *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _cityController,
                        onChanged: (_) => _updateData(),
                        decoration: InputDecoration(
                          hintText: 'e.g., New York',
                          prefixIcon: const Icon(
                            Icons.location_city,
                            color: AppColors.primaryLimeGreen,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryLimeGreen,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.error,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'State *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _stateController,
                        onChanged: (_) => _updateData(),
                        decoration: InputDecoration(
                          hintText: 'e.g., NY',
                          prefixIcon: const Icon(
                            Icons.map,
                            color: AppColors.primaryLimeGreen,
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primaryLimeGreen,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.error,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ZIP Code
            const Text(
              'ZIP Code *',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _zipController,
              keyboardType: TextInputType.number,
              onChanged: (_) => _updateData(),
              decoration: InputDecoration(
                hintText: 'e.g., 12345',
                prefixIcon: const Icon(
                  Icons.local_post_office,
                  color: AppColors.primaryLimeGreen,
                ),
                filled: true,
                fillColor: AppColors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primaryLimeGreen,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.error,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your location helps us recommend nearby bowling centers, tournaments, and connect you with local players.',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// Step 3: Brand Selection
class _BrandSelectionStep extends StatelessWidget {
  final ProfileCompletionCubit cubit;

  const _BrandSelectionStep({required this.cubit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: BlocBuilder<ProfileCompletionCubit, ProfileCompletionState>(
        builder: (context, state) {
          if (state is BrandsLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryLimeGreen),
                  SizedBox(height: 16),
                  Text(
                    'Loading brands...',
                    style: TextStyle(color: AppColors.gray, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (state is BrandsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load brands',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.gray, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => cubit.loadBrands(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLimeGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is BrandsLoaded) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand selection header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Choose Your Favorite Brands',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Select brands you love - you can choose multiple from each category.',
                                style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  if (cubit.data.selectedBrandIds.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLimeGreen.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primaryLimeGreen.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryLimeGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${cubit.data.selectedBrandIds.length} brands selected',
                            style: const TextStyle(
                              color: AppColors.primaryLimeGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  ...state.brands.brandsByCategory.entries.map((entry) {
                    return _buildBrandCategory(entry.key, entry.value);
                  }),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildBrandCategory(String categoryName, List<Brand> brands) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryLimeGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            categoryName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLimeGreen,
            ),
          ),
        ),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: brands.length,
          itemBuilder: (context, index) {
            final brand = brands[index];
            final isSelected = cubit.data.selectedBrandIds.contains(
              brand.brandId,
            );

            return GestureDetector(
              onTap: () => cubit.toggleBrandSelection(brand.brandId),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryLimeGreen
                        : AppColors.gray.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryLimeGreen.withValues(
                              alpha: 0.2,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: AppColors.shadow.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        brand.logoUrl,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.gray.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 16,
                              color: AppColors.gray,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        brand.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryLimeGreen
                              : AppColors.black,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primaryLimeGreen,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}

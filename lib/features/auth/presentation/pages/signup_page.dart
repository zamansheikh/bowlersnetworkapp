import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_button.dart';
import '../../../../core/widgets/bn_text_field.dart';
import '../bloc/auth_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Step 1 - Email
  final _emailController = TextEditingController();

  // Step 2 - OTP
  final _otpController = TextEditingController();
  int _resendCountdown = 0;

  // Step 3 - Personal Info
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Step 4 - Date of Birth
  DateTime? _dateOfBirth;
  final _parentEmailController = TextEditingController();
  bool _isCoach = false;

  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _parentEmailController.dispose();
    _authBloc.close();
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
    } else {
      context.pop();
    }
  }

  int? _calculateAge() {
    if (_dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - _dateOfBirth!.year;
    if (now.month < _dateOfBirth!.month ||
        (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  void _startResendTimer() {
    setState(() => _resendCountdown = AppConstants.otpResendSeconds);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCountdown--);
      return _resendCountdown > 0;
    });
  }

  void _sendVerificationCode() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      context.showErrorSnackBar('Please enter your email');
      return;
    }
    _authBloc.add(AuthVerifyEmailRequested(email: email));
  }

  void _handleSignup() {
    final age = _calculateAge();
    if (age == null) return;

    final isMinor = age >= AppConstants.minimumAge && age < AppConstants.adultAge;
    if (isMinor && _parentEmailController.text.trim().isEmpty) {
      context.showErrorSnackBar("Parent/guardian email is required");
      return;
    }

    final month = _dateOfBirth!.month.toString().padLeft(2, '0');
    final day = _dateOfBirth!.day.toString().padLeft(2, '0');
    final dobString = '${_dateOfBirth!.year}-$month-$day';

    _authBloc.add(AuthSignupRequested(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      verificationCode: _otpController.text.trim(),
      dateOfBirth: dobString,
      parentEmail: isMinor ? _parentEmailController.text.trim() : null,
      isCoach: age >= AppConstants.adultAge ? _isCoach : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _authBloc,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.emailSent) {
            _nextStep();
            _startResendTimer();
          } else if (state.status == AuthStatus.authenticated) {
            context.go('/profile-wizard');
          } else if (state.status == AuthStatus.consentRequired) {
            context.go('/auth/consent-pending');
          } else if (state.status == AuthStatus.error) {
            context.showErrorSnackBar(state.errorMessage ?? 'Something went wrong');
            _authBloc.add(const AuthClearError());
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

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
                        IconButton(
                          onPressed: _previousStep,
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                        ),
                        const Spacer(),
                        Text('Step ${_currentStep + 1} of $_totalSteps', style: AppTextStyles.labelSmall),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Progress
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SmoothPageIndicator(
                      controller: _pageController,
                      count: _totalSteps,
                      effect: ExpandingDotsEffect(
                        dotHeight: 6,
                        dotWidth: 6,
                        activeDotColor: AppColors.primary,
                        dotColor: AppColors.borderLight,
                        expansionFactor: 4,
                      ),
                    ),
                  ),
                  AppSpacing.verticalLg,

                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildEmailStep(isLoading),
                        _buildOtpStep(isLoading),
                        _buildPersonalInfoStep(),
                        _buildDateOfBirthStep(isLoading),
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

  Widget _buildEmailStep(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: SvgPicture.asset(AssetPaths.splashLogo, width: 60)),
          AppSpacing.verticalLg,
          Text('Create Account', style: AppTextStyles.h2, textAlign: TextAlign.center),
          AppSpacing.verticalXs,
          Text(
            'Enter your email to get started',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          BnTextField(
            controller: _emailController,
            labelText: 'Email Address',
            hintText: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            onSubmitted: (_) => _sendVerificationCode(),
          ),
          const SizedBox(height: 32),
          BnButton(
            text: 'Send Verification Code',
            isLoading: isLoading,
            onPressed: _sendVerificationCode,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account? ',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
              GestureDetector(
                onTap: () => context.go('/auth/login'),
                child: Text('Sign In', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(bool isLoading) {
    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: AppTextStyles.h3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderLight),
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.primary),
          AppSpacing.verticalLg,
          Text('Verify Your Email', style: AppTextStyles.h2, textAlign: TextAlign.center),
          AppSpacing.verticalXs,
          Text(
            'Enter the 6-digit code sent to\n${_emailController.text}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Center(
            child: Pinput(
              controller: _otpController,
              length: AppConstants.otpLength,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
              ),
              onCompleted: (_) => _nextStep(),
            ),
          ),
          const SizedBox(height: 32),
          BnButton(text: 'Continue', onPressed: _nextStep),
          AppSpacing.verticalBase,
          Center(
            child: TextButton(
              onPressed: _resendCountdown > 0
                  ? null
                  : () {
                      _sendVerificationCode();
                      _startResendTimer();
                    },
              child: Text(
                _resendCountdown > 0 ? 'Resend in ${_resendCountdown}s' : 'Resend Code',
                style: AppTextStyles.labelMedium.copyWith(
                  color: _resendCountdown > 0 ? AppColors.textMuted : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Personal Info', style: AppTextStyles.h2, textAlign: TextAlign.center),
          AppSpacing.verticalXs,
          Text(
            'Tell us a bit about yourself',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: BnTextField(
                  controller: _firstNameController,
                  labelText: 'First Name',
                  hintText: 'John',
                  textInputAction: TextInputAction.next,
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: BnTextField(
                  controller: _lastNameController,
                  labelText: 'Last Name',
                  hintText: 'Doe',
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          AppSpacing.verticalBase,
          BnTextField(
            controller: _usernameController,
            labelText: 'Username',
            hintText: '4-12 chars, starts with letter',
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.alternate_email, size: 20),
          ),
          AppSpacing.verticalBase,
          BnTextField(
            controller: _passwordController,
            labelText: 'Password',
            hintText: 'Min 8 characters',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20, color: AppColors.textMuted,
              ),
            ),
          ),
          AppSpacing.verticalBase,
          BnTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirm Password',
            hintText: 'Re-enter your password',
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                size: 20, color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 32),
          BnButton(
            text: 'Continue',
            onPressed: () {
              if (_firstNameController.text.trim().isEmpty ||
                  _lastNameController.text.trim().isEmpty ||
                  _usernameController.text.trim().isEmpty) {
                context.showErrorSnackBar('Please fill in all fields');
                return;
              }
              if (_passwordController.text.length < 8) {
                context.showErrorSnackBar('Password must be at least 8 characters');
                return;
              }
              if (_passwordController.text != _confirmPasswordController.text) {
                context.showErrorSnackBar('Passwords do not match');
                return;
              }
              _nextStep();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthStep(bool isLoading) {
    final age = _calculateAge();
    final isMinor = age != null && age >= AppConstants.minimumAge && age < AppConstants.adultAge;
    final isTooYoung = age != null && age < AppConstants.minimumAge;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Date of Birth', style: AppTextStyles.h2, textAlign: TextAlign.center),
          AppSpacing.verticalXs,
          Text(
            'We need this to personalize your experience',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.textMuted),
                  AppSpacing.horizontalMd,
                  Text(
                    _dateOfBirth != null
                        ? '${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}'
                        : 'Select your date of birth',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _dateOfBirth != null ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isTooYoung) ...[
            AppSpacing.verticalBase,
            Container(
              padding: AppSpacing.paddingCard,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: Text(
                      'You must be at least ${AppConstants.minimumAge} years old to use BowlersNetwork.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (isMinor) ...[
            AppSpacing.verticalLg,
            Container(
              padding: AppSpacing.paddingCard,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: Text(
                      'Parental consent is required for users under 18.',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalBase,
            BnTextField(
              controller: _parentEmailController,
              labelText: "Parent/Guardian's Email",
              hintText: "parent@example.com",
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.family_restroom, size: 20),
            ),
          ],

          if (age != null && age >= AppConstants.adultAge) ...[
            AppSpacing.verticalLg,
            CheckboxListTile(
              value: _isCoach,
              onChanged: (v) => setState(() => _isCoach = v ?? false),
              title: Text('I am a bowling coach', style: AppTextStyles.bodyMedium),
              subtitle: Text('Enable coaching features in your profile', style: AppTextStyles.caption),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
          ],

          const SizedBox(height: 32),
          BnButton(
            text: 'Create Account',
            isLoading: isLoading,
            onPressed: (isTooYoung || _dateOfBirth == null) ? null : _handleSignup,
          ),
        ],
      ),
    );
  }
}

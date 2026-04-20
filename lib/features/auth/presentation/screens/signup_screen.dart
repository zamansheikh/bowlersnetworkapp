import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/bn_logo.dart';
import '../../../../core/widgets/glow_blob.dart';
import '../../data/models/auth_dtos.dart';
import '../../domain/usecases/send_email_verification_usecase.dart';
import '../../domain/usecases/validate_registration_usecase.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_header.dart';

enum _SignupStep { register, verify }

/// Username format the backend expects: starts with a letter, letters +
/// digits + underscores, length 4-12. Lifted verbatim from
/// [bn_frontend_base_v2] and confirmed against entrance/validators.py.
final _usernameRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{3,11}$');
final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
final _nameRegex = RegExp(r'^[a-zA-Z\s]+$');

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _parentEmail = TextEditingController();

  DateTime? _dob;
  bool _isCoach = false;
  bool _obscurePwd = true;
  bool _obscureConfirm = true;

  _SignupStep _step = _SignupStep.register;

  // Validation state per-field. Errors populate only AFTER the user taps
  // "Continue"; never on first paint.
  bool _submitAttempted = false;
  final Map<String, String> _fieldErrors = {};

  // Backend-wide errors from /validate/registration or /signup.
  List<String> _serverErrors = const [];
  bool _busy = false;

  // OTP verification state
  String _code = '';
  SignupData? _pendingData;

  bool get _isMinor {
    if (_dob == null) return false;
    final now = DateTime.now();
    var age = now.year - _dob!.year;
    if (now.month < _dob!.month ||
        (now.month == _dob!.month && now.day < _dob!.day)) {
      age -= 1;
    }
    return age < 18;
  }

  bool get _usernameFormatValid =>
      _username.text.isNotEmpty && _usernameRegex.hasMatch(_username.text);

  @override
  void initState() {
    super.initState();
    // Force a rebuild on every keystroke so the username check indicator
    // and parent-email gate update live.
    for (final c in [
      _firstName,
      _lastName,
      _username,
      _email,
      _password,
      _confirmPassword,
      _parentEmail,
    ]) {
      c.addListener(_onAnyFieldChanged);
    }
  }

  void _onAnyFieldChanged() {
    if (_submitAttempted && mounted) {
      // Re-validate so errors disappear as the user fixes them.
      setState(() => _runClientValidation());
    } else {
      // Still rebuild for the live username indicator.
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final c in [
      _firstName,
      _lastName,
      _username,
      _email,
      _password,
      _confirmPassword,
      _parentEmail,
    ]) {
      c
        ..removeListener(_onAnyFieldChanged)
        ..dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Client validation — mirrors web's `clientValidateReg`.
  // ---------------------------------------------------------------------------
  bool _runClientValidation() {
    _fieldErrors.clear();
    final l10n = context.l10n;

    if (_firstName.text.trim().isEmpty) {
      _fieldErrors['first_name'] = l10n.signupFieldRequired;
    } else if (!_nameRegex.hasMatch(_firstName.text.trim())) {
      _fieldErrors['first_name'] = 'Letters only.';
    }

    if (_lastName.text.trim().isEmpty) {
      _fieldErrors['last_name'] = l10n.signupFieldRequired;
    } else if (!_nameRegex.hasMatch(_lastName.text.trim())) {
      _fieldErrors['last_name'] = 'Letters only.';
    }

    if (_email.text.trim().isEmpty) {
      _fieldErrors['email'] = l10n.signupFieldRequired;
    } else if (!_emailRegex.hasMatch(_email.text.trim())) {
      _fieldErrors['email'] = l10n.signupInvalidEmail;
    }

    if (_username.text.trim().isEmpty) {
      _fieldErrors['username'] = l10n.signupFieldRequired;
    } else if (!_usernameRegex.hasMatch(_username.text.trim())) {
      _fieldErrors['username'] = l10n.signupInvalidUsername;
    }

    if (_password.text.isEmpty) {
      _fieldErrors['password'] = l10n.signupFieldRequired;
    } else if (_password.text.length < 8) {
      _fieldErrors['password'] = l10n.signupPasswordTooShort;
    } else if (RegExp(r'^\d+$').hasMatch(_password.text)) {
      _fieldErrors['password'] = 'Password cannot be purely numeric.';
    }

    if (_confirmPassword.text != _password.text) {
      _fieldErrors['confirm_password'] = "Passwords don't match.";
    }

    if (_dob == null) {
      _fieldErrors['dob'] = l10n.signupFieldRequired;
    } else {
      final now = DateTime.now();
      var age = now.year - _dob!.year;
      if (now.month < _dob!.month ||
          (now.month == _dob!.month && now.day < _dob!.day)) {
        age -= 1;
      }
      if (age < 13) {
        _fieldErrors['dob'] = l10n.signupMustBe13;
      } else if (age < 18 && _parentEmail.text.trim().isEmpty) {
        _fieldErrors['parent_email'] = l10n.signupFieldRequired;
      } else if (age < 18 &&
          !_emailRegex.hasMatch(_parentEmail.text.trim())) {
        _fieldErrors['parent_email'] = l10n.signupInvalidEmail;
      }
    }

    return _fieldErrors.isEmpty;
  }

  // ---------------------------------------------------------------------------
  // Submit actions
  // ---------------------------------------------------------------------------
  Future<void> _continueToVerify() async {
    setState(() {
      _submitAttempted = true;
      _serverErrors = const [];
    });
    if (!_runClientValidation()) {
      setState(() {});
      return;
    }

    final data = SignupData(
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim().toLowerCase(),
      username: _username.text.trim().toLowerCase(),
      password: _password.text,
      dateOfBirth:
          '${_dob!.year.toString().padLeft(4, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
      isCoach: _isMinor ? null : _isCoach,
      parentEmail: _isMinor ? _parentEmail.text.trim() : null,
    );

    setState(() => _busy = true);

    // Step A: server-side uniqueness + extra validation
    final validation = await getIt<ValidateRegistrationUseCase>()(data);
    if (!mounted) return;
    final validationFailed = validation.fold((l) => l, (_) => null);
    if (validationFailed != null) {
      setState(() {
        _busy = false;
        _serverErrors = validationFailed.messages;
      });
      return;
    }

    // Step B: send the OTP to the user's email
    final otp = await getIt<SendEmailVerificationUseCase>()(data.email);
    if (!mounted) return;
    otp.fold(
      (f) => setState(() {
        _busy = false;
        _serverErrors = f.messages;
      }),
      (_) {
        setState(() {
          _busy = false;
          _pendingData = data;
          _step = _SignupStep.verify;
        });
        showAppToast(
          context,
          message: context.l10n.signupVerificationSent(data.email),
          variant: ToastVariant.success,
        );
      },
    );
  }

  void _submitSignup() {
    if (_pendingData == null || _code.length != 6) return;
    context.read<AuthBloc>().add(
          AuthSignupRequested(
            data: _pendingData!,
            verificationCode: _code,
          ),
        );
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 13, now.month, now.day),
      initialDate: DateTime(now.year - 18, now.month, now.day),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            if (_step == _SignupStep.verify) {
              setState(() => _step = _SignupStep.register);
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          SafeArea(
            child: BlocListener<AuthBloc, AuthState>(
              listenWhen: (p, n) => p.errors != n.errors,
              listener: (_, state) {
                if (state.errors.isNotEmpty) {
                  setState(() => _serverErrors = state.errors);
                }
              },
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.base,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      children: [
                        const BnLogoMark(size: 48)
                            .animate()
                            .fadeIn(duration: 400.ms, curve: BNCurves.spring),
                        const SizedBox(height: AppSpacing.md),
                        _StepIndicator(step: _step),
                        const SizedBox(height: AppSpacing.lg),
                        AppCard(
                          translucent: true,
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: _step == _SignupStep.register
                              ? _buildRegisterStep(l10n, colors)
                              : _buildVerifyStep(l10n, colors),
                        )
                            .animate()
                            .fadeIn(
                              duration: 500.ms,
                              delay: 120.ms,
                              curve: BNCurves.spring,
                            )
                            .moveY(
                              begin: 16,
                              end: 0,
                              duration: 500.ms,
                              delay: 120.ms,
                              curve: BNCurves.spring,
                            ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Register step
  // ---------------------------------------------------------------------------
  Widget _buildRegisterStep(dynamic l10n, dynamic colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AuthHeader(title: l10n.signupTitle, subtitle: l10n.signupSubtitle),
        const SizedBox(height: AppSpacing.xl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppInput(
                controller: _firstName,
                label: l10n.signupFirstNameLabel,
                errorText: _fieldErrors['first_name'],
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppInput(
                controller: _lastName,
                label: l10n.signupLastNameLabel,
                errorText: _fieldErrors['last_name'],
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          controller: _username,
          label: l10n.signupUsernameLabel,
          hint: l10n.signupUsernameHint,
          errorText: _fieldErrors['username'],
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
            LengthLimitingTextInputFormatter(12),
          ],
          prefixIcon: Icon(LucideIcons.atSign,
              size: 18, color: colors.textTertiary),
          trailing: _UsernameIndicator(
            valid: _usernameFormatValid,
            show: _username.text.isNotEmpty,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          controller: _email,
          label: l10n.signupEmailLabel,
          errorText: _fieldErrors['email'],
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          prefixIcon: Icon(LucideIcons.mail,
              size: 18, color: colors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          controller: _password,
          label: l10n.signupPasswordLabel,
          hint: l10n.signupPasswordHint,
          errorText: _fieldErrors['password'],
          obscure: _obscurePwd,
          textInputAction: TextInputAction.next,
          prefixIcon: Icon(LucideIcons.lock,
              size: 18, color: colors.textTertiary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePwd
                  ? LucideIcons.eye
                  : LucideIcons.eyeOff,
              size: 18,
              color: colors.textTertiary,
            ),
            onPressed: () => setState(() => _obscurePwd = !_obscurePwd),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          controller: _confirmPassword,
          label: 'Confirm password',
          errorText: _fieldErrors['confirm_password'],
          obscure: _obscureConfirm,
          textInputAction: TextInputAction.next,
          prefixIcon: Icon(LucideIcons.lock,
              size: 18, color: colors.textTertiary),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? LucideIcons.eye
                  : LucideIcons.eyeOff,
              size: 18,
              color: colors.textTertiary,
            ),
            onPressed: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _DobField(
          dob: _dob,
          label: l10n.signupDobLabel,
          errorText: _fieldErrors['dob'],
          onTap: _pickDob,
        ),
        if (_isMinor) ...[
          const SizedBox(height: AppSpacing.md),
          AppInput(
            controller: _parentEmail,
            label: l10n.signupParentEmailLabel,
            hint: l10n.signupParentEmailHint,
            errorText: _fieldErrors['parent_email'],
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(LucideIcons.users,
                size: 18, color: colors.textTertiary),
          ),
        ] else if (_dob != null) ...[
          const SizedBox(height: AppSpacing.md),
          _CoachToggle(
            value: _isCoach,
            onChanged: (v) => setState(() => _isCoach = v),
            label: l10n.signupIsCoachLabel,
          ),
        ],
        if (_serverErrors.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          AuthErrorBanner(messages: _serverErrors),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: l10n.actionContinue,
          size: AppButtonSize.large,
          expand: true,
          loading: _busy,
          onPressed: _busy ? null : _continueToVerify,
          trailingIcon: _busy ? null : LucideIcons.arrowRight,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.signupAlreadyHaveAccount,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: () => context.go(RouteNames.login),
              child: Text(
                l10n.actionLogin,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Verify step
  // ---------------------------------------------------------------------------
  Widget _buildVerifyStep(dynamic l10n, dynamic colors) {
    final pinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: AppTextStyles.numberLarge.copyWith(color: colors.textPrimary),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.borderStrong),
      ),
    );

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthHeader(
              title: l10n.signupStepVerify,
              subtitle: l10n.signupVerificationSent(_pendingData?.email ?? ''),
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Pinput(
                length: 6,
                defaultPinTheme: pinTheme,
                focusedPinTheme: pinTheme.copyBorderWith(
                  border: Border.all(color: colors.accent, width: 1.5),
                ),
                autofocus: true,
                keyboardType: TextInputType.number,
                onChanged: (v) => setState(() => _code = v),
                onCompleted: (v) => setState(() => _code = v),
              ),
            ),
            if (state.errors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.base),
              AuthErrorBanner(messages: state.errors),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.actionSignUp,
              size: AppButtonSize.large,
              expand: true,
              loading: state.processing,
              onPressed: (state.processing || _code.length != 6)
                  ? null
                  : _submitSignup,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () async {
                  if (_pendingData == null) return;
                  final res = await getIt<SendEmailVerificationUseCase>()(
                    _pendingData!.email,
                  );
                  if (!mounted) return;
                  res.fold(
                    (f) => showAppToast(context,
                        message: f.messages.join('\n'),
                        variant: ToastVariant.error),
                    (_) => showAppToast(context,
                        message: context.l10n.signupVerificationSent(
                            _pendingData!.email),
                        variant: ToastVariant.success),
                  );
                },
                child: Text(l10n.actionResend),
              ),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// Sub-widgets
// =============================================================================

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final _SignupStep step;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget dot(bool active) => Container(
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? colors.accent : colors.borderStrong,
            borderRadius: BorderRadius.circular(4),
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dot(step == _SignupStep.register),
        const SizedBox(width: 6),
        dot(step == _SignupStep.verify),
      ],
    );
  }
}

class _UsernameIndicator extends StatelessWidget {
  const _UsernameIndicator({required this.valid, required this.show});

  final bool valid;
  final bool show;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (!show) return const SizedBox(width: 0);
    return AnimatedSwitcher(
      duration: AppDurations.short,
      child: valid
          ? Container(
              key: const ValueKey('valid'),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(LucideIcons.check, size: 12, color: colors.success),
            )
          : Container(
              key: const ValueKey('invalid'),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: colors.textTertiary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                LucideIcons.hourglass,
                size: 12,
                color: colors.textTertiary,
              ),
            ),
    );
  }
}

class _DobField extends StatelessWidget {
  const _DobField({
    required this.dob,
    required this.label,
    required this.errorText,
    required this.onTap,
  });

  final DateTime? dob;
  final String label;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.label.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.mdAll,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: colors.bgSurface,
                borderRadius: AppRadius.mdAll,
                border: Border.all(
                  color: hasError ? colors.error : colors.borderStrong,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 16,
                    color: colors.textTertiary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      dob == null
                          ? 'Select your date of birth'
                          : '${dob!.year}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}',
                      style: AppTextStyles.body.copyWith(
                        color: dob == null
                            ? colors.textTertiary
                            : colors.textPrimary,
                        fontWeight: dob == null
                            ? FontWeight.w400
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    LucideIcons.chevronDown,
                    size: 18,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: AppTextStyles.secondary.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }
}

class _CoachToggle extends StatelessWidget {
  const _CoachToggle({
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: value
                ? colors.accent.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: value
                  ? colors.accent.withValues(alpha: 0.3)
                  : colors.borderDefault,
            ),
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.graduationCap,
                size: 18,
                color: value ? colors.accent : colors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeThumbColor: colors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

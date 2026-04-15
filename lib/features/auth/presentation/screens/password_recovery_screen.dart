import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/usecases/password_recovery_usecases.dart';
import '../widgets/auth_header.dart';

enum _RecoveryStep { email, otp, reset }

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _emailCtl = TextEditingController();
  final _newPwdCtl = TextEditingController();
  final _confirmCtl = TextEditingController();

  _RecoveryStep _step = _RecoveryStep.email;
  String _otp = '';
  String? _recoveryToken;
  List<String> _errors = const [];
  bool _busy = false;

  @override
  void dispose() {
    _emailCtl.dispose();
    _newPwdCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    setState(() {
      _busy = true;
      _errors = const [];
    });
    final result = await getIt<InitiateRecoveryOtpUseCase>()(
      _emailCtl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (f) => setState(() => _errors = f.messages),
      (_) => setState(() => _step = _RecoveryStep.otp),
    );
  }

  Future<void> _submitOtp() async {
    if (_otp.length != 6) return;
    setState(() {
      _busy = true;
      _errors = const [];
    });
    final result = await getIt<ValidateRecoveryOtpUseCase>()(
      ValidateOtpParams(email: _emailCtl.text.trim(), otp: _otp),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (f) => setState(() => _errors = f.messages),
      (token) => setState(() {
        _recoveryToken = token;
        _step = _RecoveryStep.reset;
      }),
    );
  }

  Future<void> _submitReset() async {
    if (_newPwdCtl.text != _confirmCtl.text) {
      setState(() => _errors = [context.l10n.recoveryPasswordMismatch]);
      return;
    }
    if (_newPwdCtl.text.length < 8) {
      setState(() => _errors = [context.l10n.signupPasswordTooShort]);
      return;
    }
    setState(() {
      _busy = true;
      _errors = const [];
    });
    final result = await getIt<ResetPasswordUseCase>()(
      ResetPasswordParams(
        recoveryToken: _recoveryToken!,
        newPassword: _newPwdCtl.text,
      ),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (f) => setState(() => _errors = f.messages),
      (_) {
        showAppToast(
          context,
          message: context.l10n.recoveryDone,
          variant: ToastVariant.success,
        );
        context.go(RouteNames.login);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: l10n.recoveryTitle,
                subtitle: _step == _RecoveryStep.email
                    ? l10n.recoverySubtitle
                    : _step == _RecoveryStep.otp
                        ? l10n.recoverySentDescription(_emailCtl.text.trim())
                        : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (_step == _RecoveryStep.email) _emailStep(l10n, colors),
              if (_step == _RecoveryStep.otp) _otpStep(l10n, colors),
              if (_step == _RecoveryStep.reset) _resetStep(l10n),
              const SizedBox(height: AppSpacing.base),
              AuthErrorBanner(messages: _errors),
              const SizedBox(height: AppSpacing.base),
              AppButton(
                label: _step == _RecoveryStep.reset
                    ? l10n.actionSave
                    : l10n.actionContinue,
                loading: _busy,
                expand: true,
                size: AppButtonSize.large,
                onPressed: _busy
                    ? null
                    : switch (_step) {
                        _RecoveryStep.email => _submitEmail,
                        _RecoveryStep.otp => _submitOtp,
                        _RecoveryStep.reset => _submitReset,
                      },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emailStep(dynamic l10n, colors) => AppInput(
        controller: _emailCtl,
        label: l10n.signupEmailLabel,
        keyboardType: TextInputType.emailAddress,
      );

  Widget _otpStep(dynamic l10n, colors) {
    final pin = PinTheme(
      width: 48,
      height: 56,
      textStyle: AppTextStyles.numberLarge.copyWith(color: colors.textPrimary),
      decoration: BoxDecoration(
        color: colors.bgSurface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: colors.borderStrong),
      ),
    );
    return Center(
      child: Pinput(
        length: 6,
        defaultPinTheme: pin,
        focusedPinTheme: pin.copyBorderWith(
          border: Border.all(color: colors.accent, width: 1.5),
        ),
        autofocus: true,
        keyboardType: TextInputType.number,
        onChanged: (v) => setState(() => _otp = v),
        onCompleted: (v) => setState(() => _otp = v),
      ),
    );
  }

  Widget _resetStep(dynamic l10n) => Column(
        children: [
          AppInput(
            controller: _newPwdCtl,
            label: l10n.recoveryNewPasswordLabel,
            obscure: true,
          ),
          const SizedBox(height: AppSpacing.base),
          AppInput(
            controller: _confirmCtl,
            label: l10n.recoveryConfirmPasswordLabel,
            obscure: true,
          ),
        ],
      );
}

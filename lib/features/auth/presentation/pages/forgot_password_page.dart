import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_button.dart';
import '../../../../core/widgets/bn_text_field.dart';
import '../bloc/auth_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.otpSent) {
            setState(() => _otpSent = true);
            context.showSnackBar('OTP sent to your email');
          } else if (state.status == AuthStatus.magicLinkSent) {
            context.showSnackBar('Magic link sent! Check your email.');
          } else if (state.status == AuthStatus.otpValidated) {
            context.push('/auth/reset-password?token=${state.recoveryToken}');
          } else if (state.status == AuthStatus.error) {
            context.showErrorSnackBar(state.errorMessage ?? 'Something went wrong');
            context.read<AuthBloc>().add(const AuthClearError());
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          return Scaffold(
            backgroundColor: AppColors.bgWhite,
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    const Icon(Icons.lock_reset_rounded, size: 64, color: AppColors.primary),
                    AppSpacing.verticalLg,
                    Text('Forgot Password?', style: AppTextStyles.h2, textAlign: TextAlign.center),
                    AppSpacing.verticalSm,
                    Text(
                      _otpSent
                          ? 'Enter the 6-digit code sent to your email'
                          : "No worries! Enter your email and we'll send you a way to reset it.",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    if (!_otpSent) ...[
                      BnTextField(
                        controller: _emailController,
                        labelText: 'Email Address',
                        hintText: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      ),
                      const SizedBox(height: 32),
                      BnButton(
                        text: 'Send OTP Code',
                        isLoading: isLoading,
                        onPressed: () {
                          final email = _emailController.text.trim();
                          if (email.isEmpty) {
                            context.showErrorSnackBar('Please enter your email');
                            return;
                          }
                          context.read<AuthBloc>().add(AuthInitiateOtpRecovery(email: email));
                        },
                      ),
                      AppSpacing.verticalMd,
                      BnButton(
                        text: 'Send Magic Link Instead',
                        isOutlined: true,
                        onPressed: isLoading
                            ? null
                            : () {
                                final email = _emailController.text.trim();
                                if (email.isEmpty) {
                                  context.showErrorSnackBar('Please enter your email');
                                  return;
                                }
                                context.read<AuthBloc>().add(AuthInitiateMagicLink(email: email));
                              },
                      ),
                    ] else ...[
                      Center(
                        child: Pinput(
                          controller: _otpController,
                          length: AppConstants.otpLength,
                          defaultPinTheme: PinTheme(
                            width: 52,
                            height: 56,
                            textStyle: AppTextStyles.h3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      BnButton(
                        text: 'Verify OTP',
                        isLoading: isLoading,
                        onPressed: () {
                          final otp = _otpController.text.trim();
                          if (otp.length != AppConstants.otpLength) {
                            context.showErrorSnackBar('Please enter the full 6-digit code');
                            return;
                          }
                          context.read<AuthBloc>().add(AuthValidateOtp(
                            email: _emailController.text.trim(),
                            otp: otp,
                          ));
                        },
                      ),
                      AppSpacing.verticalBase,
                      Center(
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(
                                    AuthInitiateOtpRecovery(email: _emailController.text.trim()),
                                  );
                                },
                          child: Text('Resend Code', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

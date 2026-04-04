import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_button.dart';
import '../../../../core/widgets/bn_text_field.dart';
import '../bloc/auth_bloc.dart';

class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({super.key, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.passwordReset) {
            context.showSnackBar('Password reset successfully!');
            context.go('/auth/login');
          } else if (state.status == AuthStatus.error) {
            context.showErrorSnackBar(state.errorMessage ?? 'Failed to reset password');
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
                    const Icon(Icons.lock_outline_rounded, size: 64, color: AppColors.primary),
                    AppSpacing.verticalLg,
                    Text('Set New Password', style: AppTextStyles.h2, textAlign: TextAlign.center),
                    AppSpacing.verticalSm,
                    Text(
                      'Create a strong password for your account.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    BnTextField(
                      controller: _passwordController,
                      labelText: 'New Password',
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
                      controller: _confirmController,
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
                      text: 'Reset Password',
                      isLoading: isLoading,
                      onPressed: () {
                        final password = _passwordController.text;
                        if (password.length < 8) {
                          context.showErrorSnackBar('Password must be at least 8 characters');
                          return;
                        }
                        if (password != _confirmController.text) {
                          context.showErrorSnackBar('Passwords do not match');
                          return;
                        }
                        context.read<AuthBloc>().add(AuthResetPassword(
                          newPassword: password,
                          token: widget.token,
                        ));
                      },
                    ),
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

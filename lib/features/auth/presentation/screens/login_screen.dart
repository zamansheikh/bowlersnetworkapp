import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_input.dart';

/// Placeholder login — replaced in Phase 1 with full auth flow.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl2),
              Text(
                l10n.loginTitle,
                style: AppTextStyles.pageTitle.copyWith(
                  color: colors.textPrimary,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.loginSubtitle,
                style: AppTextStyles.body.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl2),
              AppInput(
                controller: _email,
                label: l10n.loginEmailLabel,
                hint: l10n.loginEmailHint,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(
                  Icons.alternate_email_rounded,
                  size: 18,
                  color: colors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              AppInput(
                controller: _password,
                label: l10n.loginPasswordLabel,
                hint: l10n.loginPasswordHint,
                obscure: _obscure,
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: colors.textTertiary,
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: colors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: colors.accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                  ),
                  child: Text(
                    l10n.loginForgotPassword,
                    style: AppTextStyles.buttonLabel.copyWith(
                      color: colors.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
              AppButton(
                label: l10n.actionLogin,
                onPressed: () {},
                expand: true,
                size: AppButtonSize.large,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.loginNoAccount,
                    style: AppTextStyles.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(foregroundColor: colors.accent),
                    child: Text(
                      l10n.actionSignUp,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

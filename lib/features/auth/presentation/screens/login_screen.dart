import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_input.dart';
import '../../../../core/widgets/bn_logo.dart';
import '../../../../core/widgets/glow_blob.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _credentialCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _credentialCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            credential: _credentialCtl.text.trim(),
            password: _passwordCtl.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AmbientBackground(),
          SafeArea(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xl,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        children: [
                          _BrandHeader()
                              .animate()
                              .fadeIn(duration: 400.ms, curve: BNCurves.spring)
                              .moveY(
                                begin: -8,
                                end: 0,
                                duration: 400.ms,
                                curve: BNCurves.spring,
                              ),
                          const SizedBox(height: AppSpacing.xl),
                          AppCard(
                            translucent: true,
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AuthHeader(
                                    title: l10n.loginTitle,
                                    subtitle: l10n.loginSubtitle,
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  AppInput(
                                    controller: _credentialCtl,
                                    label: l10n.loginEmailLabel,
                                    hint: l10n.loginEmailHint,
                                    large: true,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icon(
                                      LucideIcons.atSign,
                                      size: 18,
                                      color: colors.textTertiary,
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? l10n.loginCredentialRequired
                                            : null,
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  AppInput(
                                    controller: _passwordCtl,
                                    label: l10n.loginPasswordLabel,
                                    hint: l10n.loginPasswordHint,
                                    large: true,
                                    obscure: _obscure,
                                    prefixIcon: Icon(
                                      LucideIcons.lock,
                                      size: 18,
                                      color: colors.textTertiary,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                      icon: Icon(
                                        _obscure
                                            ? LucideIcons.eye
                                            : LucideIcons.eyeOff,
                                        size: 18,
                                        color: colors.textTertiary,
                                      ),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? l10n.loginPasswordRequired
                                        : null,
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => context
                                          .push(RouteNames.passwordRecovery),
                                      style: TextButton.styleFrom(
                                        foregroundColor: colors.accent,
                                        minimumSize: Size.zero,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                      ),
                                      child: Text(
                                        l10n.loginForgotPassword,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: colors.accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (state.errors.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    AuthErrorBanner(messages: state.errors),
                                  ],
                                  const SizedBox(height: AppSpacing.lg),
                                  AppButton(
                                    label: l10n.actionLogin,
                                    onPressed:
                                        state.processing ? null : _submit,
                                    loading: state.processing,
                                    expand: true,
                                    size: AppButtonSize.large,
                                    trailingIcon: state.processing
                                        ? null
                                        : LucideIcons.arrowRight,
                                  ),
                                  const SizedBox(height: AppSpacing.base),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        l10n.loginNoAccount,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            context.push(RouteNames.signup),
                                        style: TextButton.styleFrom(
                                          foregroundColor: colors.accent,
                                        ),
                                        child: Text(
                                          l10n.actionSignUp,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                            color: colors.accent,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const BnBrandLockup(logoSize: 64, fontSize: 16);
  }
}

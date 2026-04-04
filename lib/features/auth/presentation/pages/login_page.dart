import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/asset_paths.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_button.dart';
import '../../../../core/widgets/bn_text_field.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _credentialController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _credentialController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/profile-wizard');
          } else if (state.status == AuthStatus.consentRequired) {
            context.go('/auth/consent-pending');
          } else if (state.status == AuthStatus.error) {
            context.showErrorSnackBar(state.errorMessage ?? 'Login failed');
            context.read<AuthBloc>().add(const AuthClearError());
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.bgWhite,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    // Logo
                    Center(
                      child: SvgPicture.asset(
                        AssetPaths.splashLogo,
                        width: 80,
                        height: 80,
                      ),
                    ),
                    AppSpacing.verticalBase,

                    Text(
                      'Welcome Back',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      'Sign in to your BowlersNetwork account',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    BnTextField(
                      controller: _credentialController,
                      labelText: 'Email or Username',
                      hintText: 'Enter your email or username',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                    ),
                    AppSpacing.verticalBase,

                    BnTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                      ),
                      onSubmitted: (_) => _handleLogin(context),
                    ),
                    AppSpacing.verticalSm,

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/auth/forgot-password'),
                        child: const Text('Forgot Password?'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    BnButton(
                      text: 'Sign In',
                      onPressed: () => _handleLogin(context),
                      isLoading: state.status == AuthStatus.loading,
                    ),

                    const SizedBox(height: 32),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/auth/signup'),
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    final credential = _credentialController.text.trim();
    final password = _passwordController.text;

    if (credential.isEmpty || password.isEmpty) {
      context.showErrorSnackBar('Please enter your credentials');
      return;
    }

    context.read<AuthBloc>().add(AuthLoginRequested(
      credential: credential,
      password: password,
    ));
  }
}

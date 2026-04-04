import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_button.dart';
import '../bloc/auth_bloc.dart';

class ConsentPendingPage extends StatelessWidget {
  const ConsentPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.consentResent) {
            context.showSnackBar('Consent email resent!');
          } else if (state.status == AuthStatus.error) {
            context.showErrorSnackBar(state.errorMessage ?? 'Failed to resend');
            context.read<AuthBloc>().add(const AuthClearError());
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          return Scaffold(
            backgroundColor: AppColors.bgWhite,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.family_restroom_rounded, size: 80, color: AppColors.primary),
                    AppSpacing.verticalXl,
                    Text(
                      'Waiting for Parent Approval',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.verticalMd,
                    Text(
                      "We've sent a consent email to your parent or guardian. "
                      "Once they approve, you'll be able to use BowlersNetwork!",
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    BnButton(
                      text: 'Resend Consent Email',
                      isOutlined: true,
                      isLoading: isLoading,
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthResendConsent());
                      },
                    ),
                    AppSpacing.verticalMd,
                    BnButton(
                      text: 'Back to Login',
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthLogoutRequested());
                        context.go('/auth/login');
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

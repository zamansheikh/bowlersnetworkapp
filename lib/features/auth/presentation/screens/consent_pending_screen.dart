import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';

class ConsentPendingScreen extends StatelessWidget {
  const ConsentPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.accent.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    LucideIcons.users,
                    size: 48,
                    color: colors.accent,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.96, 0.96),
                      end: const Offset(1.04, 1.04),
                      duration: 1400.ms,
                      curve: Curves.easeInOut,
                    ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.consentPendingTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.pageTitle.copyWith(
                  color: colors.textPrimary,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.consentPendingDescription,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
              const Spacer(flex: 2),
              AppButton(
                label: l10n.consentPendingRefresh,
                icon: LucideIcons.refreshCw,
                expand: true,
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthStarted());
                },
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.actionLogout,
                variant: AppButtonVariant.ghost,
                expand: true,
                onPressed: () => context
                    .read<AuthBloc>()
                    .add(const AuthLogoutRequested()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

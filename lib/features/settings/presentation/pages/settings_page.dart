import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../home/data/models/user_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final isDeleting = state is AuthLoading;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: AppColors.white,
                elevation: 0,
                scrolledUnderElevation: 1,
                surfaceTintColor: AppColors.white,
                leadingWidth: 72,
                leading: Padding(
                  padding: EdgeInsets.only(left: AppSpacing.md),
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 20,
                        color: AppColors.gray700,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Settings',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      // App Section
                      _buildSectionCard(
                        title: 'App',
                        children: [
                          _buildSettingsItem(
                            icon: Icons.security_outlined,
                            title: 'Privacy Policy',
                            subtitle: 'View our privacy policy',
                            onTap: () => _launchPrivacyPolicy(),
                          ),
                          const Divider(height: 1, color: AppColors.border),
                          _buildSettingsItem(
                            icon: Icons.shield,
                            title: 'Safety Center',
                            subtitle: 'Safety tips and report concerns',
                            onTap: () => context.push('/help-center'),
                          ),
                          const Divider(height: 1, color: AppColors.border),
                          _buildSettingsItem(
                            icon: Icons.help_outline,
                            title: 'Help & Support',
                            subtitle: 'Get help and contact support',
                            onTap: () => _launchSupport(),
                          ),
                        ],
                      ),

                      SizedBox(height: AppSpacing.lg),

                      // Danger Zone Section
                      _buildSectionCard(
                        title: 'Danger Zone',
                        children: [
                          _buildSettingsItem(
                            icon: Icons.delete_forever_outlined,
                            title: 'Delete Account',
                            subtitle:
                                'Permanently delete your account and all data',
                            onTap: () => _showDeleteAccountDialog(context),
                            iconColor: AppColors.error,
                            titleColor: AppColors.error,
                            showArrow: false,
                          ),
                        ],
                      ),

                      const Spacer(),

                      // App Version
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSM,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.gray500,
                              size: 20,
                            ),
                            SizedBox(width: AppSpacing.sm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bowlers Network',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.gray800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Version 1.0.0',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.gray600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Loading overlay during account deletion
            if (isDeleting)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primaryLimeGreen,
                        ),
                        SizedBox(height: AppSpacing.md),
                        Text(
                          'Deleting Account...',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.gray900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'Please wait while we delete your account\nand all associated data.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSpacing.elevationSM,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryLimeGreen).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primaryLimeGreen,
                size: 20,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: titleColor ?? AppColors.gray900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(Icons.arrow_forward_ios, color: AppColors.gray400, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse(
      'https://zamansheikh.github.io/bowlersnetworkapp/privacy-policy.html',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch privacy policy URL');
    }
  }

  Future<void> _launchSupport() async {
    final Uri emailUrl = Uri.parse('mailto:support@bowlersnetwork.com');
    if (!await launchUrl(emailUrl)) {
      debugPrint('Could not launch email client');
    }
  }

  void _showDeleteAccountDialog(BuildContext context) {
    _showWarningDialog(context);
  }

  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: AppColors.error,
                size: 28,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Delete Account',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account?',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.gray900,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This action cannot be undone. This will permanently:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    ...([
                      'Delete your profile and all personal information',
                      'Remove all your posts, comments, and interactions',
                      'Delete all your bowling statistics and game history',
                      'Cancel your team memberships and tournament registrations',
                      'Remove all your photos, videos, and media content',
                      'Delete all your messages and conversation history',
                      'Remove all notifications and preferences',
                    ]).map(
                      (item) => Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.button.copyWith(color: AppColors.gray600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showPasswordConfirmationDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                ),
              ),
              child: Text(
                'Continue',
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPasswordConfirmationDialog(BuildContext context) {
    // Get username from auth state
    final authState = context.read<AuthCubit>().state;
    String username = '';

    if (authState is Authenticated && authState.user is UserModel) {
      username = (authState.user as UserModel).username;
    }

    final TextEditingController usernameController = TextEditingController(
      text: username,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
          ),
          title: Row(
            children: [
              Icon(Icons.person_outline, color: AppColors.error, size: 28),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Confirm Username',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please confirm your username to proceed with account deletion:',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.gray900,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              TextField(
                controller: usernameController,
                enabled: false, // Make it uneditable
                decoration: InputDecoration(
                  hintText: 'Username',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: AppColors.gray500,
                  ),
                  filled: true,
                  fillColor: AppColors.gray100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSM),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.button.copyWith(color: AppColors.gray600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (usernameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Username is required'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop();
                _showFinalDeleteAccountDialog(context, usernameController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                ),
              ),
              child: Text(
                'Confirm',
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFinalDeleteAccountDialog(BuildContext context, String username) {
    // Trigger account deletion immediately with username
    context.read<AuthCubit>().deleteAccount(username);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AccountDeleted) {
              // Close dialog first
              Navigator.of(dialogContext).pop();

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account deleted successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );

              // Navigate to signin after a brief delay
              Future.delayed(const Duration(milliseconds: 500), () {
                context.go('/signin');
              });
            } else if (state is AuthError) {
              // Close dialog first
              Navigator.of(dialogContext).pop();
              // Show error message on settings page
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to delete account: ${state.message}'),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: AppColors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              ),
              title: Row(
                children: [
                  Icon(Icons.delete_forever, color: AppColors.error, size: 28),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    'Deleting Account',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account deletion in progress...',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.gray900,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Please wait while we securely delete your account and all associated data.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  if (isLoading) ...[
                    SizedBox(height: AppSpacing.md),
                    Center(
                      child: CircularProgressIndicator(color: AppColors.error),
                    ),
                  ],
                ],
              ),
              actions: isLoading
                  ? null
                  : [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.gray600,
                          ),
                        ),
                      ),
                    ],
            );
          },
        );
      },
    );
  }
}

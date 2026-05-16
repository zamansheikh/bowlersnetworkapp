import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/widgets/app_back_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../notifications/domain/entities/notification_preferences.dart';
import '../bloc/settings_bloc.dart';

/// /settings — mirrors the web settings page on a single mobile screen:
/// Appearance (theme), Notifications (9 toggles backed by
/// `/api/notifications/preferences`), Account (placeholder rows for
/// change-username / change-email — those flows live in their own
/// follow-up features), and About (version + sign-out).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (_) => getIt<SettingsBloc>()
        ..add(const SettingsLoadRequested()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const AppBackButton(),
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
        listener: (context, state) {
          showAppToast(
            context,
            message: state.errors.join('\n'),
            variant: ToastVariant.error,
          );
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.base,
            AppSpacing.xl2,
          ),
          children: const [
            _AppearanceSection(),
            SizedBox(height: AppSpacing.md),
            _NotificationsSection(),
            SizedBox(height: AppSpacing.md),
            _AccountSection(),
            SizedBox(height: AppSpacing.md),
            _AboutSection(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Appearance — theme picker
// ─────────────────────────────────────────────────────────────────────────────
class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: LucideIcons.palette,
      title: 'Appearance',
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return Column(
            children: [
              for (final option in const [
                (ThemeMode.system, LucideIcons.monitor, 'System'),
                (ThemeMode.light, LucideIcons.sun, 'Light'),
                (ThemeMode.dark, LucideIcons.moon, 'Dark'),
              ])
                _RadioRow(
                  icon: option.$2,
                  label: option.$3,
                  selected: mode == option.$1,
                  onTap: () => context
                      .read<ThemeCubit>()
                      .setThemeMode(option.$1),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifications — 9 backend toggles
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        final prefs = state.preferences;
        return _SectionCard(
          icon: LucideIcons.bell,
          title: 'Notifications',
          child: state.loading && prefs == null
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : prefs == null
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        "Couldn't load preferences. Pull to retry from above.",
                      ),
                    )
                  : Column(
                      children: [
                        for (final kind in NotificationKind.values)
                          _ToggleRow(
                            label: kind.label,
                            value: prefs.valueOf(kind),
                            busy: state.isBusy(kind),
                            onChanged: (_) => context
                                .read<SettingsBloc>()
                                .add(SettingsPreferenceToggled(kind)),
                          ),
                      ],
                    ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account — change username, change email, password reset
// ─────────────────────────────────────────────────────────────────────────────
class _AccountSection extends StatelessWidget {
  const _AccountSection();

  Future<void> _openPasswordReset(BuildContext context) async {
    // Reuses the web's recovery portal — opening the email-link flow
    // natively needs its own screen which is a separate feature.
    const url = 'https://bowlersnetwork.com/password-recovery';
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      showAppToast(
        context,
        message: "Couldn't open password reset.",
        variant: ToastVariant.error,
      );
    }
  }

  void _comingSoon(BuildContext context, String label) {
    showAppToast(
      context,
      message: '$label is coming soon.',
      variant: ToastVariant.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: LucideIcons.user,
      title: 'Account',
      child: Column(
        children: [
          _ActionRow(
            icon: LucideIcons.atSign,
            label: 'Change username',
            onTap: () => _comingSoon(context, 'Changing your username'),
          ),
          _ActionRow(
            icon: LucideIcons.mail,
            label: 'Change email',
            onTap: () => _comingSoon(context, 'Changing your email'),
          ),
          _ActionRow(
            icon: LucideIcons.keyRound,
            label: 'Reset password',
            onTap: () => _openPasswordReset(context),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// About — version + sign out
// ─────────────────────────────────────────────────────────────────────────────
class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _SectionCard(
      icon: LucideIcons.info,
      title: 'About',
      child: Column(
        children: [
          _ActionRow(
            icon: LucideIcons.tag,
            label: 'Version',
            trailingText: _versionLabel,
            onTap: null,
          ),
          _ActionRow(
            icon: LucideIcons.logOut,
            label: 'Sign out',
            destructive: true,
            onTap: () => context
                .read<AuthBloc>()
                .add(const AuthLogoutRequested()),
          ),
          const SizedBox(height: AppSpacing.sm),
          Center(
            child: Text(
              '${AppConstants.appName} • ${AppConstants.appTagline}',
              style: AppTextStyles.nano.copyWith(color: colors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }

  /// Pulled from pubspec.yaml `version: 1.0.5+7` — kept in sync manually
  /// (package_info_plus isn't installed yet).
  static const String _versionLabel = 'v1.0.5 (7)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Section + row primitives
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: colors.accent),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.label
                    .copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 16, color: colors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              selected
                  ? LucideIcons.circleCheck
                  : LucideIcons.circle,
              size: 18,
              color: selected ? colors.accent : colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.busy,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: busy ? null : onChanged,
            activeThumbColor: colors.accent,
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailingText,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? trailingText;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = destructive ? colors.error : colors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(icon,
                size: 16, color: destructive ? colors.error : colors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: colors.textTertiary,
                ),
              )
            else if (onTap != null)
              Icon(
                LucideIcons.chevronRight,
                size: 14,
                color: colors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

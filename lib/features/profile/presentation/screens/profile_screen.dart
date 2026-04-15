import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../core/widgets/user_chip.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<ProfileBloc>();
      if (bloc.state.profile == null && !bloc.state.loading) {
        bloc.add(const ProfileLoadRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.navProfile),
        actions: [
          IconButton(
            tooltip: l10n.actionLogout,
            icon: const Icon(Icons.logout_rounded),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<ProfileBloc>().add(const ProfileLoadRequested());
          },
          color: colors.accent,
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state.loading && state.profile == null) {
                return _loading();
              }
              if (state.profile == null) {
                return EmptyState(
                  icon: Icons.person_outline_rounded,
                  title: l10n.commonSomethingWentWrong,
                  hint: state.errors.isNotEmpty
                      ? state.errors.join('\n')
                      : null,
                  action: AppButton(
                    label: l10n.actionRetry,
                    onPressed: () => context
                        .read<ProfileBloc>()
                        .add(const ProfileLoadRequested()),
                  ),
                );
              }

              final profile = state.profile!;
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.base),
                children: [
                  if (!state.isComplete)
                    _CompletionBanner(percent: state.completionPercentage),
                  const SizedBox(height: AppSpacing.base),
                  UserChip(
                    username: profile.user.username,
                    displayName: profile.user.displayName,
                    avatarUrl: profile.profilePictureUrl,
                    size: UserChipSize.large,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: l10n.profileFollowers,
                          value: profile.followerCount,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StatCard(
                          label: l10n.profileFollowing,
                          value: profile.followingCount,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _loading() => ListView(
        padding: const EdgeInsets.all(AppSpacing.base),
        children: const [
          SkeletonBox(height: 96),
          SizedBox(height: AppSpacing.base),
          SkeletonBox(height: 72),
          SizedBox(height: AppSpacing.base),
          SkeletonBox(height: 88),
        ],
      );
}

class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return AppCard(
      showCornerOrb: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileCompletionBannerTitle,
            style: AppTextStyles.cardTitle.copyWith(color: colors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.profileCompletionBannerHint(percent),
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: AppRadius.fullAll,
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: colors.bgSurfaceHover,
              valueColor: AlwaysStoppedAnimation(colors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: AppTextStyles.numberLarge.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.label.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

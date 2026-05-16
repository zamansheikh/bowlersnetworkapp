import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../follow/domain/repositories/follow_repository.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../bloc/other_profile_bloc.dart';
import '../widgets/cards_tab.dart';
import '../widgets/info_tab.dart';
import '../widgets/media_tab.dart';
import '../widgets/posts_tab.dart';
import '../widgets/profile_hero.dart';
import '../widgets/profile_tab_bar.dart';

/// Read-only profile screen for users OTHER than the logged-in user.
///
/// Same layout as the self profile (hero + stats + tabs) but stripped of
/// edit / upload / logout / completion-banner UI, and with a Follow /
/// Following action button instead of Edit Profile.
class OtherProfileScreen extends StatelessWidget {
  const OtherProfileScreen({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OtherProfileBloc>(
      create: (_) => OtherProfileBloc(
        profileRepository: getIt<ProfileRepository>(),
        followRepository: getIt<FollowRepository>(),
        username: username,
      )..add(const OtherProfileLoadRequested()),
      child: _OtherProfileView(username: username),
    );
  }
}

class _OtherProfileView extends StatefulWidget {
  const _OtherProfileView({required this.username});
  final String username;

  @override
  State<_OtherProfileView> createState() => _OtherProfileViewState();
}

class _OtherProfileViewState extends State<_OtherProfileView> {
  ProfileTab _activeTab = ProfileTab.info;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocConsumer<OtherProfileBloc, OtherProfileState>(
          listenWhen: (p, n) => p.errors != n.errors && n.errors.isNotEmpty,
          listener: (context, state) {
            showAppToast(
              context,
              message: state.errors.join('\n'),
              variant: ToastVariant.error,
            );
          },
          builder: (context, state) {
            if (state.loading && state.profile == null) {
              return const _OtherProfileSkeleton();
            }
            if (state.profile == null) {
              return _OtherProfileError(
                username: widget.username,
                errors: state.errors,
                onRetry: () => context
                    .read<OtherProfileBloc>()
                    .add(const OtherProfileLoadRequested()),
              );
            }
            final profile = state.profile!;
            return RefreshIndicator(
              color: colors.accent,
              onRefresh: () async {
                context
                    .read<OtherProfileBloc>()
                    .add(const OtherProfileLoadRequested());
                await context
                    .read<OtherProfileBloc>()
                    .stream
                    .firstWhere((s) => !s.loading);
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ProfileHero(
                          profile: profile,
                          isSelf: false,
                          onToggleFollow: state.followBusy
                              ? null
                              : () => context
                                  .read<OtherProfileBloc>()
                                  .add(const OtherProfileFollowToggled()),
                        ),
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 4,
                          left: AppSpacing.base,
                          child: const _GlassBackButton(),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.base,
                        AppSpacing.base,
                        AppSpacing.base,
                        AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: profile.isFollowing == true
                                  ? 'Following'
                                  : 'Follow',
                              variant: profile.isFollowing == true
                                  ? AppButtonVariant.secondary
                                  : AppButtonVariant.primary,
                              size: AppButtonSize.regular,
                              icon: profile.isFollowing == true
                                  ? LucideIcons.userCheck
                                  : LucideIcons.userPlus,
                              expand: true,
                              loading: state.followBusy,
                              onPressed: profile.canFollow == false
                                  ? null
                                  : () => context
                                      .read<OtherProfileBloc>()
                                      .add(const OtherProfileFollowToggled()),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          _SecondaryIconButton(
                            icon: LucideIcons.messageSquare,
                            tooltip: 'Message',
                            onTap: () => _messageNotImplemented(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                      ),
                      child: _StatsRow(profile: profile)
                          .animate()
                          .fadeIn(
                            delay: 60.ms,
                            duration: 300.ms,
                            curve: BNCurves.spring,
                          )
                          .moveY(
                            begin: 8,
                            end: 0,
                            delay: 60.ms,
                            duration: 300.ms,
                            curve: BNCurves.spring,
                          ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: ProfileStickyTabsDelegate(
                      active: _activeTab,
                      onChanged: (t) => setState(() => _activeTab = t),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.base,
                      AppSpacing.xl2,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: AnimatedSwitcher(
                        duration: AppDurations.short,
                        switchInCurve: BNCurves.spring,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: child,
                        ),
                        child: KeyedSubtree(
                          key: ValueKey(_activeTab),
                          child: _tabContent(profile),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tabContent(Profile profile) {
    final tabBoxHeight = MediaQuery.sizeOf(context).height * 0.75;
    switch (_activeTab) {
      case ProfileTab.info:
        return ProfileInfoTab(profile: profile, isSelf: false);
      case ProfileTab.posts:
        return SizedBox(
          height: tabBoxHeight,
          child: PostsTab(userId: profile.user.id, isSelf: false),
        );
      case ProfileTab.media:
        return SizedBox(
          height: tabBoxHeight,
          child: MediaTab(username: profile.user.username),
        );
      case ProfileTab.cards:
        return SizedBox(
          height: tabBoxHeight,
          child: CardsTab(userId: profile.user.id, isSelf: false),
        );
    }
  }

  void _messageNotImplemented(BuildContext context) {
    showAppToast(
      context,
      message: 'Direct messaging from a profile is coming soon.',
      variant: ToastVariant.info,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SecondaryIconButton extends StatelessWidget {
  const _SecondaryIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.08),
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: colors.accent.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: colors.accent),
          ),
        ),
      ),
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          alignment: Alignment.center,
          child: const Icon(LucideIcons.arrowLeft, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: LucideIcons.users,
            label: l10n.profileFollowers,
            value: profile.followerCount,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            icon: LucideIcons.heart,
            label: l10n.profileFollowing,
            value: profile.followingCount,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.accent),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$value',
            style: AppTextStyles.numberLarge.copyWith(
              color: colors.textPrimary,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: AppTextStyles.label.copyWith(color: colors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _OtherProfileSkeleton extends StatelessWidget {
  const _OtherProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const [
        SkeletonBox(height: 240, borderRadius: BorderRadius.zero),
        Padding(
          padding: EdgeInsets.all(AppSpacing.base),
          child: Column(
            children: [
              SkeletonBox(height: 44),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 96),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 200),
            ],
          ),
        ),
      ],
    );
  }
}

class _OtherProfileError extends StatelessWidget {
  const _OtherProfileError({
    required this.username,
    required this.errors,
    required this.onRetry,
  });

  final String username;
  final List<String> errors;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: IconButton(
              icon: const Icon(LucideIcons.arrowLeft),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Center(
            child: EmptyState(
              icon: LucideIcons.userX,
              title: errors.any((e) => e.toLowerCase().contains('not found'))
                  ? '@$username not found'
                  : l10n.commonSomethingWentWrong,
              hint: errors.isNotEmpty ? errors.join('\n') : null,
              action: AppButton(label: l10n.actionRetry, onPressed: onRetry),
            ),
          ),
        ],
      ),
    );
  }
}

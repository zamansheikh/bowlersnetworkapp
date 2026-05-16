import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/profile.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/cards_tab.dart';
import '../widgets/favorite_brands_card.dart';
import '../widgets/info_tab.dart';
import '../widgets/media_tab.dart';
import '../widgets/posts_tab.dart';
import '../widgets/profile_hero.dart';
import '../widgets/profile_tab_bar.dart';
import '../widgets/xp_rank_card.dart';

/// Production profile screen.
///
/// Uses a single [CustomScrollView] — NOT [NestedScrollView] — to avoid the
/// `layoutExtent > paintExtent` rendering error that happens when an inner
/// TabBarView can't settle its height. The tab bar pins via
/// [SliverPersistentHeader] and the active tab renders below.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileTab _activeTab = ProfileTab.info;

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

  Future<void> _pickAvatar() async {
    final picked = await getIt<ImagePickerService>().pickImage();
    if (picked == null || !mounted) return;
    context.read<ProfileBloc>().add(
      ProfileAvatarUploadRequested(bytes: picked.bytes, fileName: picked.name),
    );
  }

  Future<void> _pickCover() async {
    final picked = await getIt<ImagePickerService>().pickImage();
    if (picked == null || !mounted) return;
    context.read<ProfileBloc>().add(
      ProfileCoverUploadRequested(bytes: picked.bytes, fileName: picked.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: SafeArea(
        top: false,
        bottom: false,
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.loading && state.profile == null) {
              return const _ProfileSkeleton();
            }
            if (state.profile == null) {
              return _ErrorState(
                errors: state.errors,
                onRetry: () => context.read<ProfileBloc>().add(
                  const ProfileLoadRequested(),
                ),
              );
            }

            final profile = state.profile!;
            return RefreshIndicator(
              color: colors.accent,
              onRefresh: () async {
                context.read<ProfileBloc>().add(const ProfileLoadRequested());
                await context.read<ProfileBloc>().stream.firstWhere(
                  (s) => !s.loading,
                );
              },
              child: CustomScrollView(
                slivers: [
                  // ── Hero (cover + avatar + name) ──
                  SliverToBoxAdapter(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ProfileHero(
                          profile: profile,
                          isSelf: true,
                          onEditAvatar: _pickAvatar,
                          onEditCover: _pickCover,
                          uploadingAvatar: state.uploadingAvatar,
                          uploadingCover: state.uploadingCover,
                        ),
                        Positioned(
                          top: MediaQuery.paddingOf(context).top + 4,
                          right: AppSpacing.base,
                          child: _LogoutButton(
                            tooltip: l10n.actionLogout,
                            onTap: () => context.read<AuthBloc>().add(
                              const AuthLogoutRequested(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── Edit Profile action row ──
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
                              label: 'Edit Profile',
                              variant: AppButtonVariant.secondary,
                              size: AppButtonSize.regular,
                              icon: LucideIcons.pencil,
                              expand: true,
                              onPressed: () => context.push('/profile/edit'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          _SecondaryIconButton(
                            icon: LucideIcons.settings,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── Completion banner + XP + stats ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base,
                      ),
                      child: Column(
                        children: [
                          if (!profile.isComplete) ...[
                            _CompletionBanner(
                                  percent: profile.completionPercentage,
                                )
                                .animate()
                                .fadeIn(duration: 300.ms)
                                .moveY(begin: 8, end: 0),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          if (state.xp != null) ...[
                            XpRankCard(xp: state.xp!)
                                .animate()
                                .fadeIn(
                                  duration: 300.ms,
                                  delay: 40.ms,
                                  curve: BNCurves.spring,
                                )
                                .moveY(
                                  begin: 8,
                                  end: 0,
                                  duration: 300.ms,
                                  delay: 40.ms,
                                  curve: BNCurves.spring,
                                ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          _StatsRow(profile: profile)
                              .animate()
                              .fadeIn(
                                delay: 80.ms,
                                duration: 300.ms,
                                curve: BNCurves.spring,
                              )
                              .moveY(
                                begin: 8,
                                end: 0,
                                delay: 80.ms,
                                duration: 300.ms,
                                curve: BNCurves.spring,
                              ),
                          const SizedBox(height: AppSpacing.md),
                          FavoriteBrandsCard(
                                brands: state.favoriteBrands,
                                onBrowse: () {},
                              )
                              .animate()
                              .fadeIn(
                                delay: 120.ms,
                                duration: 300.ms,
                                curve: BNCurves.spring,
                              )
                              .moveY(
                                begin: 8,
                                end: 0,
                                delay: 120.ms,
                                duration: 300.ms,
                                curve: BNCurves.spring,
                              ),
                        ],
                      ),
                    ),
                  ),
                  // ── Sticky tab bar ──
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: ProfileStickyTabsDelegate(
                      active: _activeTab,
                      onChanged: (t) => setState(() => _activeTab = t),
                    ),
                  ),
                  // ── Active tab content ──
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
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
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
    // Each non-info tab owns its own ScrollController, so we hand them a
    // bounded box to live in. The outer CustomScrollView covers the hero /
    // stats; once the user has scrolled to the tabs, the inner tab takes
    // over its own scroll.
    final tabBoxHeight = MediaQuery.sizeOf(context).height * 0.75;
    switch (_activeTab) {
      case ProfileTab.info:
        return ProfileInfoTab(profile: profile, isSelf: true);
      case ProfileTab.posts:
        return SizedBox(
          height: tabBoxHeight,
          child: PostsTab(userId: profile.user.id, isSelf: true),
        );
      case ProfileTab.media:
        return SizedBox(
          height: tabBoxHeight,
          child: MediaTab(username: profile.user.username),
        );
      case ProfileTab.cards:
        return SizedBox(
          height: tabBoxHeight,
          child: CardsTab(userId: profile.user.id, isSelf: true),
        );
    }
  }
}

class _SecondaryIconButton extends StatelessWidget {
  const _SecondaryIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
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
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.tooltip, required this.onTap});
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: AppRadius.mdAll,
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            alignment: Alignment.center,
            child: const Icon(
              LucideIcons.logOut,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
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
      padding: const EdgeInsets.all(AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.15),
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: Icon(LucideIcons.info, size: 16, color: colors.warning),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.profileCompletionBannerTitle,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: AppTextStyles.numberLarge.copyWith(
                  color: colors.warning,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
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
              valueColor: AlwaysStoppedAnimation(colors.warning),
            ),
          ),
        ],
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

// ─────────────────────────────────────────────────────────────────────────────
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

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
              SkeletonBox(height: 88),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 96),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 72),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 120),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 200),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.errors, required this.onRetry});

  final List<String> errors;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: EmptyState(
        icon: LucideIcons.user,
        title: l10n.commonSomethingWentWrong,
        hint: errors.isNotEmpty ? errors.join('\n') : null,
        action: AppButton(label: l10n.actionRetry, onPressed: onRetry),
      ),
    );
  }
}

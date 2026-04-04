import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_avatar.dart';
import '../../../../core/widgets/bn_error_widget.dart';
import '../../../../core/widgets/bn_loading_indicator.dart';
import '../../data/models/profile_models.dart';
import '../bloc/profile_bloc.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> with TickerProviderStateMixin {
  late final ProfileBloc _bloc;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _bloc = getIt<ProfileBloc>()..add(const ProfileLoadRequested());
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _bloc.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColors.bgWhite,
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state.status == ProfileStatus.loading) {
              return const Center(child: BnLoadingIndicator());
            }
            if (state.status == ProfileStatus.error) {
              return BnErrorWidget(
                message: state.errorMessage ?? 'Failed to load profile',
                onRetry: () => _bloc.add(const ProfileLoadRequested()),
              );
            }
            final profile = state.profile;
            if (profile == null) return const Center(child: BnLoadingIndicator());

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // Cover + avatar + info — all in one sliver
                  SliverToBoxAdapter(
                    child: _ProfileHeader(profile: profile),
                  ),
                  // Sticky tab bar
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    sliver: SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyTabDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textMuted,
                          indicatorColor: AppColors.primary,
                          indicatorWeight: 2.5,
                          labelStyle: AppTextStyles.labelMedium,
                          unselectedLabelStyle: AppTextStyles.bodySmall,
                          dividerColor: AppColors.borderLight,
                          tabs: const [
                            Tab(text: 'Info'),
                            Tab(text: 'Stats'),
                            Tab(text: 'Posts'),
                            Tab(text: 'Media'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _InfoTab(profile: profile),
                  _StatsTab(profile: profile),
                  _PlaceholderTab(label: 'Posts', icon: Icons.dynamic_feed_outlined),
                  _PlaceholderTab(label: 'Media', icon: Icons.photo_library_outlined),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Profile Header (cover + avatar + info card)
// ══════════════════════════════════════════════════════════

class _ProfileHeader extends StatelessWidget {
  final ProfileModel profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final user = profile.user;
    final media = profile.profileMedia;
    final coverUrl = media?.coverPictureUrl;
    final hasCover = coverUrl != null && !coverUrl.contains('defaults/');
    final picUrl = media?.profilePictureUrl;
    final hasAvatar = picUrl != null && !picUrl.contains('defaults/');
    final nickname = profile.nickname?.name;
    final bio = profile.bio?.content;
    final center = profile.homeCenter?.centerName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Cover photo ──
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: hasCover
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF8BC342), Color(0xFF5B9A26)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
              ),
              child: hasCover
                  ? CachedNetworkImage(imageUrl: coverUrl, fit: BoxFit.cover, width: double.infinity)
                  : null,
            ),
            // Settings button
            Positioned(
              top: MediaQuery.paddingOf(context).top + 8,
              right: 12,
              child: _CircleBtn(icon: Icons.settings_outlined, onTap: () {}),
            ),
          ],
        ),

        // ── Avatar + name + edit row ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar overlapping cover
              Transform.translate(
                offset: const Offset(0, -32),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bgWhite, width: 4),
                  ),
                  child: BnAvatar(
                    imageUrl: hasAvatar ? picUrl : null,
                    name: '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                    size: 80,
                  ),
                ),
              ),
              const Spacer(),
              // Edit button
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderLight),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Edit Profile', style: AppTextStyles.buttonSmall.copyWith(color: AppColors.textPrimary)),
                ),
              ),
            ],
          ),
        ),

        // ── Name, username, nickname ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Transform.translate(
            offset: const Offset(0, -20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                        style: AppTextStyles.h3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user?.isPro == true) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, size: 18, color: AppColors.navActive),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text('@${user?.username ?? ''}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
                if (nickname != null && nickname.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('"$nickname"', style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic, color: AppColors.textTertiary)),
                ],
                if (bio != null && bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(bio, style: AppTextStyles.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
                if (center != null && center.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(center, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                // Stats
                Row(
                  children: [
                    _StatChip(count: profile.followerCount ?? 0, label: 'Followers'),
                    const SizedBox(width: 20),
                    _StatChip(count: profile.followingCount ?? 0, label: 'Following'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.35)),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final int count;
  final String label;
  const _StatChip({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$count', style: AppTextStyles.labelLarge),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════
// Tabs
// ══════════════════════════════════════════════════════════

class _InfoTab extends StatelessWidget {
  final ProfileModel profile;
  const _InfoTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          slivers: [
            SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList.list(
                children: [
                  if (profile.gender?.value case final v? when v.isNotEmpty)
                    _InfoTile(icon: Icons.person_outline_rounded, label: 'Gender', value: v),
                  if (profile.birthdate?.age case final age? when age > 0)
                    _InfoTile(icon: Icons.cake_outlined, label: 'Age', value: '$age years old'),
                  if (profile.homeCenter?.centerName case final c? when c.isNotEmpty)
                    _InfoTile(icon: Icons.place_outlined, label: 'Home Center', value: c),
                  if (profile.ballHandlingStyle case final s? when (s.handedness ?? '').isNotEmpty)
                    _InfoTile(
                      icon: Icons.sports_rounded,
                      label: 'Style',
                      value: [s.handedness, s.ballCarry, s.grip].where((e) => e != null && e.isNotEmpty).join(' · '),
                    ),
                  if (profile.address?.location?.address case final a? when a.isNotEmpty)
                    _InfoTile(icon: Icons.location_on_outlined, label: 'Location', value: a),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final ProfileModel profile;
  const _StatsTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    final stats = profile.officialGameStat;
    if (stats == null || !stats.isAdded) return const _PlaceholderTab(label: 'Stats', icon: Icons.analytics_outlined);

    return Builder(
      builder: (context) {
        return CustomScrollView(
          slivers: [
            SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'Average', value: stats.average?.toStringAsFixed(1) ?? '-', accent: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'High Game', value: stats.highGame?.toString() ?? '-', accent: AppColors.navActive)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'High Series', value: stats.highSeries?.toString() ?? '-', accent: AppColors.warning)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(label: 'Experience', value: '${stats.experience ?? 0}y', accent: AppColors.info)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _StatCard({required this.label, required this.value, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h2.copyWith(color: accent)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String label;
  final IconData icon;
  const _PlaceholderTab({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return CustomScrollView(
          slivers: [
            SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 56, color: AppColors.textMuted.withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text('No $label yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
// Sticky tab bar delegate
// ══════════════════════════════════════════════════════════

class _StickyTabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _StickyTabDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.bgWhite, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _StickyTabDelegate oldDelegate) => false;
}

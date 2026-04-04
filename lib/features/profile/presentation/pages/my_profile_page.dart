import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_spacing.dart';
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

class _MyProfilePageState extends State<MyProfilePage> with SingleTickerProviderStateMixin {
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
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.status == ProfileStatus.loading) {
            return const Scaffold(body: Center(child: BnLoadingIndicator()));
          }
          if (state.status == ProfileStatus.error) {
            return Scaffold(body: BnErrorWidget(
              message: state.errorMessage ?? 'Failed to load profile',
              onRetry: () => _bloc.add(const ProfileLoadRequested()),
            ));
          }
          final profile = state.profile;
          if (profile == null) return const Scaffold(body: BnLoadingIndicator());

          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (_, _) => [
                _buildSliverHeader(profile),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textMuted,
                      indicatorColor: AppColors.primary,
                      indicatorWeight: 3,
                      tabs: const [
                        Tab(text: 'Info'),
                        Tab(text: 'Stats'),
                        Tab(text: 'Posts'),
                        Tab(text: 'Media'),
                      ],
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildInfoTab(profile),
                  _buildStatsTab(profile),
                  _buildPostsTab(),
                  _buildMediaTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverHeader(ProfileModel profile) {
    final user = profile.user;
    final media = profile.profileMedia;
    final coverUrl = media?.coverPictureUrl;
    final picUrl = media?.profilePictureUrl;
    final hasCover = coverUrl != null && !coverUrl.contains('defaults/');

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.bgWhite,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover photo
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: hasCover
                    ? null
                    : const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                image: hasCover
                    ? DecorationImage(image: NetworkImage(coverUrl), fit: BoxFit.cover)
                    : null,
              ),
            ),

            // Profile info overlay
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                color: AppColors.bgWhite,
                padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                                    style: AppTextStyles.h3,
                                  ),
                                  if (user?.isPro == true) ...[
                                    AppSpacing.horizontalXs,
                                    const Icon(Icons.verified, size: 20, color: AppColors.navActive),
                                  ],
                                ],
                              ),
                              Text('@${user?.username ?? ''}', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.borderMedium),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.verticalMd,
                    // Stats row
                    Row(
                      children: [
                        _statItem('${profile.followerCount ?? 0}', 'Followers'),
                        const SizedBox(width: 24),
                        _statItem('${profile.followingCount ?? 0}', 'Following'),
                        const SizedBox(width: 24),
                        _statItem('${profile.completionPercentage ?? 0}%', 'Complete'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Avatar
            Positioned(
              bottom: 80, left: 16,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgWhite, width: 4),
                ),
                child: BnAvatar(
                  imageUrl: picUrl != null && !picUrl.contains('defaults/') ? picUrl : null,
                  name: '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim(),
                  size: 80,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.labelLarge),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildInfoTab(ProfileModel profile) {
    return ListView(
      padding: AppSpacing.paddingAll,
      children: [
        if (profile.bio?.content != null && profile.bio!.content!.isNotEmpty) ...[
          Text('Bio', style: AppTextStyles.labelMedium),
          AppSpacing.verticalXs,
          Text(profile.bio!.content!, style: AppTextStyles.bodyMedium),
          AppSpacing.verticalLg,
        ],
        if (profile.nickname?.name != null && profile.nickname!.name!.isNotEmpty)
          _infoRow(Icons.badge_outlined, 'Nickname', profile.nickname!.name!),
        if (profile.gender?.value != null && profile.gender!.value!.isNotEmpty)
          _infoRow(Icons.person_outline, 'Gender', profile.gender!.value!),
        if (profile.birthdate?.age != null)
          _infoRow(Icons.cake_outlined, 'Age', '${profile.birthdate!.age}'),
        if (profile.homeCenter?.centerName != null && profile.homeCenter!.centerName!.isNotEmpty)
          _infoRow(Icons.place_outlined, 'Home Center', profile.homeCenter!.centerName!),
        if (profile.ballHandlingStyle != null) ...[
          if (profile.ballHandlingStyle!.handedness != null && profile.ballHandlingStyle!.handedness!.isNotEmpty)
            _infoRow(Icons.sports_rounded, 'Style',
              '${profile.ballHandlingStyle!.handedness ?? ''} · ${profile.ballHandlingStyle!.ballCarry ?? ''} · ${profile.ballHandlingStyle!.grip ?? ''}'.trim()),
        ],
        if (profile.address?.location != null && profile.address!.location!.address != null)
          _infoRow(Icons.location_on_outlined, 'Location', profile.address!.location!.address!),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textMuted),
          AppSpacing.horizontalMd,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(ProfileModel profile) {
    final stats = profile.officialGameStat;
    if (stats == null || !stats.isAdded) {
      return const Center(child: Text('No game stats yet', style: TextStyle(color: AppColors.textMuted)));
    }
    return ListView(
      padding: AppSpacing.paddingAll,
      children: [
        _statCard('Average', stats.average?.toStringAsFixed(1) ?? '-', Icons.analytics_outlined),
        _statCard('High Game', stats.highGame?.toString() ?? '-', Icons.emoji_events_outlined),
        _statCard('High Series', stats.highSeries?.toString() ?? '-', Icons.military_tech_outlined),
        _statCard('Experience', '${stats.experience ?? 0} years', Icons.timer_outlined),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: AppColors.primary),
          AppSpacing.horizontalBase,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.h4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return const Center(child: Text('Posts coming soon', style: TextStyle(color: AppColors.textMuted)));
  }

  Widget _buildMediaTab() {
    return const Center(child: Text('Media coming soon', style: TextStyle(color: AppColors.textMuted)));
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.bgWhite, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

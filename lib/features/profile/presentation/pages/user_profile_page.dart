import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../home/data/models/user_model.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            // Check if user is UserModel (full data) or basic User entity
            if (state.user is UserModel) {
              final userModel = state.user as UserModel;
              return _buildProfileContent(context, userModel);
            } else {
              // Create a mock UserModel for demonstration with basic user data
              final mockUserModel = UserModel(
                id: state.user.id,
                name: state.user.name,
                email: state.user.email,
                username: 'demo_user',
                firstName: state.user.name.split(' ').first,
                lastName: state.user.name.split(' ').length > 1 
                    ? state.user.name.split(' ').last 
                    : 'User',
                profilePictureUrl: '',
                introVideoUrl: '',
                coverPhotoUrl: '',
                xp: 93,
                level: 4,
                cardTheme: '#425A70',
                isPro: true,
                sponsors: [
                  BrandModel(
                    brandId: 7,
                    brandType: "Business Sponsors",
                    name: "JMar Entertainment",
                    formalName: "JMar Entertainment LLC",
                    logoUrl: "https://pub-49dd9bba56ef4264b3519dc44f61a815.r2.dev/business-sponsors/jmar%20entertainment.png"
                  )
                ],
                followerCount: 3,
                stats: StatsModel(
                  id: state.user.id,
                  userId: state.user.id,
                  averageScore: 185.5,
                  highGame: 278,
                  highSeries: 756,
                  experience: 1500,
                ),
                favoriteBrands: [
                  BrandModel(
                    brandId: 24,
                    brandType: "Balls",
                    name: "Brunswick",
                    formalName: "Brunswick",
                    logoUrl: "https://pub-49dd9bba56ef4264b3519dc44f61a815.r2.dev/ball-manufacturers/brunswick%20bowling%20%20ball.png"
                  ),
                  BrandModel(
                    brandId: 5,
                    brandType: "Business Sponsors", 
                    name: "Buffalo Wild Wings",
                    formalName: "Buffalo Wild Wings",
                    logoUrl: "https://pub-49dd9bba56ef4264b3519dc44f61a815.r2.dev/business-sponsors/buffalo%20wild%20wings.png"
                  ),
                ],
                isComplete: true,
              );
              return _buildProfileContent(context, mockUserModel);
            }
          }
          return const Center(
            child: Text('User data not available'),
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel user) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, user),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(user),
                const SizedBox(height: 24),
                _buildStatsSection(user.stats),
                const SizedBox(height: 24),
                if (user.isPro)
                  _buildSponsorsSection(user.sponsors)
                else
                  _buildFavoriteBrandsSection(user.favoriteBrands),
                const SizedBox(height: 24),
                _buildIntroVideoSection(user.introVideoUrl),
                const SizedBox(height: 24),
                _buildSocialSection(), // Future: User posts will go here
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context, UserModel user) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Cover Photo
            user.coverPhotoUrl.isNotEmpty
                ? Image.network(
                    user.coverPhotoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.blue.shade400,
                                Colors.blue.shade800,
                              ],
                            ),
                          ),
                        ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade800,
                        ],
                      ),
                    ),
                  ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Profile Picture and Basic Info
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Hero(
                    tag: 'profile_picture',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: user.profilePictureUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                user.profilePictureUrl,
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Text(
                                      user.name[0].toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                              ),
                            )
                          : Text(
                              user.name[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '@${user.username}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (user.isPro) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              'Level ${user.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(UserModel user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Email', user.email, Icons.email),
            _buildInfoRow('Experience Points', '${user.xp} XP', Icons.star),
            _buildInfoRow('Followers', '${user.followerCount}', Icons.people),
            _buildInfoRow('Level', '${user.level}', Icons.trending_up),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(StatsModel stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bowling Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Average Score',
                    stats.averageScore.toStringAsFixed(1),
                    Icons.analytics,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'High Game',
                    '${stats.highGame}',
                    Icons.emoji_events,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'High Series',
                    '${stats.highSeries}',
                    Icons.timeline,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Experience',
                    '${stats.experience}',
                    Icons.psychology,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSponsorsSection(List<BrandModel> sponsors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.business, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Sponsors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sponsors.isEmpty)
              const Text(
                'No sponsors yet',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: sponsors.map((sponsor) => _buildBrandCard(sponsor)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteBrandsSection(List<BrandModel> favoriteBrands) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.favorite, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Favorite Brands',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (favoriteBrands.isEmpty)
              const Text(
                'No favorite brands selected',
                style: TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: favoriteBrands.map((brand) => _buildBrandCard(brand)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandCard(BrandModel brand) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                brand.logoUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            brand.name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildIntroVideoSection(String introVideoUrl) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.video_library, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Introduction Video',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (introVideoUrl.isEmpty)
              const Text(
                'No introduction video available',
                style: TextStyle(color: Colors.grey),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade800, Colors.blue.shade400],
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_fill,
                              size: 64,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Introduction Video',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Tap to play',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
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
      ),
    );
  }

  Widget _buildSocialSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.feed, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Activity Feed',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.post_add,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Social Posts Coming Soon!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Share your bowling achievements, photos, and connect with other bowlers.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

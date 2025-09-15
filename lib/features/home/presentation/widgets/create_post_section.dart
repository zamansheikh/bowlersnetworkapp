import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../cubit/feed_cubit.dart';
import 'create_post_modal.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../home/data/models/user_model.dart';

class CreatePostSection extends StatelessWidget {
  const CreatePostSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const SizedBox.shrink();
        }

        // Cast to UserModel to access additional properties
        final userModel = authState.user is UserModel
            ? authState.user as UserModel
            : null;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            elevation: 2,
            shadowColor: AppColors.cardShadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quick action buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.edit_note,
                          label: 'Create Post',
                          color: AppColors.info,
                          onTap: () =>
                              _showCreatePostModal(context, PostType.text),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.photo_camera,
                          label: 'Add Media',
                          color: AppColors.error,
                          onTap: () =>
                              _showCreatePostModal(context, PostType.media),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.poll,
                          label: 'Create Poll',
                          color: AppColors.warning,
                          onTap: () =>
                              _showCreatePostModal(context, PostType.poll),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Main post input area
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            userModel != null &&
                                userModel.profilePictureUrl.isNotEmpty
                            ? NetworkImage(userModel.profilePictureUrl)
                            : null,
                        backgroundColor: AppColors.primaryLimeGreen,
                        child: userModel?.profilePictureUrl.isEmpty ?? true
                            ? Text(
                                userModel?.firstName.isNotEmpty == true
                                    ? userModel!.firstName[0].toUpperCase()
                                    : authState.user.name.isNotEmpty
                                    ? authState.user.name[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _showCreatePostModal(context, PostType.text),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.outline.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              'What\'s on your mind, ${userModel?.firstName ?? authState.user.name}?',
                              style: const TextStyle(
                                color: AppColors.gray,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Privacy and post button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.public, size: 16, color: AppColors.gray),
                          const SizedBox(width: 4),
                          const Text(
                            'Public',
                            style: TextStyle(
                              color: AppColors.gray,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.gray,
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _showCreatePostModal(context, PostType.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.gray,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: AppColors.outline.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        child: const Text(
                          'Post',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostModal(BuildContext context, PostType initialType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreatePostModal(
        initialType: initialType,
        onPostCreated: () {
          // Refresh the feed
          context.read<FeedCubit>().refreshFeed();
        },
      ),
    );
  }
}

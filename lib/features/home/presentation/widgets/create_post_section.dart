import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEDEDED), width: 1),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Main post input area
              Padding(
                padding: const EdgeInsets.only(bottom: 21),
                child: Row(
                  children: [
                    // Profile picture
                    CircleAvatar(
                      radius: 12,
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
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    // Text input
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            _showCreatePostModal(context, PostType.text),
                        child: Text(
                          'What\'s on your mind ${userModel?.firstName ?? authState.user.name}?',
                          style: const TextStyle(
                            color: Color(0xFF6D6D6D),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        
              // Divider line
              Container(
                height: 1,
                color: const Color(0xFFEDEDED),
                margin: const EdgeInsets.only(bottom: 12),
              ),
        
              // Bottom row with icons and post button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left side - icons and public dropdown
                  Row(
                    children: [
                      // Camera icon
                      GestureDetector(
                        onTap: () =>
                            _showCreatePostModal(context, PostType.media),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFEEEEEE),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/camera.svg',
                            width: 16.w,
                            height: 16.h,
                            // colorFilter: const ColorFilter.mode(
                            //   Color(0xFF666666),
                            //   BlendMode.srcIn,
                            // ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Poll icon
                      GestureDetector(
                        onTap: () =>
                            _showCreatePostModal(context, PostType.poll),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFEEEEEE),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/poll.svg',
                            width: 16.w,
                            height: 16.h,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Public dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFEFEDED),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.public,
                              size: 16,
                              color: Color(0xFF818181),
                            ),
                            const SizedBox(width: 2),
                            const Text(
                              'Public',
                              style: TextStyle(
                                color: Color(0xFF949494),
                                fontSize: 10,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              size: 12,
                              color: Color(0xFF818181),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Right side - Post button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8BBB4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () =>
                          _showCreatePostModal(context, PostType.text),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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

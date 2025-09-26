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
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFEDEDED), width: 1.w),
          ),
          padding: EdgeInsets.all(12.w),
          child: Column(
            children: [
              // Main post input area
              Padding(
                padding: EdgeInsets.only(bottom: 21.h),
                child: Row(
                  children: [
                    // Profile picture
                    CircleAvatar(
                      radius: 12.r,
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
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(width: 8.w),
                    // Text input
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            _showCreatePostModal(context, PostType.text),
                        child: Text(
                          'What\'s on your mind ${userModel?.firstName ?? authState.user.name}?',
                          style: TextStyle(
                            color: Color(0xFF6D6D6D),
                            fontSize: 12.sp,
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
                height: 1.h,
                color: const Color(0xFFEDEDED),
                margin: EdgeInsets.only(bottom: 12.h),
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
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFEEEEEE),
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(50.r),
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
                      SizedBox(width: 12.w),
                      // Poll icon
                      GestureDetector(
                        onTap: () =>
                            _showCreatePostModal(context, PostType.poll),
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFEEEEEE),
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/poll.svg',
                            width: 16.w,
                            height: 16.h,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      // Public dropdown
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFFEFEDED),
                            width: 1.w,
                          ),
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.public,
                              size: 16.sp,
                              color: Color(0xFF818181),
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Public',
                              style: TextStyle(
                                color: Color(0xFF949494),
                                fontSize: 10.sp,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 12.sp,
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
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextButton(
                      onPressed: () =>
                          _showCreatePostModal(context, PostType.text),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 5.h,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Post',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
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

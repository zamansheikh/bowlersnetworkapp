import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../home/data/models/user_model.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _averageScoreController;
  late TextEditingController _highGameController;
  late TextEditingController _highSeriesController;
  late TextEditingController _experienceController;

  File? _profilePicture;
  File? _coverPhoto;
  File? _introVideo;

  String? _existingProfilePictureUrl;
  String? _existingCoverPhotoUrl;
  String? _existingIntroVideoUrl;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _averageScoreController = TextEditingController();
    _highGameController = TextEditingController();
    _highSeriesController = TextEditingController();
    _experienceController = TextEditingController();

    // Add listeners to trigger rebuild for floating labels
    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
    _usernameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _averageScoreController.addListener(() => setState(() {}));
    _highGameController.addListener(() => setState(() {}));
    _highSeriesController.addListener(() => setState(() {}));
    _experienceController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _averageScoreController.dispose();
    _highGameController.dispose();
    _highSeriesController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _populateFields(UserModel user) {
    setState(() {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _averageScoreController.text = user.stats.averageScore.toString();
      _highGameController.text = user.stats.highGame.toString();
      _highSeriesController.text = user.stats.highSeries.toString();
      _experienceController.text = user.stats.experience.toString();

      _existingProfilePictureUrl = user.profilePictureUrl;
      _existingCoverPhotoUrl = user.coverPhotoUrl;
      _existingIntroVideoUrl = user.introVideoUrl;
    });
  }

  Future<void> _pickImage(String type) async {
    final ImageSource? source = await _showImageSourceDialog();
    if (source == null) return;

    try {
      if (type == 'video') {
        final XFile? pickedFile = await _picker.pickVideo(source: source);
        if (pickedFile != null) {
          setState(() {
            _introVideo = File(pickedFile.path);
          });
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            if (type == 'profile') {
              _profilePicture = File(pickedFile.path);
            } else if (type == 'cover') {
              _coverPhoto = File(pickedFile.path);
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking $type: $e')));
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is Authenticated && state.user is UserModel) {
            final user = state.user as UserModel;
            // Populate fields when user data is available
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_firstNameController.text.isEmpty) {
                _populateFields(user);
              }
            });
            return _buildEditForm(user);
          }
          return const Center(
            child: Text(
              'Unable to load profile data',
              style: TextStyle(color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditForm(UserModel user) {
    return Column(
      children: [
        // Status bar and header
        SafeArea(
          bottom: false,
          child: Container(
            height: 56.h,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              children: [
                // Back button
                Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18.sp,
                      color: Colors.black87,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                ),

                // Title
                Expanded(
                  child: Text(
                    'Edit Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF101010),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),

                // Save button
                GestureDetector(
                  onTap: _saveProfile,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8BC342),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Information Section
                  _buildPersonalInfoSection(),
                  SizedBox(height: 24.h),

                  // Media & Display Section
                  _buildMediaSection(user),
                  SizedBox(height: 24.h),

                  // Bowling Statistics Section
                  _buildStatsSection(),
                  SizedBox(height: 24.h),

                  // Save Button
                  _buildSaveButton(),
                  SizedBox(height: 20.h), // Bottom padding for scroll
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFF8BC342),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _saveProfile,
          borderRadius: BorderRadius.circular(8.r),
          child: Center(
            child: Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media & Display',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            // Profile Picture
            _buildMediaCard(
              title: 'Profile Picture',
              icon: Icons.image_outlined,
              onTap: () => _pickImage('profile'),
              isVideo: false,
              imageFile: _profilePicture,
              existingUrl: _existingProfilePictureUrl,
            ),
            SizedBox(width: 8.w),
            // Intro Video
            Expanded(
              child: _buildMediaCard(
                title: 'Intro Video',
                icon: Icons.play_circle_outline,
                onTap: () => _pickImage('video'),
                isVideo: true,
                imageFile: _introVideo,
                existingUrl: _existingIntroVideoUrl,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 24.h),
        _buildInputField(
          controller: _firstNameController,
          label: 'First Name',
          icon: Icons.person_outline,
        ),
        SizedBox(height: 24.h),
        _buildInputField(
          controller: _lastNameController,
          label: 'Last Name',
          icon: Icons.person_outline,
        ),
        SizedBox(height: 24.h),
        _buildInputField(
          controller: _usernameController,
          label: 'Username',
          icon: Icons.person_outline,
          enabled: false,
        ),
        SizedBox(height: 24.h),
        _buildInputField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bowling Statistics',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _experienceController,
                label: 'Experience',
                icon: Icons.star_outline,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildInputField(
                controller: _highGameController,
                label: 'High Game',
                icon: Icons.emoji_events_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _averageScoreController,
                label: 'Average Score',
                icon: Icons.poll_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildInputField(
                controller: _highSeriesController,
                label: 'High Series',
                icon: Icons.trending_up,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required bool isVideo,
    File? imageFile,
    String? existingUrl,
  }) {
    final hasContent =
        imageFile != null || (existingUrl != null && existingUrl.isNotEmpty);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isVideo ? null : 106.w,
        height: 106.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: hasContent
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: imageFile != null
                        ? (isVideo
                              ? Container(
                                  color: Colors.black87,
                                  child: const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                )
                              : Image.file(imageFile, fit: BoxFit.cover))
                        : (isVideo
                              ? Container(
                                  color: Colors.black87,
                                  child: const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                )
                              : Image.network(
                                  existingUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildPlaceholder(title, icon),
                                )),
                  ),
                  if (!isVideo)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      right: 4,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              )
            : _buildPlaceholder(title, icon),
      ),
    );
  }

  Widget _buildPlaceholder(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24.sp, color: const Color(0xFFA0A49B)),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFFA0A49B),
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    final bool hasValue = controller.text.isNotEmpty;

    return Stack(
      clipBehavior: Clip.none, // Ensure floating label is not clipped
      children: [
        Container(
          height: 56.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFE8E9E6)),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: enabled
                  ? const Color(0xFF111B05)
                  : const Color(0xFFA0A49B),
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                size: 24.sp,
                color: const Color(0xFF8BC342),
              ),
              hintText: hasValue ? null : label,
              hintStyle: TextStyle(
                fontSize: 16.sp,
                color: const Color(0xFFA0A49B),
                fontFamily: 'Poppins',
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            ),
          ),
        ),
        // Floating label - show when field has value or is disabled
        if (hasValue || !enabled)
          Positioned(
            left: 16.w,
            top: -10.h, // Adjust position to ensure visibility
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFFA0A49B),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement profile update logic
      // This would typically involve:
      // 1. Uploading images/videos to server
      // 2. Updating user profile with new URLs
      // 3. Calling repository method to update profile

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile update functionality coming soon!'),
          backgroundColor: Colors.blue,
        ),
      );

      // For now, just go back to the profile page
      context.pop();
    }
  }
}

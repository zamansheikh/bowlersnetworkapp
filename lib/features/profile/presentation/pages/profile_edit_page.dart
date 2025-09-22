import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../home/data/models/user_model.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

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
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Edit Profile',
        actions: [CustomSaveButton(onPressed: _saveProfile)],
      ),
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
              style: TextStyle(color: AppColors.gray),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditForm(UserModel user) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMediaSection(user),
              const SizedBox(height: 20),
              _buildPersonalInfoSection(),
              const SizedBox(height: 20),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildSaveButton(),
              const SizedBox(height: 20), // Bottom padding for scroll
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLimeGreen,
          foregroundColor: AppColors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: AppColors.primaryLimeGreen.withOpacity(0.3),
        ),
        child: const Text(
          'Save Changes',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildMediaSection(UserModel user) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Media & Display',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Profile Picture
            _buildImagePickerSection(
              'Profile Picture',
              _profilePicture,
              _existingProfilePictureUrl,
              () => _pickImage('profile'),
              isCircular: true,
            ),
            const SizedBox(height: 20),

            // Cover Photo or Intro Video based on user type
            if (user.isPro)
              _buildVideoPickerSection(
                'Introduction Video',
                _introVideo,
                _existingIntroVideoUrl,
                () => _pickImage('video'),
              )
            else
              _buildImagePickerSection(
                'Cover Photo',
                _coverPhoto,
                _existingCoverPhotoUrl,
                () => _pickImage('cover'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerSection(
    String title,
    File? imageFile,
    String? existingUrl,
    VoidCallback onTap, {
    bool isCircular = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: isCircular
              ? _buildCircularProfilePicture(imageFile, existingUrl, title)
              : _buildRectangularImage(imageFile, existingUrl, title),
        ),
      ],
    );
  }

  Widget _buildCircularProfilePicture(
    File? imageFile,
    String? existingUrl,
    String title,
  ) {
    const size = 120.0;
    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryLimeGreen, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLimeGreen.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: imageFile != null
              ? Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                )
              : existingUrl != null && existingUrl.isNotEmpty
              ? Image.network(
                  existingUrl,
                  fit: BoxFit.cover,
                  width: size,
                  height: size,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildCircularPlaceholder(title),
                )
              : _buildCircularPlaceholder(title),
        ),
      ),
    );
  }

  Widget _buildRectangularImage(
    File? imageFile,
    String? existingUrl,
    String title,
  ) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageFile != null
            ? Image.file(imageFile, fit: BoxFit.cover)
            : existingUrl != null && existingUrl.isNotEmpty
            ? Image.network(
                existingUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildRectangularPlaceholder(title),
              )
            : _buildRectangularPlaceholder(title),
      ),
    );
  }

  Widget _buildCircularPlaceholder(String title) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_add, size: 40, color: AppColors.primaryLimeGreen),
          const SizedBox(height: 4),
          Text(
            'Add Photo',
            style: TextStyle(
              color: AppColors.primaryLimeGreen,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRectangularPlaceholder(String title) {
    return Container(
      color: AppColors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 32, color: AppColors.gray),
          const SizedBox(height: 8),
          Text(
            'Tap to select $title',
            style: const TextStyle(color: AppColors.gray, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPickerSection(
    String title,
    File? videoFile,
    String? existingUrl,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
              gradient:
                  videoFile != null ||
                      (existingUrl != null && existingUrl.isNotEmpty)
                  ? AppColors.primaryGradient
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (videoFile != null ||
                    (existingUrl != null && existingUrl.isNotEmpty))
                  const Icon(
                    Icons.play_circle_fill,
                    size: 48,
                    color: AppColors.white,
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.video_library,
                        size: 32,
                        color: AppColors.gray,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to select $title',
                        style: const TextStyle(
                          color: AppColors.gray,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                if (videoFile != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'New Video',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection('Personal Information', [
      _buildTextField(
        controller: _firstNameController,
        label: 'First Name',
        icon: Icons.person,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your first name';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _lastNameController,
        label: 'Last Name',
        icon: Icons.person_outline,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your last name';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _usernameController,
        label: 'Username',
        icon: Icons.alternate_email,
        enabled: false,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a username';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _emailController,
        label: 'Email',
        icon: Icons.email,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    ]);
  }

  Widget _buildStatsSection() {
    return _buildSection('Bowling Statistics', [
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: _averageScoreController,
              label: 'Average Score',
              icon: Icons.analytics,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed < 0 || parsed > 300) {
                    return 'Enter valid score (0-300)';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildTextField(
              controller: _highGameController,
              label: 'High Game',
              icon: Icons.emoji_events,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed < 0 || parsed > 300) {
                    return 'Enter valid score (0-300)';
                  }
                }
                return null;
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: _buildTextField(
              controller: _highSeriesController,
              label: 'High Series',
              icon: Icons.timeline,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed < 0 || parsed > 900) {
                    return 'Enter valid series (0-900)';
                  }
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildTextField(
              controller: _experienceController,
              label: 'Experience',
              icon: Icons.psychology,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed < 0) {
                    return 'Enter valid experience';
                  }
                }
                return null;
              },
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primaryLimeGreen),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.primaryLimeGreen,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        filled: true,
        fillColor: enabled ? AppColors.white : AppColors.surface,
        labelStyle: TextStyle(
          color: enabled
              ? AppColors.gray
              : AppColors.gray.withValues(alpha: 0.5),
        ),
      ),
      style: TextStyle(color: enabled ? AppColors.black : AppColors.gray),
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
          backgroundColor: AppColors.info,
        ),
      );

      // For now, just go back to the profile page
      context.pop();
    }
  }
}

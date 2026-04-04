import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/cloud_upload_service.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_avatar.dart';
import '../../data/models/profile_models.dart';
import '../../domain/repositories/profile_repository.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileModel profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final ProfileRepository _repo;
  late final CloudUploadService _cloud;
  bool _saving = false;
  bool _uploadingPic = false;
  bool _uploadingCover = false;

  // Form controllers
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _bioCtrl;
  late String? _gender;
  late String _handedness;
  late String _ballCarry;
  late String _grip;
  String? _profilePicUrl;
  String? _coverPicUrl;

  @override
  void initState() {
    super.initState();
    _repo = getIt<ProfileRepository>();
    _cloud = getIt<CloudUploadService>();

    final p = widget.profile;
    _nicknameCtrl = TextEditingController(text: p.nickname?.name ?? '');
    _bioCtrl = TextEditingController(text: p.bio?.content ?? '');
    _gender = p.gender?.value;
    _handedness = p.ballHandlingStyle?.handedness ?? 'Righty';
    _ballCarry = p.ballHandlingStyle?.ballCarry ?? 'One handed';
    _grip = p.ballHandlingStyle?.grip ?? 'With Thumb';
    _profilePicUrl = p.profileMedia?.profilePictureUrl;
    _coverPicUrl = p.profileMedia?.coverPictureUrl;
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  bool get _hasCustomPic =>
      _profilePicUrl != null && !_profilePicUrl!.contains('defaults/');
  bool get _hasCustomCover =>
      _coverPicUrl != null && !_coverPicUrl!.contains('defaults/');

  Future<void> _pickAndUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() => _uploadingPic = true);
    final bytes = await image.readAsBytes();
    final result = await _cloud.uploadFile(
      fileBytes: bytes,
      fileName: image.name.isNotEmpty ? image.name : 'profile.jpg',
      bucket: 'profiles',
    );
    result.fold(
      (f) {
        if (mounted) context.showErrorSnackBar(f.message);
      },
      (url) async {
        await _repo.uploadProfilePicture(
          fileBytes: bytes,
          fileName: image.name,
        );
        setState(() => _profilePicUrl = url);
      },
    );
    if (mounted) setState(() => _uploadingPic = false);
  }

  Future<void> _pickAndUploadCover() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (image == null) return;
    setState(() => _uploadingCover = true);
    final bytes = await image.readAsBytes();
    final result = await _cloud.uploadFile(
      fileBytes: bytes,
      fileName: image.name.isNotEmpty ? image.name : 'cover.jpg',
      bucket: 'profiles',
    );
    result.fold((f) {
      if (mounted) context.showErrorSnackBar(f.message);
    }, (url) => setState(() => _coverPicUrl = url));
    // Update cover URL on backend
    final coverUrl = result.fold((_) => null, (url) => url);
    if (coverUrl != null) {
      final updateResult = await _repo.updateCoverPicture(url: coverUrl);
      updateResult.fold((f) {
        if (mounted) context.showErrorSnackBar(f.message);
      }, (_) {});
    }
    if (mounted) setState(() => _uploadingCover = false);
  }

  Future<void> _saveAll() async {
    setState(() => _saving = true);

    final nickname = _nicknameCtrl.text.trim();
    final bio = _bioCtrl.text.trim();

    // Save each changed field
    if (nickname.isNotEmpty &&
        nickname != (widget.profile.nickname?.name ?? '')) {
      final r = await _repo.updateNickname(name: nickname);
      r.fold((f) {
        if (mounted) context.showErrorSnackBar(f.message);
      }, (_) {});
    }
    if (bio != (widget.profile.bio?.content ?? '')) {
      final r = await _repo.updateBio(content: bio);
      r.fold((f) {
        if (mounted) context.showErrorSnackBar(f.message);
      }, (_) {});
    }
    if (_gender != null && _gender != widget.profile.gender?.value) {
      final r = await _repo.updateGender(value: _gender!);
      r.fold((f) {
        if (mounted) context.showErrorSnackBar(f.message);
      }, (_) {});
    }
    if (_handedness != (widget.profile.ballHandlingStyle?.handedness ?? '') ||
        _ballCarry != (widget.profile.ballHandlingStyle?.ballCarry ?? '') ||
        _grip != (widget.profile.ballHandlingStyle?.grip ?? '')) {
      final r = await _repo.updateBallHandlingStyle(
        handedness: _handedness,
        ballCarry: _ballCarry,
        grip: _grip,
      );
      r.fold((f) {
        if (mounted) context.showErrorSnackBar(f.message);
      }, (_) {});
    }

    if (mounted) {
      setState(() => _saving = false);
      context.showSnackBar('Profile updated!');
      context.pop(true); // true = refresh profile
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Profile', style: AppTextStyles.h4),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saving ? null : _saveAll,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Save',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMediaSection(),
            const Divider(height: 1),
            _buildFieldsSection(),
          ],
        ),
      ),
    );
  }

  // ── Cover + Avatar section ────────────────────────────

  Widget _buildMediaSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover
        GestureDetector(
          onTap: _uploadingCover ? null : _pickAndUploadCover,
          child: Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: _hasCustomCover
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF8BC342), Color(0xFF5B9A26)],
                    ),
            ),
            child: Stack(
              children: [
                if (_hasCustomCover)
                  CachedNetworkImage(
                    imageUrl: _coverPicUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 140,
                  ),
                Center(
                  child: _uploadingCover
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Edit Cover',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),

        // Avatar
        Positioned(
          bottom: -40,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _uploadingPic ? null : _pickAndUploadProfilePic,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bgWhite, width: 4),
                    ),
                    child: _uploadingPic
                        ? Container(
                            width: 88,
                            height: 88,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.bgSubtleGray,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : BnAvatar(
                            imageUrl: _hasCustomPic ? _profilePicUrl : null,
                            name:
                                '${widget.profile.user?.firstName ?? ''} ${widget.profile.user?.lastName ?? ''}',
                            size: 88,
                          ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        border: Border.all(color: AppColors.bgWhite, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Spacer for avatar overflow
        const SizedBox(height: 140),
      ],
    );
  }

  // ── Fields section ────────────────────────────────────

  Widget _buildFieldsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nickname
          _fieldLabel('Nickname'),
          TextField(
            controller: _nicknameCtrl,
            maxLength: 20,
            decoration: _inputDecor('What should we call you?'),
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Bio
          _fieldLabel('Bio'),
          TextField(
            controller: _bioCtrl,
            maxLines: 3,
            maxLength: 280,
            decoration: _inputDecor('Tell the community about yourself...'),
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 20),

          // Gender
          _fieldLabel('Gender'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _choiceChip(
                  'Male',
                  _gender == 'Male',
                  () => setState(() => _gender = 'Male'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _choiceChip(
                  'Female',
                  _gender == 'Female',
                  () => setState(() => _gender = 'Female'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Ball Handling Style
          _fieldLabel('Bowling Hand'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _choiceChip(
                  'Righty',
                  _handedness == 'Righty',
                  () => setState(() => _handedness = 'Righty'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _choiceChip(
                  'Lefty',
                  _handedness == 'Lefty',
                  () => setState(() => _handedness = 'Lefty'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _fieldLabel('Ball Carry'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _choiceChip(
                  'One handed',
                  _ballCarry == 'One handed',
                  () => setState(() => _ballCarry = 'One handed'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _choiceChip(
                  'Two handed',
                  _ballCarry == 'Two handed',
                  () => setState(() => _ballCarry = 'Two handed'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _fieldLabel('Grip Style'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _choiceChip(
                  'With Thumb',
                  _grip == 'With Thumb',
                  () => setState(() => _grip = 'With Thumb'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _choiceChip(
                  'With No Thumb',
                  _grip == 'With No Thumb',
                  () => setState(() => _grip = 'With No Thumb'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text, style: AppTextStyles.labelMedium),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _choiceChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.bgWhite,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

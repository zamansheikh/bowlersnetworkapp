import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/cloud_upload_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/bn_button.dart';
import '../../domain/repositories/newsfeed_repository.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _captionController = TextEditingController();
  String _selectedAudience = 'public';
  final List<XFile> _selectedImages = [];
  bool _isPosting = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(maxWidth: 1200, imageQuality: 85);
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images));
    }
  }

  Future<void> _submitPost() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty && _selectedImages.isEmpty) {
      context.showErrorSnackBar('Write something or add a photo');
      return;
    }

    setState(() => _isPosting = true);

    try {
      final repo = getIt<NewsfeedRepository>();

      if (_selectedImages.isNotEmpty) {
        // Upload images via CloudUploadService, then create photo post
        final cloudService = getIt<CloudUploadService>();
        final files = <({Uint8List bytes, String name})>[];
        for (final img in _selectedImages) {
          final bytes = await img.readAsBytes();
          files.add((bytes: bytes, name: img.name.isNotEmpty ? img.name : 'photo.jpg'));
        }
        final uploadResult = await cloudService.uploadFiles(files: files, bucket: 'media');
        final urls = uploadResult.fold((f) => <String>[], (urls) => urls);
        if (urls.isEmpty) {
          if (mounted) context.showErrorSnackBar('Failed to upload images');
          setState(() => _isPosting = false);
          return;
        }
        await repo.createPhotoPost(mediaUrls: urls, caption: caption, audience: _selectedAudience);
      } else {
        await repo.createTextPost(caption: caption, audience: _selectedAudience);
      }

      if (mounted) {
        context.showSnackBar('Post created!');
        context.pop(true); // true = refresh feed
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar('Failed to create post');
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close, size: 24),
        ),
        title: Text('Create Post', style: AppTextStyles.h4),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 80,
              child: BnButton(
                text: 'Post',
                height: 36,
                isLoading: _isPosting,
                onPressed: _submitPost,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingAll,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Audience selector
                  GestureDetector(
                    onTap: _showAudiencePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderMedium),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_audienceIcon, size: 16, color: AppColors.textSecondary),
                          AppSpacing.horizontalXs,
                          Text(_selectedAudience.capitalize, style: AppTextStyles.labelSmall),
                          AppSpacing.horizontalXs,
                          const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  AppSpacing.verticalBase,

                  // Caption
                  TextField(
                    controller: _captionController,
                    maxLines: null,
                    minLines: 4,
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    style: AppTextStyles.bodyLarge,
                  ),

                  // Selected images preview
                  if (_selectedImages.isNotEmpty) ...[
                    AppSpacing.verticalBase,
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (_, i) => Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.bgSubtleGray,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: FutureBuilder<List<int>>(
                                  future: _selectedImages[i].readAsBytes().then((b) => b.toList()),
                                  builder: (_, snap) {
                                    if (!snap.hasData) return const SizedBox.shrink();
                                    return Image.memory(Uint8List.fromList(snap.data!), fit: BoxFit.cover);
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4, right: 12,
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedImages.removeAt(i)),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black54),
                                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom toolbar
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
                    onPressed: _pickImages,
                  ),
                  IconButton(
                    icon: const Icon(Icons.videocam_outlined, color: AppColors.textMuted),
                    onPressed: () {}, // TODO: Video post
                  ),
                  IconButton(
                    icon: const Icon(Icons.poll_outlined, color: AppColors.textMuted),
                    onPressed: () {}, // TODO: Poll post
                  ),
                  IconButton(
                    icon: const Icon(Icons.scoreboard_outlined, color: AppColors.textMuted),
                    onPressed: () {}, // TODO: Score post
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData get _audienceIcon => switch (_selectedAudience) {
        'public' => Icons.public,
        'followers' => Icons.people_outline,
        'private' => Icons.lock_outline,
        _ => Icons.public,
      };

  void _showAudiencePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Public'),
              subtitle: const Text('Everyone can see this'),
              selected: _selectedAudience == 'public',
              onTap: () { setState(() => _selectedAudience = 'public'); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Followers'),
              subtitle: const Text('Only your followers'),
              selected: _selectedAudience == 'followers',
              onTap: () { setState(() => _selectedAudience = 'followers'); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Private'),
              subtitle: const Text('Only you'),
              selected: _selectedAudience == 'private',
              onTap: () { setState(() => _selectedAudience = 'private'); Navigator.pop(context); },
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String get capitalize => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

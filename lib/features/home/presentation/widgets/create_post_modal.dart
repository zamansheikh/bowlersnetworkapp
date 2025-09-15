import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/colors.dart';
import '../cubit/feed_cubit.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../home/data/models/user_model.dart';

enum PostType { text, media, poll }

class CreatePostModal extends StatefulWidget {
  final PostType initialType;
  final VoidCallback? onPostCreated;

  const CreatePostModal({
    super.key,
    required this.initialType,
    this.onPostCreated,
  });

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  late PostType _currentType;
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _pollTitleController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<File> _selectedFiles = [];
  List<String> _pollOptions = ['', ''];
  String _pollType = 'Single';
  List<String> _tags = [];
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;
  }

  @override
  void dispose() {
    _captionController.dispose();
    _pollTitleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                    const Expanded(
                      child: Text(
                        'Create Post',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isCreating ? null : _createPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLimeGreen,
                        foregroundColor: AppColors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                      ),
                      child: _isCreating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.black,
                                ),
                              ),
                            )
                          : const Text(
                              'Post',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type selector
                      _buildTypeSelector(),

                      const SizedBox(height: 16),

                      // User info
                      _buildUserInfo(),

                      const SizedBox(height: 16),

                      // Content based on type
                      if (_currentType == PostType.text ||
                          _currentType == PostType.media)
                        _buildTextContent(),

                      if (_currentType == PostType.media) _buildMediaSection(),

                      if (_currentType == PostType.poll) _buildPollContent(),

                      const SizedBox(height: 16),

                      // Tags section
                      _buildTagsSection(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeButton(
            type: PostType.text,
            icon: Icons.edit_note,
            label: 'Text',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTypeButton(
            type: PostType.media,
            icon: Icons.photo_camera,
            label: 'Media',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTypeButton(
            type: PostType.poll,
            icon: Icons.poll,
            label: 'Poll',
          ),
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required PostType type,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentType = type;
          // Clear media files when switching away from media
          if (type != PostType.media) {
            _selectedFiles.clear();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLimeGreen.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLimeGreen
                : AppColors.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryLimeGreen : AppColors.gray,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryLimeGreen : AppColors.gray,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) return const SizedBox.shrink();

        // Cast to UserModel to access additional properties
        final userModel = state.user is UserModel
            ? state.user as UserModel
            : null;

        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
                  userModel != null && userModel.profilePictureUrl.isNotEmpty
                  ? NetworkImage(userModel.profilePictureUrl)
                  : null,
              backgroundColor: AppColors.primaryLimeGreen,
              child: userModel?.profilePictureUrl.isEmpty ?? true
                  ? Text(
                      userModel?.firstName.isNotEmpty == true
                          ? userModel!.firstName[0].toUpperCase()
                          : state.user.name.isNotEmpty
                          ? state.user.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userModel != null
                      ? '${userModel.firstName} ${userModel.lastName}'
                      : state.user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.public, size: 14, color: AppColors.gray),
                    const SizedBox(width: 4),
                    const Text(
                      'Public',
                      style: TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextContent() {
    return TextField(
      controller: _captionController,
      maxLines: null,
      minLines: 3,
      decoration: InputDecoration(
        hintText: _currentType == PostType.media
            ? 'Say something about your photos/videos...'
            : 'What\'s on your mind?',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryLimeGreen),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            const Text(
              'Media',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _pickMedia,
              icon: const Icon(Icons.add),
              label: const Text('Add Media'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryLimeGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_selectedFiles.isEmpty)
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
            ),
            child: InkWell(
              onTap: _pickMedia,
              borderRadius: BorderRadius.circular(12),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: AppColors.gray,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tap to add photos or videos',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ],
              ),
            ),
          )
        else
          _buildMediaPreview(),
      ],
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedFiles.length + 1, // +1 for add button
        itemBuilder: (context, index) {
          if (index == _selectedFiles.length) {
            // Add more button
            return Container(
              width: 100,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 0.5),
                ),
              ),
              child: InkWell(
                onTap: _pickMedia,
                borderRadius: BorderRadius.circular(12),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: AppColors.gray),
                    SizedBox(height: 4),
                    Text(
                      'Add More',
                      style: TextStyle(color: AppColors.gray, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          final file = _selectedFiles[index];
          final isVideo =
              file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov') ||
              file.path.toLowerCase().endsWith('.avi');

          return Container(
            width: 100,
            margin: EdgeInsets.only(
              right: index == _selectedFiles.length - 1 ? 0 : 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isVideo
                      ? Container(
                          width: 100,
                          height: 120,
                          color: AppColors.black,
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: AppColors.white,
                            size: 32,
                          ),
                        )
                      : Image.file(
                          file,
                          width: 100,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFiles.removeAt(index);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPollContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _pollTitleController,
          decoration: InputDecoration(
            labelText: 'Poll Question',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryLimeGreen),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            const Text(
              'Poll Type:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 16),
            ChoiceChip(
              label: const Text('Single Choice'),
              selected: _pollType == 'Single',
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _pollType = 'Single';
                  });
                }
              },
              selectedColor: AppColors.primaryLimeGreen.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: _pollType == 'Single'
                    ? AppColors.primaryLimeGreen
                    : AppColors.gray,
              ),
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Multiple Choice'),
              selected: _pollType == 'Multiple',
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _pollType = 'Multiple';
                  });
                }
              },
              selectedColor: AppColors.primaryLimeGreen.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: _pollType == 'Multiple'
                    ? AppColors.primaryLimeGreen
                    : AppColors.gray,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        const Text('Options', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pollOptions.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Option ${index + 1}',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.outline.withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryLimeGreen,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        _pollOptions[index] = value;
                      },
                    ),
                  ),
                  if (_pollOptions.length > 2)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _pollOptions.removeAt(index);
                        });
                      },
                      icon: const Icon(
                        Icons.remove_circle,
                        color: AppColors.error,
                      ),
                    ),
                ],
              ),
            );
          },
        ),

        if (_pollOptions.length < 5)
          TextButton.icon(
            onPressed: () {
              setState(() {
                _pollOptions.add('');
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Option'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryLimeGreen,
            ),
          ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tags', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),

        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tags.map((tag) {
              return Chip(
                label: Text('#$tag'),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _tags.remove(tag);
                  });
                },
                backgroundColor: AppColors.primaryLimeGreen.withValues(
                  alpha: 0.1,
                ),
                labelStyle: const TextStyle(color: AppColors.primaryLimeGreen),
              );
            }).toList(),
          ),

        const SizedBox(height: 8),

        TextField(
          controller: _tagController,
          decoration: InputDecoration(
            labelText: 'Add tags (press Enter)',
            prefixText: '#',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.outline.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryLimeGreen),
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty && !_tags.contains(value.trim())) {
              setState(() {
                _tags.add(value.trim());
                _tagController.clear();
              });
            }
          },
        ),
      ],
    );
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? file = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (file != null) {
                  setState(() {
                    _selectedFiles.add(File(file.path));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final List<XFile> files = await _picker.pickMultiImage();
                if (files.isNotEmpty) {
                  setState(() {
                    _selectedFiles.addAll(files.map((f) => File(f.path)));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? file = await _picker.pickVideo(
                  source: ImageSource.gallery,
                );
                if (file != null) {
                  setState(() {
                    _selectedFiles.add(File(file.path));
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    if (_isCreating) return;

    setState(() {
      _isCreating = true;
    });

    try {
      final feedCubit = context.read<FeedCubit>();

      switch (_currentType) {
        case PostType.text:
          if (_captionController.text.trim().isEmpty) {
            throw Exception('Please enter some text');
          }
          await feedCubit.createPost(
            caption: _captionController.text.trim(),
            tags: _tags.isNotEmpty ? _tags : null,
          );
          break;

        case PostType.media:
          if (_selectedFiles.isEmpty &&
              _captionController.text.trim().isEmpty) {
            throw Exception('Please add media files or enter text');
          }
          await feedCubit.createPost(
            caption: _captionController.text.trim(),
            mediaFiles: _selectedFiles.isNotEmpty ? _selectedFiles : null,
            tags: _tags.isNotEmpty ? _tags : null,
          );
          break;

        case PostType.poll:
          if (_pollTitleController.text.trim().isEmpty) {
            throw Exception('Please enter a poll question');
          }
          final validOptions = _pollOptions
              .where((opt) => opt.trim().isNotEmpty)
              .toList();
          if (validOptions.length < 2) {
            throw Exception('Please provide at least 2 poll options');
          }
          await feedCubit.createPollPost(
            caption: _captionController.text.trim(),
            pollTitle: _pollTitleController.text.trim(),
            pollType: _pollType,
            pollOptions: validOptions,
            tags: _tags.isNotEmpty ? _tags : null,
          );
          break;
      }

      if (widget.onPostCreated != null) {
        widget.onPostCreated!();
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
      );
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }
}

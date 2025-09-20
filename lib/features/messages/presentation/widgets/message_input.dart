import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/colors.dart';

class MessageInput extends StatefulWidget {
  final Function(String text, List<File> mediaFiles) onSendMessage;
  final String? conversationName;
  final bool isLoading;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.conversationName,
    this.isLoading = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _textController = TextEditingController();
  final List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty || _selectedFiles.isNotEmpty) {
      widget.onSendMessage(text, List.from(_selectedFiles));
      _textController.clear();
      _selectedFiles.clear();
      setState(() {});
    }
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                await _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Video'),
              onTap: () async {
                Navigator.pop(context);
                await _pickVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    for (final image in images) {
      _selectedFiles.add(File(image.path));
    }
    setState(() {});
  }

  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      _selectedFiles.add(File(image.path));
      setState(() {});
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      _selectedFiles.add(File(video.path));
      setState(() {});
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Selected files preview
            if (_selectedFiles.isNotEmpty)
              Container(
                height: 100,
                padding: const EdgeInsets.all(8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    final isVideo = _isVideoFile(file.path);

                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isVideo
                                  ? Stack(
                                      children: [
                                        Container(
                                          color: Colors.black26,
                                          child: const Center(
                                            child: Icon(
                                              Icons.play_circle_filled,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'VIDEO',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey,
                                                size: 24,
                                              ),
                                            );
                                          },
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeFile(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Input area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Attachment button
                  IconButton(
                    onPressed: widget.isLoading ? null : _pickMedia,
                    icon: const Icon(Icons.attach_file),
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),

                  // Text input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              decoration: InputDecoration(
                                hintText: widget.conversationName != null
                                    ? 'Type a message to ${widget.conversationName}...'
                                    : 'Type a message...',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              enabled: !widget.isLoading,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  Container(
                    decoration: BoxDecoration(
                      color:
                          (_textController.text.trim().isNotEmpty ||
                                  _selectedFiles.isNotEmpty) &&
                              !widget.isLoading
                          ? AppColors.primaryLimeGreen
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed:
                          (_textController.text.trim().isNotEmpty ||
                                  _selectedFiles.isNotEmpty) &&
                              !widget.isLoading
                          ? _sendMessage
                          : null,
                      icon: widget.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white,
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

  bool _isVideoFile(String path) {
    final extensions = ['.mp4', '.webm', '.ogg', '.mov', '.avi'];
    return extensions.any((ext) => path.toLowerCase().endsWith(ext));
  }
}
